test_that(".extract_code_block extracts r code blocks", {
  response <- "Here is the code:\n```r\nx <- 42\nprint(x)\n```\nThis prints 42."
  result   <- rviber:::.extract_code_block(response)
  expect_equal(trimws(result), "x <- 42\nprint(x)")
})

test_that(".extract_code_block returns NULL when no block", {
  result <- rviber:::.extract_code_block("No code here, just text.")
  expect_null(result)
})

test_that(".extract_code_block handles uppercase R fence", {
  response <- "```R\ndf <- data.frame(x=1:3)\n```"
  result   <- rviber:::.extract_code_block(response)
  expect_false(is.null(result))
})

test_that("rviber_chat returns character", {
  # Mock llm_chat
  mockery::stub(rviber_chat, "llm_chat", "Mocked AI response")
  result <- rviber_chat("What is ggplot2?")
  expect_type(result, "character")
})

test_that("rviber_explain handles empty code gracefully", {
  mockery::stub(rviber_explain, "get_selected_code", "")
  result <- rviber_explain()
  expect_null(result)
})

test_that("rviber_generate handles empty description", {
  result <- rviber_generate("")
  expect_null(result)
})
