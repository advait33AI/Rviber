#' @title rviber RStudio Addin
#' @description Launches the rviber Shiny panel inside RStudio.

#' Launch the rviber AI assistant
#'
#' This is registered as an RStudio Addin. Users can trigger it from:
#'   Addins menu → rviber: Open AI Assistant
#' or by running rviber_addin() in the console.
#'
#' @param mode "viewer" (side panel) or "dialog" (floating window)
#' @export
rviber_addin <- function(mode = rviber_config("panel_mode")) {
  # First-time setup check
  if (!.is_configured()) {
    msg <- paste0(
      "rviber is not configured yet.\n\n",
      "Run rviber_setup() in the console to choose your AI provider and add your API key.\n\n",
      "It only takes 30 seconds!"
    )
    if (rstudioapi::isAvailable()) {
      rstudioapi::showDialog("rviber — Setup Required", msg)
    } else {
      message(msg)
    }
    return(invisible(NULL))
  }

  app <- .build_shiny_app()

  viewer <- if (mode == "dialog") {
    shiny::dialogViewer("rviber AI Assistant", width = 700, height = 800)
  } else {
    shiny::paneViewer(minHeight = 600)
  }

  shiny::runGadget(app, viewer = viewer, stopOnCancel = FALSE)
}

#' Check if rviber has been configured
.is_configured <- function() {
  provider <- rviber_config("provider")
  if (is.null(provider) || provider == "") return(FALSE)
  tryCatch(provider_is_configured(provider), error = function(e) FALSE)
}

#' Build the Shiny gadget app
.build_shiny_app <- function() {
  app_dir <- system.file("shiny/app", package = "rviber")
  if (nchar(app_dir) == 0 || !dir.exists(app_dir)) {
    # Fallback: load inline app
    return(.inline_app())
  }
  shiny::shinyAppDir(app_dir)
}

#' Minimal inline fallback app (used during development before install)
.inline_app <- function() {
  ui     <- rviber_ui()
  server <- rviber_server
  shiny::shinyApp(ui, server)
}
