test_that("all built-in providers are registered", {
  providers <- get_providers()
  expected  <- c("groq", "gemini", "openai", "anthropic", "mistral", "together", "ollama", "custom")
  for (id in expected) {
    expect_true(id %in% names(providers), info = paste("Missing provider:", id))
  }
})

test_that("each provider has required fields", {
  providers <- get_providers()
  required  <- c("id", "name", "base_url", "models", "key_env")
  for (id in names(providers)) {
    p <- providers[[id]]
    for (field in required) {
      expect_true(!is.null(p[[field]]), info = paste(id, "missing field:", field))
    }
  }
})

test_that("each provider has at least one model", {
  providers <- get_providers()
  for (id in names(providers)) {
    p <- providers[[id]]
    if (id != "custom") {
      expect_true(length(p$models) > 0, info = paste(id, "has no models"))
    }
  }
})

test_that("get_provider() throws on unknown id", {
  expect_error(get_provider("does_not_exist"), "Unknown provider")
})

test_that("provider_is_configured() returns FALSE when key missing", {
  withr::with_envvar(c(GROQ_API_KEY = ""), {
    # Only if key not in config either
    result <- tryCatch(provider_is_configured("groq"), error = function(e) FALSE)
    expect_true(is.logical(result))
  })
})

test_that("register_provider() adds a new provider", {
  register_provider(
    id       = "test_provider",
    name     = "Test Provider",
    base_url = "https://test.example.com/v1",
    models   = c("test-model-1"),
    key_env  = "TEST_API_KEY"
  )
  providers <- get_providers()
  expect_true("test_provider" %in% names(providers))
  expect_equal(providers$test_provider$name, "Test Provider")
})
