# Test setup — runs before all tests
library(rviber)

# Prevent real API calls during tests
# Use mockery package for stubbing
if (!requireNamespace("mockery", quietly = TRUE)) {
  message("Install mockery for full test coverage: install.packages('mockery')")
}
