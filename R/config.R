#' @title rviber Configuration
#' @description Read/write persistent settings stored in ~/.rviber/config.json

.config_path <- function() {
  file.path(Sys.getenv("HOME"), ".rviber", "config.json")
}

.default_config <- list(
  provider    = "groq",
  model       = "llama-3.3-70b-versatile",
  temperature = 0.3,
  max_tokens  = 4096,
  panel_mode  = "viewer",   # "viewer" | "dialog"
  theme       = "auto",
  show_tokens = TRUE,
  api_keys    = list()      # provider_id -> key (fallback if env var not set)
)

#' Read a config value (or the whole config)
#'
#' @param key Config key, e.g. "provider". NULL returns the full list.
#' @return Config value or full config list
#' @export
rviber_config <- function(key = NULL) {
  cfg_file <- .config_path()
  cfg <- if (file.exists(cfg_file)) {
    tryCatch(
      jsonlite::fromJSON(cfg_file, simplifyVector = FALSE),
      error = function(e) .default_config
    )
  } else {
    .default_config
  }
  # Fill in any missing keys from defaults
  for (k in names(.default_config)) {
    if (is.null(cfg[[k]])) cfg[[k]] <- .default_config[[k]]
  }
  if (is.null(key)) cfg else cfg[[key]]
}

#' Write one or more config values
#'
#' @param ... Named arguments, e.g. provider = "gemini", model = "gemini-2.0-flash"
#' @return Invisibly returns updated config
#' @export
rviber_set_config <- function(...) {
  cfg <- rviber_config()
  updates <- list(...)
  for (k in names(updates)) cfg[[k]] <- updates[[k]]
  dir.create(dirname(.config_path()), showWarnings = FALSE, recursive = TRUE)
  jsonlite::write_json(cfg, .config_path(), auto_unbox = TRUE, pretty = TRUE)
  invisible(cfg)
}

#' Interactive setup wizard — called on first use or via rviber_setup()
#'
#' Guides the user through picking a provider and entering their API key.
#' @export
rviber_setup <- function() {
  cli::cli_h1("rviber Setup")
  cli::cli_alert_info("This wizard sets up your AI provider. You can re-run it anytime with {.fn rviber_setup}.")

  providers <- get_providers()
  provider_ids   <- names(providers)
  provider_names <- vapply(providers, `[[`, character(1), "name")

  cat("\nAvailable providers:\n")
  for (i in seq_along(provider_ids)) {
    cat(glue::glue("  [{i}] {provider_names[i]}\n"))
  }

  choice <- readline(prompt = "\nPick a provider (number): ")
  idx    <- suppressWarnings(as.integer(trimws(choice)))

  if (is.na(idx) || idx < 1 || idx > length(provider_ids)) {
    cli::cli_alert_danger("Invalid choice. Run rviber_setup() again.")
    return(invisible(NULL))
  }

  provider_id <- provider_ids[idx]
  p           <- providers[[provider_id]]

  cli::cli_alert_info("Selected: {p$name}")

  # Ask for API key if needed
  api_key <- ""
  if (p$auth_type != "none" && p$key_env != "") {
    existing <- Sys.getenv(p$key_env)
    if (existing != "") {
      cli::cli_alert_success("Found {p$key_env} in environment — using it.")
      api_key <- existing
    } else {
      cat(glue::glue("\nGet your API key from the {p$name} website.\n"))
      api_key <- readline(prompt = glue::glue("Paste your {p$name} API key: "))
      api_key <- trimws(api_key)

      if (nchar(api_key) > 0) {
        # Save to config and offer to add to .Renviron
        keys <- rviber_config("api_keys")
        keys[[provider_id]] <- api_key
        rviber_set_config(api_keys = keys)

        add_env <- readline(prompt = glue::glue("Add {p$key_env} to ~/.Renviron for future sessions? [y/N]: "))
        if (tolower(trimws(add_env)) == "y") {
          .append_renviron(p$key_env, api_key)
          cli::cli_alert_success("Added to ~/.Renviron. Restart R for it to take effect.")
        }
      }
    }
  } else {
    cli::cli_alert_success("{p$name} needs no API key.")
  }

  # Pick default model
  cat("\nAvailable models:\n")
  for (i in seq_along(p$models)) {
    cat(glue::glue("  [{i}] {p$models[i]}\n"))
  }
  model_choice <- readline(prompt = "Pick a model (number, or Enter for default): ")
  model_idx    <- suppressWarnings(as.integer(trimws(model_choice)))
  model <- if (is.na(model_idx) || model_idx < 1 || model_idx > length(p$models)) {
    p$models[1]
  } else {
    p$models[model_idx]
  }

  rviber_set_config(provider = provider_id, model = model)
  cli::cli_alert_success("rviber configured: {p$name} / {model}")
  cli::cli_alert_info("Open the assistant with: rviber_addin()  or  Addins -> rviber")
  invisible(list(provider = provider_id, model = model))
}

#' Set the active provider and model
#'
#' @param provider Provider ID, e.g. "groq", "gemini", "openai"
#' @param model    Model ID. If NULL, uses the first model for the provider.
#' @export
set_provider <- function(provider, model = NULL) {
  p <- get_provider(provider)
  if (is.null(model)) model <- p$models[1]
  rviber_set_config(provider = provider, model = model)
  cli::cli_alert_success("Provider set to {p$name} / {model}")
  invisible(list(provider = provider, model = model))
}

# ── Internal helpers ──────────────────────────────────────────────────────────

.append_renviron <- function(key, value) {
  renviron <- file.path(Sys.getenv("HOME"), ".Renviron")
  line <- glue::glue('\n{key}="{value}"\n')
  cat(line, file = renviron, append = TRUE)
}

#' Retrieve stored API key from config (fallback if env var not set)
.stored_api_key <- function(provider_id) {
  keys <- rviber_config("api_keys")
  keys[[provider_id]] %||% ""
}

`%||%` <- function(a, b) if (!is.null(a) && a != "") a else b
