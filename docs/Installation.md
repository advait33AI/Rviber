# Installation

## Requirements

- **R 4.1+**
- **RStudio 1.4+** (for the Addin and panel features)
- An API key from any supported provider — or Ollama for 100% local use

---

## Install from GitHub

```r
# Install devtools if you don't have it
install.packages("devtools")

# Install rviber
devtools::install_github("yourusername/rviber")
```

## Install dependencies manually (if needed)

rviber depends on these packages — they are installed automatically, but if anything fails:

```r
install.packages(c(
  "shiny", "miniUI", "rstudioapi",
  "httr2", "jsonlite", "glue",
  "cli", "htmltools", "shinyjs", "later"
))
```

---

## Verify the install

```r
library(rviber)
# Should load silently with no errors

# Check available providers
get_providers()
```

---

## First-time setup

Run the setup wizard — it only takes 30 seconds:

```r
rviber_setup()
```

You will be asked to:
1. Pick a provider (Groq, Gemini, OpenAI, Anthropic, Ollama, etc.)
2. Paste your API key (or press Enter for Ollama — no key needed)
3. Pick a default model

Your settings are saved to `~/.rviber/config.json` and persist across R sessions.

---

## After setup — open the assistant

```r
rviber_addin()
```

Or go to **Addins menu → rviber: Open AI Assistant**

---

## Updating rviber

```r
devtools::install_github("yourusername/rviber")
```

---

## Uninstall

```r
remove.packages("rviber")

# Optionally remove saved config
unlink("~/.rviber", recursive = TRUE)
```
