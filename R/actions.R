#' @title rviber Actions
#' @description High-level functions for each AI feature.
#' These can be called from R console, scripts, or the Shiny UI.

# ── Helper: get selected code from RStudio editor ─────────────────────────────

#' Get the currently selected text in the active RStudio editor
#' @return Character string of selected code, or "" if nothing selected
get_selected_code <- function() {
  if (!rstudioapi::isAvailable()) return("")
  ctx <- rstudioapi::getActiveDocumentContext()
  sel <- ctx$selection[[1]]$text
  trimws(sel)
}

#' Get all code in the active RStudio editor
#' @return Character string of full document contents
get_document_code <- function() {
  if (!rstudioapi::isAvailable()) return("")
  ctx <- rstudioapi::getActiveDocumentContext()
  paste(ctx$contents, collapse = "\n")
}

#' Insert text at the current cursor position in RStudio
#' @param text Text to insert
insert_at_cursor <- function(text) {
  if (!rstudioapi::isAvailable()) {
    cat(text)
    return(invisible(NULL))
  }
  rstudioapi::insertText(text)
}

#' Replace the current selection in RStudio with new text
#' @param text Replacement text
replace_selection <- function(text) {
  if (!rstudioapi::isAvailable()) {
    cat(text)
    return(invisible(NULL))
  }
  ctx  <- rstudioapi::getActiveDocumentContext()
  rng  <- ctx$selection[[1]]$range
  rstudioapi::modifyRange(rng, text)
}

# ── Core action functions ─────────────────────────────────────────────────────

#' Chat with the AI about R code
#'
#' @param message User message string
#' @param history  List of prior messages for multi-turn conversation
#' @param provider Provider ID (defaults to config)
#' @param model    Model ID (defaults to config)
#' @return Character string — AI response
#' @export
rviber_chat <- function(
    message,
    history  = list(),
    provider = rviber_config("provider"),
    model    = rviber_config("model")
) {
  messages <- c(history, list(list(role = "user", content = message)))
  llm_chat(messages, provider = provider, model = model, system = prompt_chat())
}

#' Explain the currently selected R code
#'
#' @param code     Code to explain (defaults to RStudio selection)
#' @param insert   If TRUE, insert explanation as a comment above selection
#' @return Character string — explanation
#' @export
rviber_explain <- function(code = get_selected_code(), insert = FALSE) {
  if (nchar(code) == 0) {
    cli::cli_alert_danger("No code selected. Select some R code in the editor first.")
    return(invisible(NULL))
  }
  cli::cli_alert_info("Explaining code...")
  response <- llm_chat(
    messages = list(list(role = "user", content = "Please explain this code.")),
    system   = prompt_explain(code)
  )
  if (insert) {
    commented <- paste0("# ", gsub("\n", "\n# ", response), "\n")
    insert_at_cursor(commented)
  }
  response
}

#' Fix bugs in the currently selected R code
#'
#' @param code    Code to fix (defaults to RStudio selection)
#' @param error   Optional error message to help the AI
#' @param replace If TRUE, replace the selection with fixed code
#' @return Character string — fixed code + explanation
#' @export
rviber_fix <- function(
    code    = get_selected_code(),
    error   = NULL,
    replace = FALSE
) {
  if (nchar(code) == 0) {
    cli::cli_alert_danger("No code selected. Select some R code in the editor first.")
    return(invisible(NULL))
  }
  cli::cli_alert_info("Fixing code...")
  response <- llm_chat(
    messages = list(list(role = "user", content = "Fix this code.")),
    system   = prompt_fix(code, error)
  )
  if (replace) {
    fixed_code <- .extract_code_block(response)
    if (!is.null(fixed_code)) replace_selection(fixed_code)
  }
  response
}

#' Improve / refactor the currently selected R code
#'
#' @param code    Code to improve (defaults to RStudio selection)
#' @param replace If TRUE, replace the selection with improved code
#' @return Character string — improved code + changelog
#' @export
rviber_improve <- function(code = get_selected_code(), replace = FALSE) {
  if (nchar(code) == 0) {
    cli::cli_alert_danger("No code selected. Select some R code in the editor first.")
    return(invisible(NULL))
  }
  cli::cli_alert_info("Improving code...")
  response <- llm_chat(
    messages = list(list(role = "user", content = "Improve this code.")),
    system   = prompt_improve(code)
  )
  if (replace) {
    improved <- .extract_code_block(response)
    if (!is.null(improved)) replace_selection(improved)
  }
  response
}

