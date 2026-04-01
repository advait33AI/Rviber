# Console Functions

Every rviber feature works as a plain R function — no panel, no Shiny, just the console or a script.

---

## rviber_setup()

First-time configuration wizard. Pick a provider and enter your API key.

```r
rviber_setup()
```

---

## rviber_addin()

Open the rviber panel inside RStudio.

```r
rviber_addin()                    # side panel (default)
rviber_addin(mode = "dialog")     # floating window
rviber_addin(mode = "viewer")     # side panel explicitly
```

---

## rviber_chat()

Chat with the AI. Returns the response as a character string.

```r
# Single message
rviber_chat("How do I pivot a dataframe from wide to long?")

# Multi-turn — pass history
history <- list(
  list(role = "user",      content = "What is ggplot2?"),
  list(role = "assistant", content = "ggplot2 is an R package for data visualisation...")
)
rviber_chat("Give me an example of a scatter plot", history = history)

# Use a specific provider for this call
rviber_chat("Explain tidy evaluation", provider = "gemini", model = "gemini-2.0-flash")
```

---

## rviber_explain()

Explain R code in plain English.

```r
# Explain selected code in the active editor
rviber_explain()

# Explain specific code
rviber_explain(code = "
  df %>%
    group_by(region) %>%
    summarise(
      mean_sales = mean(sales, na.rm = TRUE),
      n          = n()
    ) %>%
    arrange(desc(mean_sales))
")

# Insert explanation as a comment above the selection
rviber_explain(insert = TRUE)
```

---

## rviber_fix()

Find and fix bugs in R code. Optionally replaces the selection in the editor.

```r
# Fix selected code
rviber_fix()

# Fix specific code
rviber_fix(code = "ggplot(df) + geom_pont(aes(x = wt, y = mpg))")

# Fix with error message for better context
rviber_fix(
  code  = "mean(df$sales, na.omit = TRUE)",
  error = "Error in mean.default(df$sales, na.omit = TRUE) : unused argument (na.omit = TRUE)"
)

# Replace selection in editor with fixed code
rviber_fix(replace = TRUE)
```

---

## rviber_improve()

Refactor and improve R code — cleaner style, tidyverse conventions, added comments.

```r
# Improve selected code
rviber_improve()

# Improve specific code
rviber_improve(code = "
result = c()
for(i in 1:length(x)) {
  if(x[i] > 0) {
    result = c(result, x[i])
  }
}
result
")
# Returns: x[x > 0]

# Replace selection in editor
rviber_improve(replace = TRUE)
```

---

## rviber_complete()

Autocomplete — suggest the next lines of code.

```r
# Complete from the full current document
rviber_complete()

# Complete from specific code
rviber_complete(code = "
library(tidyverse)
df <- read_csv('sales.csv')
df <- df %>% filter(!is.na(sales))
# group by region and calculate...
")

# Insert completion at cursor
rviber_complete(insert = TRUE)
```

---

## rviber_generate()

Generate R code from a plain English description.

```r
# Generate and print
rviber_generate("Calculate a rolling 7-day average of daily sales grouped by product")

# Generate and insert at cursor
rviber_generate(
  description = "Fit a random forest model to predict churn, tune mtry using cross-validation, plot variable importance",
  insert      = TRUE
)

# More examples
rviber_generate("Create a Shiny app with a file upload input that shows a summary table and histogram")
rviber_generate("Write unit tests for a function called clean_text() using testthat")
rviber_generate("Connect to a PostgreSQL database using DBI and query the orders table")
```

---

## rviber_plot()

Generate ggplot2 chart code from a description.

```r
# Basic chart
rviber_plot("Histogram of departure delays from the nycflights13 flights dataset")

# With data frame name — rviber inspects its structure automatically
rviber_plot(
  description = "Box plot of price by cut, coloured by clarity, with outliers shown",
  data_name   = "diamonds"
)

# Insert code into editor
rviber_plot(
  description = "Faceted line chart of monthly sales by product category",
  data_name   = "sales_df",
  insert      = TRUE
)
```

---

## rviber_run_debug()

Execute code and get AI help understanding the output.

```r
result <- rviber_run_debug(code = "
library(dplyr)
data(mtcars)
mtcars %>%
  group_by(cyl) %>%
  summarise(mean_mpg = mean(mpg), n = n())
")

cat(result$output)       # the actual R output
cat(result$ai_response)  # AI explanation of the output
cat(result$error)        # any error message (NULL if none)
```

---

## set_provider()

Switch the active AI provider and model.

```r
set_provider("groq",      model = "llama-3.3-70b-versatile")
set_provider("gemini",    model = "gemini-2.0-flash")
set_provider("openai",    model = "gpt-4o-mini")
set_provider("anthropic", model = "claude-haiku-4-5")
set_provider("ollama",    model = "codellama")
set_provider("mistral",   model = "mistral-large-latest")

# Use default model for provider
set_provider("groq")
```

---

## get_providers()

List all registered providers and their details.

```r
providers <- get_providers()
names(providers)
# [1] "groq" "gemini" "openai" "anthropic" "mistral" "together" "ollama" "custom"

# Get details for one provider
providers$groq$models
# [1] "llama-3.3-70b-versatile" "llama-3.1-8b-instant" ...
```

---

## rviber_config()

Read the current configuration.

```r
# Full config
cfg <- rviber_config()
cfg$provider    # "groq"
cfg$model       # "llama-3.3-70b-versatile"
cfg$temperature # 0.3

# Single value
rviber_config("provider")   # "groq"
rviber_config("model")      # "llama-3.3-70b-versatile"
```
