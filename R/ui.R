#' @title rviber Shiny UI
#' @description The full UI definition for the rviber panel.

#' Build the rviber Shiny UI
#' @return A shiny UI object
#' @export
rviber_ui <- function() {
  providers    <- get_providers()
  provider_ids <- names(providers)
  provider_labels <- stats::setNames(
    vapply(providers, `[[`, character(1), "name"),
    provider_ids
  )
  cfg <- rviber_config()

  miniUI::miniPage(
    # ── CSS ────────────────────────────────────────────────────────────────
    shiny::tags$head(
      shiny::tags$style(shiny::HTML("
        body { font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', sans-serif; font-size: 13px; }
        .mini-layout { background: #f8f9fa; }

        /* Header bar */
        .gadget-title { background: #2C3E50 !important; color: #fff !important; padding: 8px 12px !important; font-size: 14px !important; }

        /* Tab strip */
        .nav-tabs { border-bottom: 2px solid #dee2e6; }
        .nav-tabs .nav-link { color: #495057; font-size: 12px; padding: 6px 12px; }
        .nav-tabs .nav-link.active { color: #2C3E50; font-weight: 600; border-bottom: 2px solid #2C3E50; }

        /* Chat area */
        #chat_history {
          height: 340px; overflow-y: auto; background: #fff;
          border: 1px solid #dee2e6; border-radius: 6px;
          padding: 10px; margin-bottom: 8px;
          display: flex; flex-direction: column; gap: 8px;
        }
        .msg-user {
          align-self: flex-end; background: #2C3E50; color: #fff;
          border-radius: 12px 12px 2px 12px; padding: 8px 12px;
          max-width: 85%; font-size: 12px; line-height: 1.5;
        }
        .msg-ai {
          align-self: flex-start; background: #f0f2f5; color: #1a1a1a;
          border-radius: 2px 12px 12px 12px; padding: 8px 12px;
          max-width: 92%; font-size: 12px; line-height: 1.5;
        }
        .msg-ai pre { background: #2d2d2d; color: #f8f8f2; border-radius: 4px; padding: 8px; font-size: 11px; overflow-x: auto; }
        .msg-ai code { background: #e9ecef; padding: 1px 4px; border-radius: 3px; font-size: 11px; }
        .msg-error { background: #fff0f0; border-left: 3px solid #e74c3c; padding: 8px 10px; border-radius: 4px; font-size: 12px; color: #c0392b; }
        .msg-system { text-align: center; color: #868e96; font-size: 11px; padding: 4px; }

        /* Input area */
        #user_input { border-radius: 6px; border: 1px solid #dee2e6; font-size: 12px; resize: vertical; }
        #user_input:focus { border-color: #2C3E50; outline: none; box-shadow: 0 0 0 2px rgba(44,62,80,0.15); }

        /* Action buttons */
        .action-bar { display: flex; gap: 5px; flex-wrap: wrap; margin-bottom: 8px; }
        .btn-action {
          font-size: 11px; padding: 4px 10px; border-radius: 4px;
          border: 1px solid #dee2e6; background: #fff; cursor: pointer;
          transition: all 0.15s;
        }
        .btn-action:hover { background: #2C3E50; color: #fff; border-color: #2C3E50; }
        .btn-send {
          background: #2C3E50; color: #fff; border: none;
          border-radius: 6px; padding: 6px 16px; font-size: 12px;
          font-weight: 600; cursor: pointer; width: 100%;
          margin-top: 6px; transition: background 0.15s;
        }
        .btn-send:hover { background: #1a252f; }
        .btn-send:disabled { background: #95a5a6; cursor: not-allowed; }

        /* Settings panel */
        .settings-card { background: #fff; border: 1px solid #dee2e6; border-radius: 8px; padding: 14px; margin-bottom: 10px; }
        .settings-card label { font-size: 12px; font-weight: 600; color: #495057; }
        .settings-card .form-control { font-size: 12px; }

        /* Status bar */
        #status_bar { font-size: 11px; color: #868e96; padding: 4px 0; min-height: 18px; }
        .spinner { display: inline-block; width: 10px; height: 10px;
          border: 2px solid #dee2e6; border-top-color: #2C3E50;
          border-radius: 50%; animation: spin 0.6s linear infinite; margin-right: 4px; }
        @keyframes spin { to { transform: rotate(360deg); } }

        /* Provider badge */
        .provider-badge {
          display: inline-block; font-size: 10px; padding: 2px 8px;
          border-radius: 999px; background: #e8f4fd; color: #2980b9;
          font-weight: 600; margin-left: 6px;
        }
      "))
    ),

    # ── Title bar ─────────────────────────────────────────────────────────
    miniUI::gadgetTitleBar(
      shiny::div(
        "rviber",
        shiny::span(id = "provider_badge", class = "provider-badge",
                    paste0(provider_labels[[cfg$provider]], " / ", cfg$model))
      ),
      right = miniUI::miniTitleBarButton("done", "Close")
    ),

    # ── Body ──────────────────────────────────────────────────────────────
    miniUI::miniTabstripPanel(

      # ── Tab 1: Chat ─────────────────────────────────────────────────────
      miniUI::miniTabPanel("Chat", icon = shiny::icon("comments"),
        miniUI::miniContentPanel(
          # Action buttons
          shiny::div(class = "action-bar",
            shiny::actionButton("btn_explain",  "Explain",   class = "btn-action"),
            shiny::actionButton("btn_fix",      "Fix bugs",  class = "btn-action"),
            shiny::actionButton("btn_improve",  "Improve",   class = "btn-action"),
            shiny::actionButton("btn_complete", "Complete",  class = "btn-action"),
            shiny::actionButton("btn_run",      "Run+Debug", class = "btn-action"),
            shiny::actionButton("btn_clear",    "Clear",     class = "btn-action")
          ),

          # Chat history
          shiny::div(id = "chat_history"),

          # Status
          shiny::div(id = "status_bar"),

          # Input
          shiny::textAreaInput("user_input", NULL, placeholder = "Ask anything about R, or describe code to generate...", rows = 3, width = "100%"),
          shiny::actionButton("btn_send", "Send", class = "btn-send")
        )
      ),

      # ── Tab 2: Generate ─────────────────────────────────────────────────
      miniUI::miniTabPanel("Generate", icon = shiny::icon("wand-magic-sparkles"),
        miniUI::miniContentPanel(
          shiny::h5("Generate R code from plain English"),
          shiny::textAreaInput("gen_description", "What should the code do?",
                               placeholder = "e.g. Read a CSV file, clean missing values, and plot a bar chart of sales by region",
                               rows = 4, width = "100%"),
          shiny::checkboxInput("gen_insert", "Insert code into editor", value = TRUE),
          shiny::actionButton("btn_generate", "Generate Code", class = "btn-send"),
          shiny::hr(),
          shiny::verbatimTextOutput("gen_output")
        )
      ),

      # ── Tab 3: Plot ──────────────────────────────────────────────────────
      miniUI::miniTabPanel("Plot", icon = shiny::icon("chart-bar"),
        miniUI::miniContentPanel(
          shiny::h5("Generate a ggplot2 chart"),
          shiny::textAreaInput("plot_description", "Describe the chart",
                               placeholder = "e.g. Scatter plot of mpg vs wt from the mtcars dataset, coloured by cyl, with a trend line",
                               rows = 3, width = "100%"),
          shiny::selectInput("plot_data", "Data frame (optional)",
                             choices = c("(none)" = "", .list_dataframes()),
                             width = "100%"),
          shiny::checkboxInput("plot_insert", "Insert code into editor", value = TRUE),
          shiny::actionButton("btn_plot", "Generate Plot Code", class = "btn-send"),
          shiny::hr(),
          shiny::verbatimTextOutput("plot_output")
        )
      ),

      # ── Tab 4: Settings ──────────────────────────────────────────────────
      miniUI::miniTabPanel("Settings", icon = shiny::icon("gear"),
        miniUI::miniContentPanel(
          shiny::div(class = "settings-card",
            shiny::h6("AI Provider"),
            shiny::selectInput("settings_provider", "Provider",
                               choices = provider_labels,
                               selected = cfg$provider,
                               width = "100%"),
            shiny::selectInput("settings_model", "Model",
                               choices = providers[[cfg$provider]]$models,
                               selected = cfg$model,
                               width = "100%"),
            shiny::passwordInput("settings_api_key", "API Key",
                                 placeholder = "Paste your API key here (saved locally)",
                                 width = "100%"),
            shiny::textInput("settings_custom_url", "Custom endpoint URL (optional)",
                             placeholder = "http://localhost:11434/v1",
                             width = "100%")
          ),
          shiny::div(class = "settings-card",
            shiny::h6("Behaviour"),
            shiny::sliderInput("settings_temp", "Temperature", min = 0, max = 1, value = cfg$temperature, step = 0.05, width = "100%"),
            shiny::sliderInput("settings_tokens", "Max tokens", min = 256, max = 8192, value = cfg$max_tokens, step = 256, width = "100%"),
            shiny::radioButtons("settings_mode", "Panel mode", inline = TRUE,
                                choices = c("Side panel" = "viewer", "Floating window" = "dialog"),
                                selected = cfg$panel_mode)
          ),
          shiny::actionButton("btn_save_settings", "Save Settings", class = "btn-send"),
          shiny::div(id = "settings_status", style = "margin-top: 8px;")
        )
      )
    )
  )
}

#' List data frames available in the global environment
.list_dataframes <- function() {
  tryCatch({
    objs <- ls(envir = .GlobalEnv)
    dfs  <- objs[vapply(objs, function(x) is.data.frame(get(x, envir = .GlobalEnv)), logical(1))]
    dfs
  }, error = function(e) character(0))
}
