#' @title rviber Shiny Server
#' @description All reactive logic for the rviber panel.

#' rviber Shiny server function
#' @param input,output,session Shiny standard args
#' @export
rviber_server <- function(input, output, session) {

  # ── Reactive state ─────────────────────────────────────────────────────────
  rv <- shiny::reactiveValues(
    history  = list(),       # Chat message history [{role, content}]
    thinking = FALSE,        # Loading state
    provider = rviber_config("provider"),
    model    = rviber_config("model")
  )

  # ── Helpers ────────────────────────────────────────────────────────────────

  # Add a message bubble to the chat
  add_message <- function(role, content) {
    rv$history <- c(rv$history, list(list(role = role, content = content)))
    .render_chat(rv$history, session)
  }

  # Show/hide the spinner
  set_thinking <- function(state) {
    rv$thinking <- state
    if (state) {
      shinyjs::html("status_bar", '<span class="spinner"></span> Thinking...')
      shinyjs::disable("btn_send")
    } else {
      shinyjs::html("status_bar", "")
      shinyjs::enable("btn_send")
    }
  }

  # Call the LLM and handle errors cleanly
  call_ai <- function(messages, system = NULL) {
    tryCatch(
      llm_chat(messages,
               provider = rv$provider,
               model    = rv$model,
               system   = system),
      error = function(e) {
        paste0("**Error:** ", conditionMessage(e),
               "\n\nCheck your API key in the Settings tab.")
      }
    )
  }

  # ── Close button ───────────────────────────────────────────────────────────
  shiny::observeEvent(input$done, shiny::stopApp())

  # ── Chat: Send message ─────────────────────────────────────────────────────
  shiny::observeEvent(input$btn_send, {
    msg <- trimws(input$user_input)
    if (nchar(msg) == 0) return()
    shiny::updateTextAreaInput(session, "user_input", value = "")
    add_message("user", msg)
    set_thinking(TRUE)

    shiny::isolate({
      msgs     <- rv$history
      provider <- rv$provider
      model    <- rv$model
    })

    shiny::observe({
      response <- call_ai(msgs, system = prompt_chat())
      add_message("assistant", response)
      set_thinking(FALSE)
    }) |> shiny::bindEvent(shiny::reactiveTimer(50)(), once = TRUE)
  })

  # Also send on Ctrl+Enter
  shinyjs::onevent("keydown", "user_input", shiny::JS("
    function(e) {
      if ((e.ctrlKey || e.metaKey) && e.keyCode === 13) {
        document.getElementById('btn_send').click();
      }
    }
  "))

  # ── Chat: Action buttons ───────────────────────────────────────────────────

  # Explain selected code
  shiny::observeEvent(input$btn_explain, {
    code <- get_selected_code()
    if (nchar(code) == 0) {
      add_message("system", "No code selected. Select some R code in the editor first.")
      return()
    }
    add_message("user", paste0("Explain this code:\n```r\n", code, "\n```"))
    set_thinking(TRUE)
    shiny::observe({
      response <- call_ai(
        list(list(role = "user", content = "Explain this code.")),
        system = prompt_explain(code)
      )
      add_message("assistant", response)
      set_thinking(FALSE)
    }) |> shiny::bindEvent(shiny::reactiveTimer(50)(), once = TRUE)
  })

  # Fix bugs
  shiny::observeEvent(input$btn_fix, {
    code <- get_selected_code()
    if (nchar(code) == 0) {
      add_message("system", "No code selected.")
      return()
    }
    add_message("user", paste0("Fix bugs in:\n```r\n", code, "\n```"))
    set_thinking(TRUE)
    shiny::observe({
      response <- call_ai(
        list(list(role = "user", content = "Fix this code.")),
        system = prompt_fix(code)
      )
      add_message("assistant", response)
      # Auto-insert fixed code
      fixed <- .extract_code_block(response)
      if (!is.null(fixed)) replace_selection(fixed)
      set_thinking(FALSE)
    }) |> shiny::bindEvent(shiny::reactiveTimer(50)(), once = TRUE)
  })

  # Improve / refactor
  shiny::observeEvent(input$btn_improve, {
    code <- get_selected_code()
    if (nchar(code) == 0) {
      add_message("system", "No code selected.")
      return()
    }
    add_message("user", paste0("Improve this code:\n```r\n", code, "\n```"))
    set_thinking(TRUE)
    shiny::observe({
      response <- call_ai(
        list(list(role = "user", content = "Improve this code.")),
        system = prompt_improve(code)
      )
      add_message("assistant", response)
      set_thinking(FALSE)
    }) |> shiny::bindEvent(shiny::reactiveTimer(50)(), once = TRUE)
  })

  # Autocomplete
  shiny::observeEvent(input$btn_complete, {
    code <- get_document_code()
    add_message("user", "Complete my code from where I left off.")
    set_thinking(TRUE)
    shiny::observe({
      response <- call_ai(
        list(list(role = "user", content = "Complete this code.")),
        system = prompt_complete(code)
      )
      add_message("assistant", response)
      completion <- .extract_code_block(response)
      if (!is.null(completion)) insert_at_cursor(paste0("\n", completion))
      set_thinking(FALSE)
    }) |> shiny::bindEvent(shiny::reactiveTimer(50)(), once = TRUE)
  })

  # Run + debug
  shiny::observeEvent(input$btn_run, {
    code <- get_selected_code()
    if (nchar(code) == 0) {
      add_message("system", "No code selected.")
      return()
    }
    add_message("user", paste0("Run and debug:\n```r\n", code, "\n```"))
    set_thinking(TRUE)
    shiny::observe({
      result   <- rviber_run_debug(code)
      response <- result$ai_response
      add_message("assistant", response)
      set_thinking(FALSE)
    }) |> shiny::bindEvent(shiny::reactiveTimer(50)(), once = TRUE)
  })

  # Clear chat
  shiny::observeEvent(input$btn_clear, {
    rv$history <- list()
    .render_chat(list(), session)
  })

  # ── Generate tab ───────────────────────────────────────────────────────────
  shiny::observeEvent(input$btn_generate, {
    desc <- trimws(input$gen_description)
    if (nchar(desc) == 0) return()
    set_thinking(TRUE)
    shiny::observe({
      response <- call_ai(
        list(list(role = "user", content = desc)),
        system = prompt_generate(desc)
      )
      output$gen_output <- shiny::renderText(response)
      if (isTRUE(input$gen_insert)) {
        code <- .extract_code_block(response)
        if (!is.null(code)) insert_at_cursor(code)
      }
      set_thinking(FALSE)
    }) |> shiny::bindEvent(shiny::reactiveTimer(50)(), once = TRUE)
  })

  # ── Plot tab ───────────────────────────────────────────────────────────────
  shiny::observeEvent(input$btn_plot, {
    desc <- trimws(input$plot_description)
    if (nchar(desc) == 0) return()
    data_name <- if (input$plot_data == "") NULL else input$plot_data
    set_thinking(TRUE)
    shiny::observe({
      response <- call_ai(
        list(list(role = "user", content = desc)),
        system = prompt_plot(desc, data_name)
      )
      output$plot_output <- shiny::renderText(response)
      if (isTRUE(input$plot_insert)) {
        code <- .extract_code_block(response)
        if (!is.null(code)) insert_at_cursor(code)
      }
      set_thinking(FALSE)
    }) |> shiny::bindEvent(shiny::reactiveTimer(50)(), once = TRUE)
  })

  # ── Settings tab ───────────────────────────────────────────────────────────

  # Update model list when provider changes
  shiny::observeEvent(input$settings_provider, {
    provider <- input$settings_provider
    p <- get_provider(provider)
    shiny::updateSelectInput(session, "settings_model", choices = p$models)
    # Pre-fill API key hint
    existing <- get_api_key(provider)
    if (nchar(existing) > 0) {
      shinyjs::html("settings_status",
        '<span style="color:#27ae60">✓ API key found in environment</span>')
    } else {
      shinyjs::html("settings_status", "")
    }
  })

  # Save settings
  shiny::observeEvent(input$btn_save_settings, {
    provider <- input$settings_provider
    model    <- input$settings_model
    api_key  <- trimws(input$settings_api_key)

    # Save API key to config if provided
    if (nchar(api_key) > 0) {
      keys <- rviber_config("api_keys")
      keys[[provider]] <- api_key
      rviber_set_config(api_keys = keys)
    }

    # Handle custom URL
    custom_url <- trimws(input$settings_custom_url)
    if (nchar(custom_url) > 0 && provider == "custom") {
      .providers[["custom"]]$base_url <- custom_url
    }

    rviber_set_config(
      provider    = provider,
      model       = model,
      temperature = input$settings_temp,
      max_tokens  = input$settings_tokens,
      panel_mode  = input$settings_mode
    )

    rv$provider <- provider
    rv$model    <- model

    # Update badge
    providers <- get_providers()
    badge_text <- paste0(providers[[provider]]$name, " / ", model)
    shinyjs::html("provider_badge", badge_text)
    shinyjs::html("settings_status",
      '<span style="color:#27ae60">✓ Settings saved!</span>')
  })
}

# ── Chat rendering ────────────────────────────────────────────────────────────

#' Render chat history as HTML bubbles in the panel
.render_chat <- function(history, session) {
  html_parts <- vapply(history, function(msg) {
    content <- .md_to_html(msg$content)
    if (msg$role == "user") {
      glue::glue('<div class="msg-user">{content}</div>')
    } else if (msg$role == "system") {
      glue::glue('<div class="msg-system">{content}</div>')
    } else {
      glue::glue('<div class="msg-ai">{content}</div>')
    }
  }, character(1))

  html <- paste(html_parts, collapse = "\n")
  session$sendCustomMessage("update_chat", list(html = html))
}

#' Very lightweight markdown → HTML conversion for chat bubbles
.md_to_html <- function(text) {
  # Code blocks
  text <- gsub("```r?\n([\\s\\S]*?)```", "<pre><code>\\1</code></pre>", text, perl = TRUE)
  # Inline code
  text <- gsub("`([^`]+)`", "<code>\\1</code>", text)
  # Bold
  text <- gsub("\\*\\*(.+?)\\*\\*", "<strong>\\1</strong>", text)
  # Newlines
  text <- gsub("\n", "<br>", text)
  text
}