#' Autocomplete — suggest the next lines of code
#'
#' @param code   Code written so far (defaults to full document up to cursor)
#' @param insert If TRUE, insert the completion at the cursor
#' @return Character string — completion
#' @export
rviber_complete <- function(code = get_document_code(), insert = FALSE) {
  if (nchar(code) == 0) {
    cli::cli_alert_danger("Editor is empty.")
    return(invisible(NULL))
  }
  cli::cli_alert_info("Generating completion...")
  response <- llm_chat(
    messages = list(list(role = "user", content = "Complete this code.")),
    system   = prompt_complete(code)
  )
  if (insert) {
    completion <- .extract_code_block(response)
    if (!is.null(completion)) insert_at_cursor(paste0("\n", completion))
  }
  response
}

#' Generate R code from a plain English description
#'
#' @param description Natural language description of what you want
#' @param insert      If TRUE, insert at cursor in the editor
#' @return Character string — generated code
#' @export
rviber_generate <- function(description, insert = FALSE) {
  if (missing(description) || nchar(trimws(description)) == 0) {
    cli::cli_alert_danger("Provide a description of what code to generate.")
    return(invisible(NULL))
  }
  cli::cli_alert_info("Generating code...")
  context <- tryCatch(get_document_code(), error = function(e) NULL)
  response <- llm_chat(
    messages = list(list(role = "user", content = description)),
    system   = prompt_generate(description, context)
  )
  if (insert) {
    code <- .extract_code_block(response)
    if (!is.null(code)) insert_at_cursor(code)
  }
  response
}

#' Generate a ggplot2 chart from a description
#'
#' @param description Description of the chart to create
#' @param data_name   Name of a data frame available in the global env
#' @param insert      If TRUE, insert code at cursor
#' @return Character string — ggplot2 code
#' @export
rviber_plot <- function(description, data_name = NULL, insert = FALSE) {
  data_info <- NULL
  if (!is.null(data_name)) {
    df <- tryCatch(get(data_name, envir = .GlobalEnv), error = function(e) NULL)
    if (!is.null(df)) {
      data_info <- paste(
        glue::glue("Object: {data_name}"),
        glue::glue("Dimensions: {nrow(df)} rows x {ncol(df)} cols"),
        paste("Columns:", paste(names(df), collapse = ", ")),
        paste(utils::capture.output(utils::str(df, max.level = 1)), collapse = "\n"),
        sep = "\n"
      )
    }
  }

  cli::cli_alert_info("Generating ggplot2 chart...")
  response <- llm_chat(
    messages = list(list(role = "user", content = description)),
    system   = prompt_plot(description, data_info)
  )
  if (insert) {
    code <- .extract_code_block(response)
    if (!is.null(code)) insert_at_cursor(code)
  }
  response
}

#' Run code and get AI help understanding the output
#'
#' @param code Code to run (defaults to selected code)
#' @return List with output, error, and ai_response
#' @export
rviber_run_debug <- function(code = get_selected_code()) {
  if (nchar(code) == 0) {
    cli::cli_alert_danger("No code selected.")
    return(invisible(NULL))
  }

  # Run in a temp environment and capture everything
  output <- ""
  error  <- NULL
  env    <- new.env(parent = globalenv())

  result <- tryCatch({
    out_con <- textConnection("output_lines", "w", local = TRUE)
    sink(out_con)
    eval(parse(text = code), envir = env)
    sink()
    close(out_con)
    output <- paste(output_lines, collapse = "\n")
    list(success = TRUE)
  }, error = function(e) {
    sink()
    error <<- conditionMessage(e)
    list(success = FALSE)
  }, warning = function(w) {
    sink()
    list(success = TRUE, warning = conditionMessage(w))
  })

  ai_response <- llm_chat(
    messages = list(list(role = "user", content = "Help me understand this output.")),
    system   = prompt_debug(code, output, error)
  )

  list(output = output, error = error, ai_response = ai_response)
}

# ── Utility ───────────────────────────────────────────────────────────────────

#' Extract the first R code block from a markdown response
#' @param text Markdown text containing ```r ... ``` blocks
#' @return Code string or NULL
.extract_code_block <- function(text) {
  pattern <- "```(?:r|R)\\n([\\s\\S]*?)```"
  m <- regmatches(text, regexpr(pattern, text, perl = TRUE))
  if (length(m) == 0) return(NULL)
  # Strip the fence markers
  gsub("^```(?:r|R)\\n|```$", "", m, perl = TRUE)
}
