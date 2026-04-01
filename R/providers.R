#' @title LLM Provider Registry
#' @description Defines all supported LLM providers and handles API calls.
#' Adding a new provider is a one-liner — see `register_provider()`.

# ── Provider registry ─────────────────────────────────────────────────────────

.providers <- new.env(parent = emptyenv())

#' Register a provider definition
#' @param id        Short identifier, e.g. "groq"
#' @param name      Display name, e.g. "Groq"
#' @param base_url  Base URL for the OpenAI-compatible endpoint
#' @param models    Character vector of available model IDs
#' @param key_env   Name of the env var that holds the API key
#' @param auth_type "bearer" (default) or "none" (Ollama)
#' @export
register_provider <- function(id, name, base_url, models, key_env, auth_type = "bearer") {
  .providers[[id]] <- list(
    id        = id,
    name      = name,
    base_url  = base_url,
    models    = models,
    key_env   = key_env,
    auth_type = auth_type
  )
  invisible(NULL)
}

# ── Built-in providers ────────────────────────────────────────────────────────

register_provider(
  id       = "groq",
  name     = "Groq",
  base_url = "https://api.groq.com/openai/v1",
  models   = c("llama-3.3-70b-versatile", "llama-3.1-8b-instant",
               "mixtral-8x7b-32768", "gemma2-9b-it"),
  key_env  = "GROQ_API_KEY"
)

register_provider(
  id       = "gemini",
  name     = "Google Gemini",
  base_url = "https://generativelanguage.googleapis.com/v1beta/openai",
  models   = c("gemini-2.0-flash", "gemini-1.5-pro", "gemini-1.5-flash"),
  key_env  = "GEMINI_API_KEY"
)

register_provider(
  id       = "openai",
  name     = "OpenAI",
  base_url = "https://api.openai.com/v1",
  models   = c("gpt-4o", "gpt-4o-mini", "gpt-4-turbo", "gpt-3.5-turbo"),
  key_env  = "OPENAI_API_KEY"
)

register_provider(
  id       = "anthropic",
  name     = "Anthropic Claude",
  base_url = "https://api.anthropic.com/v1",
  models   = c("claude-opus-4-5", "claude-sonnet-4-5", "claude-haiku-4-5"),
  key_env  = "ANTHROPIC_API_KEY"
)

register_provider(
  id       = "mistral",
  name     = "Mistral AI",
  base_url = "https://api.mistral.ai/v1",
  models   = c("mistral-large-latest", "mistral-small-latest", "open-mixtral-8x22b"),
  key_env  = "MISTRAL_API_KEY"
)

register_provider(
  id       = "together",
  name     = "Together AI",
  base_url = "https://api.together.xyz/v1",
  models   = c("meta-llama/Llama-3-70b-chat-hf",
               "mistralai/Mixtral-8x7B-Instruct-v0.1",
               "codellama/CodeLlama-70b-Instruct-hf"),
  key_env  = "TOGETHER_API_KEY"
)

register_provider(
  id        = "ollama",
  name      = "Ollama (Local)",
  base_url  = "http://localhost:11434/v1",
  models    = c("codellama", "llama3", "mistral", "deepseek-coder", "phi3"),
  key_env   = "",
  auth_type = "none"
)

register_provider(
  id       = "custom",
  name     = "Custom / Self-hosted",
  base_url = "",   # user fills this in
  models   = c(),
  key_env  = "RVIBER_CUSTOM_KEY"
)

# ── Provider accessors ────────────────────────────────────────────────────────

#' List all registered providers
#' @return Named list of provider definitions
#' @export
get_providers <- function() {
  as.list(.providers)
}

#' Get a single provider by ID
#' @param id Provider ID string
#' @return List with provider fields
get_provider <- function(id) {
  p <- .providers[[id]]
  if (is.null(p)) stop(glue::glue("Unknown provider: '{id}'. Use get_providers() to list available ones."))
  p
}

#' Get the API key for a provider from environment variables
#' @param provider_id Provider ID
#' @return API key string or ""
get_api_key <- function(provider_id) {
  p <- get_provider(provider_id)
  if (p$key_env == "") return("")
  key <- Sys.getenv(p$key_env)
  if (key == "") {
    key <- getOption(glue::glue("rviber.{provider_id}_key"), default = "")
  }
  key
}

# ── Core API call ─────────────────────────────────────────────────────────────

#' Call any LLM provider via OpenAI-compatible chat endpoint
#'
#' @param messages  List of message dicts: list(list(role="user", content="..."))
#' @param provider  Provider ID (default from config)
#' @param model     Model ID (default from config)
#' @param system    Optional system prompt string
#' @param temperature Sampling temperature (0-2)
#' @param max_tokens Max tokens in response
#' @return Character string — the assistant's reply
#' @export
llm_chat <- function(
    messages,
    provider    = rviber_config("provider"),
    model       = rviber_config("model"),
    system      = NULL,
    temperature = 0.3,
    max_tokens  = 4096
) {
  p   <- get_provider(provider)
  key <- get_api_key(provider)

  # Build message list with optional system prompt
  all_messages <- messages
  if (!is.null(system)) {
    all_messages <- c(list(list(role = "system", content = system)), messages)
  }

  # Special handling for Anthropic (different endpoint + headers)
  if (provider == "anthropic") {
    return(.call_anthropic(all_messages, model, key, max_tokens, temperature))
  }

  # OpenAI-compatible path (Groq, Gemini, OpenAI, Mistral, Together, Ollama, custom)
  url <- paste0(p$base_url, "/chat/completions")

  req <- httr2::request(url) |>
    httr2::req_headers(
      "Content-Type" = "application/json",
      .if = p$auth_type == "bearer",
      "Authorization" = paste("Bearer", key)
    ) |>
    httr2::req_body_json(list(
      model       = model,
      messages    = all_messages,
      temperature = temperature,
      max_tokens  = max_tokens
    )) |>
    httr2::req_error(is_error = \(resp) FALSE)

  resp <- httr2::req_perform(req)
  body <- httr2::resp_body_json(resp)

  if (!is.null(body$error)) {
    stop(glue::glue("[{provider}] API error: {body$error$message}"))
  }

  body$choices[[1]]$message$content
}

#' Anthropic-specific API call (different request format)
.call_anthropic <- function(messages, model, key, max_tokens, temperature) {
  # Split system from messages
  system_msg <- NULL
  chat_msgs  <- messages
  if (length(messages) > 0 && messages[[1]]$role == "system") {
    system_msg <- messages[[1]]$content
    chat_msgs  <- messages[-1]
  }

  body <- list(
    model       = model,
    max_tokens  = max_tokens,
    temperature = temperature,
    messages    = chat_msgs
  )
  if (!is.null(system_msg)) body$system <- system_msg

  req <- httr2::request("https://api.anthropic.com/v1/messages") |>
    httr2::req_headers(
      "Content-Type"      = "application/json",
      "x-api-key"         = key,
      "anthropic-version" = "2023-06-01"
    ) |>
    httr2::req_body_json(body) |>
    httr2::req_error(is_error = \(resp) FALSE)

  resp <- httr2::req_perform(req)
  body <- httr2::resp_body_json(resp)

  if (!is.null(body$error)) {
    stop(glue::glue("[anthropic] API error: {body$error$message}"))
  }

  body$content[[1]]$text
}

#' Check if a provider's API key is configured
#' @param provider_id Provider ID
#' @return TRUE/FALSE
provider_is_configured <- function(provider_id) {
  p <- get_provider(provider_id)
  if (p$auth_type == "none" || p$key_env == "") return(TRUE)
  get_api_key(provider_id) != ""
}
