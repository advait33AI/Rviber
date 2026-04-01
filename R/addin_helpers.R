#' @title Addin helper wrappers
#' @description These are the bindings registered in addins.dcf for actions
#' that need user input before running.

#' Generate code addin — shows an input dialog then inserts code
#' @export
rviber_generate_addin <- function() {
  if (!rstudioapi::isAvailable()) {
    message("rviber requires RStudio.")
    return(invisible(NULL))
  }
  desc <- rstudioapi::showPrompt(
    title   = "rviber: Generate Code",
    message = "Describe what you want the code to do:",
    default = ""
  )
  if (is.null(desc) || nchar(trimws(desc)) == 0) return(invisible(NULL))
  cli::cli_alert_info("Generating code for: {desc}")
  rviber_generate(desc, insert = TRUE)
}

#' Plot addin — shows an input dialog then inserts ggplot2 code
#' @export
rviber_plot_addin <- function() {
  if (!rstudioapi::isAvailable()) {
    message("rviber requires RStudio.")
    return(invisible(NULL))
  }
  desc <- rstudioapi::showPrompt(
    title   = "rviber: Generate Plot",
    message = "Describe the chart you want to create:",
    default = ""
  )
  if (is.null(desc) || nchar(trimws(desc)) == 0) return(invisible(NULL))

  # Try to detect data frame in scope
  data_name <- rstudioapi::showPrompt(
    title   = "rviber: Data frame",
    message = "Name of your data frame (or leave blank):",
    default = ""
  )
  data_name <- if (is.null(data_name) || nchar(trimws(data_name)) == 0) NULL else trimws(data_name)

  cli::cli_alert_info("Generating ggplot2 code...")
  rviber_plot(desc, data_name = data_name, insert = TRUE)
}
