test_that("prompt_explain includes the code", {
  code   <- "x <- 1 + 1"
  result <- prompt_explain(code)
  expect_true(grepl(code, result, fixed = TRUE))
})

test_that("prompt_fix includes error message when provided", {
  code   <- "x <- undefined_var"
  error  <- "object 'undefined_var' not found"
  result <- prompt_fix(code, error)
  expect_true(grepl(error, result, fixed = TRUE))
})

test_that("prompt_fix works without error message", {
  result <- prompt_fix("x <- 1")
  expect_true(nchar(result) > 50)
})

test_that("prompt_generate includes the description", {
  desc   <- "read a CSV and calculate summary statistics"
  result <- prompt_generate(desc)
  expect_true(grepl(desc, result, fixed = TRUE))
})

test_that("prompt_plot includes description and data info", {
  desc   <- "bar chart of sales by month"
  data_i <- "data.frame: sales, cols: month, revenue"
  result <- prompt_plot(desc, data_i)
  expect_true(grepl(desc, result, fixed = TRUE))
  expect_true(grepl("ggplot2", result, fixed = TRUE))
})

test_that("all prompts return character strings", {
  code <- "mean(c(1,2,3))"
  expect_type(prompt_chat(),          "character")
  expect_type(prompt_explain(code),   "character")
  expect_type(prompt_fix(code),       "character")
  expect_type(prompt_improve(code),   "character")
  expect_type(prompt_complete(code),  "character")
  expect_type(prompt_generate("do something"), "character")
  expect_type(prompt_plot("a scatter plot"),   "character")
})
