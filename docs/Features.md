# Features

rviber has 8 core features, each accessible from the Addins menu, the panel, or the R console.

---

## 1. Chat

Talk to the AI about anything R-related — concepts, packages, statistics, debugging, code reviews.

**From the panel:** Open the panel → type in the chat box → press Send or Ctrl+Enter

**From the console:**
```r
rviber_chat("What is the difference between lapply and sapply?")
rviber_chat("How do I use purrr::map2 with multiple arguments?")
rviber_chat("Explain tidy evaluation in rlang")
```

The chat is multi-turn — the AI remembers the full conversation history within a session.

---

## 2. Explain Selected Code

Select any R code in the editor and get a plain-English explanation.

**From the panel:** Select code → click **Explain**

**From the Addins menu:** Addins → rviber: Explain Selected Code

**From the console:**
```r
# Explain selected code in editor
rviber_explain()

# Or pass code directly
rviber_explain(code = "df %>% group_by(region) %>% summarise(total = sum(sales))")
```

The explanation covers what the code does step by step, any potential issues, and suggested improvements.

---

## 3. Fix Bugs

Select broken R code and let the AI find and fix all errors. The corrected code is automatically inserted back into the editor.

**From the panel:** Select code → click **Fix bugs**

**From the Addins menu:** Addins → rviber: Fix Bugs in Selection

**From the console:**
```r
# Fix selected code
rviber_fix()

# Fix with error message for better context
rviber_fix(
  code  = "ggplot(df) + geom_pont(aes(x = wt, y = mpg))",
  error = "could not find function 'geom_pont'"
)
```

---

## 4. Improve / Refactor

Select code and get a cleaner, more idiomatic R version — better readability, tidyverse style, comments added.

**From the panel:** Select code → click **Improve**

**From the Addins menu:** Addins → rviber: Improve Selected Code

**From the console:**
```r
rviber_improve(code = "
result = c()
for(i in 1:nrow(df)) {
  if(df[i, 'score'] > 80) {
    result = c(result, df[i, 'name'])
  }
}
")
# Returns: df %>% filter(score > 80) %>% pull(name)
```

---

## 5. Autocomplete

Let the AI continue your code from where you left off. The completion is inserted at the cursor.

**From the panel:** Click **Complete**

**From the Addins menu:** Addins → rviber: Complete My Code

**From the console:**
```r
rviber_complete()   # reads the full document automatically
```

Works best when you have a few lines of context — the AI sees your whole document and continues naturally.

---

## 6. Generate Code from English

Describe what you want in plain English and get working R code, ready to run.

**From the panel:** Go to the **Generate** tab → describe → click Generate Code

**From the Addins menu:** Addins → rviber: Generate Code from Description (opens an input dialog)

**From the console:**
```r
rviber_generate("Read all CSV files in a folder, bind them into one dataframe, and remove duplicate rows")

rviber_generate("Create a function that validates email addresses using regex")

rviber_generate("Fit a linear model of price ~ sqft + bedrooms, check assumptions, and plot residuals")

# Insert directly into the editor
rviber_generate("calculate rolling 7-day average of daily sales", insert = TRUE)
```

---

## 7. Generate ggplot2 Charts

Describe a chart in plain English and get complete, publication-ready ggplot2 code — with proper theme, labels, title, and colour palette.

**From the panel:** Go to the **Plot** tab → describe → select data frame → click Generate

**From the Addins menu:** Addins → rviber: Generate ggplot2 Chart

**From the console:**
```r
rviber_plot("Scatter plot of mpg vs wt from mtcars, coloured by number of cylinders, with a smooth trend line")

rviber_plot("Bar chart of mean sepal length per species from the iris dataset, sorted descending, viridis palette")

rviber_plot(
  description = "Distribution of departure delays by carrier",
  data_name   = "flights",   # rviber inspects the dataframe structure automatically
  insert      = TRUE
)
```

---

## 8. Run & Debug

Select code, run it in a safe environment, and get AI help understanding the output or fixing errors.

**From the panel:** Select code → click **Run+Debug**

**From the console:**
```r
result <- rviber_run_debug(code = "
x <- c(1, 2, NA, 4, 5)
mean(x)
summary(x)
")

cat(result$output)        # execution output
cat(result$ai_response)   # AI explanation of the output
```

---

## All features at a glance

| Feature | Panel button | Addins menu | Console function |
|---------|-------------|-------------|-----------------|
| Chat | Chat box | — | `rviber_chat()` |
| Explain | Explain | rviber: Explain | `rviber_explain()` |
| Fix bugs | Fix bugs | rviber: Fix Bugs | `rviber_fix()` |
| Improve | Improve | rviber: Improve | `rviber_improve()` |
| Autocomplete | Complete | rviber: Complete | `rviber_complete()` |
| Generate code | Generate tab | rviber: Generate | `rviber_generate()` |
| Generate chart | Plot tab | rviber: Generate Plot | `rviber_plot()` |
| Run & debug | Run+Debug | — | `rviber_run_debug()` |
| Setup | Settings tab | rviber: Setup | `rviber_setup()` |
| Switch provider | Settings tab | — | `set_provider()` |
