test_that("rviber_config returns default values when unconfigured", {
  withr::with_tempdir({
    withr::with_envvar(c(HOME = getwd()), {
      cfg <- rviber_config()
      expect_true(is.list(cfg))
      expect_true("provider"    %in% names(cfg))
      expect_true("model"       %in% names(cfg))
      expect_true("temperature" %in% names(cfg))
    })
  })
})

test_that("rviber_set_config persists values", {
  withr::with_tempdir({
    withr::with_envvar(c(HOME = getwd()), {
      rviber_set_config(provider = "gemini", model = "gemini-2.0-flash")
      cfg <- rviber_config()
      expect_equal(cfg$provider, "gemini")
      expect_equal(cfg$model,    "gemini-2.0-flash")
    })
  })
})

test_that("rviber_config() returns single value with key arg", {
  withr::with_tempdir({
    withr::with_envvar(c(HOME = getwd()), {
      rviber_set_config(temperature = 0.7)
      val <- rviber_config("temperature")
      expect_equal(val, 0.7)
    })
  })
})

test_that("set_provider validates provider id", {
  expect_error(set_provider("nonexistent_provider"), "Unknown provider")
})
