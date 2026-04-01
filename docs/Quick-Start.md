# Quick Start

## Step 1 — Install

```r
devtools::install_github("yourusername/rviber")
```

---

## Step 2 — Run the setup wizard

```r
library(rviber)
rviber_setup()
```

**Recommended for beginners: choose Groq.** It is free, fast, and requires only a free account at [console.groq.com](https://console.groq.com).

```
Available providers:
  [1] Groq                  ← pick this to start
  [2] Google Gemini
  [3] OpenAI
  [4] Anthropic Claude
  [5] Mistral AI
  [6] Together AI
  [7] Ollama (Local)
  [8] Custom / Self-hosted

Pick a provider (number): 1

Paste your Groq API key: gsk_...

Available models:
  [1] llama-3.3-70b-versatile   ← recommended
  [2] llama-3.1-8b-instant
  [3] mixtral-8x7b-32768

Pick a model (number): 1

✓ rviber configured: Groq / llama-3.3-70b-versatile
```

---

## Step 3 — Open the assistant

```r
rviber_addin()
```

Or click **Addins → rviber: Open AI Assistant** in the RStudio menu bar.

The panel opens in RStudio's Viewer pane on the right side.

---

## Step 4 — Try it out

**Chat:**
Type anything in the chat box and press Send (or Ctrl+Enter):
```
> How do I read all CSV files in a folder and combine them into one dataframe?
```

**Explain code:**
1. Write or open any R script
2. Select some code with your mouse
3. Click the **Explain** button in the panel
4. The AI explains the selected code

**Fix a bug:**
1. Select code that has an error
2. Click **Fix bugs**
3. The AI fixes it and inserts the corrected version back into your editor

**Generate code:**
1. Go to the **Generate** tab
2. Type: `Read a CSV, remove NA rows, group by category and sum sales`
3. Click Generate — the code appears in your editor

---

## Step 5 — Try with your own data

```r
# Load a dataset
data(mtcars)

# Open the panel and go to the Plot tab
rviber_addin()

# In the Plot tab:
# Data frame: mtcars
# Description: scatter plot of mpg vs wt coloured by number of cylinders
# → click Generate Plot Code
# → code is inserted into your editor
# → run it to see the chart
```

---

## What next?

- [Features](Features) — full list of everything rviber can do
- [Providers & API Keys](Providers-and-API-Keys) — switch providers, add keys
- [Using the Panel](Using-the-Panel) — detailed guide to each tab
- [Console Functions](Console-Functions) — use rviber without the panel
