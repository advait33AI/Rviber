# rviber 🤖

**An AI vibe coder built into RStudio.** Chat, generate, fix, explain, complete, and plot R code, powered by Groq, Gemini, OpenAI, Anthropic, Ollama, or any provider. Everything happens inside RStudio without leaving your editor.

[![R-CMD-check](https://github.com/yourusername/rviber/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/yourusername/rviber/actions)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)
[![R 4.1+](https://img.shields.io/badge/R-4.1%2B-blue.svg)](https://cran.r-project.org/)

---

## What is rviber?

rviber is an R package that puts an AI coding assistant directly inside RStudio. Select code, click a button, and the AI explains it, fixes it, or improves it, right in your editor. Type in plain English and get complete R scripts back. Describe a chart and get ggplot2 code.

It works as three things at once:
- An **RStudio Addin** — 8 actions in the Addins menu
- An **R Package** — all features callable from the R console
- A **Shiny Panel** — a full chat UI with Chat, Generate, Plot, and Settings tabs

```
You select buggy R code → click "Fix bugs" → AI fixes it → code replaced in editor
You type "bar chart of sales by region" → click Generate → ggplot2 code inserted at cursor
You ask "how do I use purrr::map2?" → AI explains with examples in the chat panel
```

---

## Features

| Feature | How to trigger |
|---------|---------------|
| 💬 Chat with AI | Open panel → type anything |
| 🔍 Explain selected code | Select → Addins → Explain |
| 🐛 Fix bugs | Select → Addins → Fix Bugs |
| ✨ Improve / refactor | Select → Addins → Improve |
| ⚡ Autocomplete | Addins → Complete My Code |
| 📝 Generate from English | Addins → Generate Code |
| 📊 Generate ggplot2 charts | Addins → Generate Plot |
| 🏃 Run & debug | Select → Addins → Run+Debug |

---

## Installation

```r
install.packages("devtools")
devtools::install_github("yourusername/rviber")
```

---

## Quick Start (2 minutes)

**Step 1 — Run the setup wizard**

```r
library(rviber)
rviber_setup()
```

Pick a provider, paste your API key. Groq is recommended — it's free and fastest.

**Step 2 — Open the assistant**

```r
rviber_addin()
# or: Addins menu → rviber: Open AI Assistant
```

**Step 3 — Start vibe coding**

- Type a question in the chat box
- Select R code in your editor → click **Explain**, **Fix**, or **Improve**
- Go to the **Generate** tab → describe what you want → code appears at your cursor

---

## Supported Providers

| Provider | Free tier | Notes |
|----------|-----------|-------|
| **Groq** | ✅ Generous | Fastest. Recommended default. [console.groq.com](https://console.groq.com) |
| **Google Gemini** | ✅ Flash model | [aistudio.google.com](https://aistudio.google.com) |
| **Ollama** | ✅ Always | 100% local. No internet. No key. [ollama.ai](https://ollama.ai) |
| **OpenAI** | ❌ | GPT-4o, GPT-4o-mini |
| **Anthropic** | ❌ | Claude models |
| **Mistral** | Limited | [console.mistral.ai](https://console.mistral.ai) |
| **Together AI** | Pay-per-use | Open source models |
| **LM Studio** | ✅ Always | Local GUI. [lmstudio.ai](https://lmstudio.ai) |
| **Custom** | — | Any OpenAI-compatible URL |

Switch anytime:
```r
set_provider("groq",   model = "llama-3.3-70b-versatile")
set_provider("gemini", model = "gemini-2.0-flash")
set_provider("ollama", model = "codellama")
```

---

## Using Ollama — 100% Local, Free Forever

No API key. No internet. Your code never leaves your machine.

```bash
# Terminal — install Ollama and pull a model
curl -fsSL https://ollama.ai/install.sh | sh
ollama pull codellama
ollama serve
```

```r
# In R
set_provider("ollama", model = "codellama")
rviber_addin()
```

Best local models for R coding:
- `codellama` — best for R/code (4GB)
- `deepseek-coder` — excellent code quality (4GB)
- `qwen2.5-coder` — strong across languages (1.5–7GB)
- `phi3` — small and fast for low-RAM machines (2GB)

---

## Adding Any Custom Provider

Any OpenAI-compatible API works in one function call:

```r
# LM Studio (local, no key)
register_provider(
  id       = "lmstudio",
  name     = "LM Studio",
  base_url = "http://localhost:1234/v1",
  models   = c("local-model"),
  key_env  = "",
  auth_type = "none"
)
set_provider("lmstudio")

# Your company's internal LLM
register_provider(
  id       = "company_llm",
  name     = "Company LLM",
  base_url = "https://llm.mycompany.com/v1",
  models   = c("internal-model-v2"),
  key_env  = "COMPANY_LLM_KEY"
)
set_provider("company_llm")

# Together AI, Mistral, Anyscale, vLLM, Perplexity — same pattern
```

---

## Use from the R Console

Every feature works as a plain R function — no panel needed:

```r
# Chat
rviber_chat("What is the difference between lapply and purrr::map?")

# Explain code
rviber_explain(code = "df %>% group_by(region) %>% summarise(n = n())")

# Fix bugs
rviber_fix(code = "ggplot(df) + geom_pont(aes(x, y))")

# Generate code
rviber_generate("Read all CSV files in a folder and combine them into one dataframe")

# Generate a ggplot2 chart
rviber_plot("Scatter plot of mpg vs wt from mtcars, coloured by cyl")

# Autocomplete
rviber_complete()

# Run and debug
rviber_run_debug(code = "x <- c(1, NA, 3); mean(x)")
```

---

## Setting API Keys

**Best — add to `~/.Renviron` so keys load automatically:**

```r
usethis::edit_r_environ()
```

Add your keys:
```
GROQ_API_KEY="gsk_..."
GEMINI_API_KEY="AIza..."
OPENAI_API_KEY="sk-..."
ANTHROPIC_API_KEY="sk-ant-..."
```

Restart R. rviber reads these automatically.

**Or — paste in the Settings tab** of the rviber panel.

**Or — set in the R session (temporary):**
```r
Sys.setenv(GROQ_API_KEY = "gsk_...")
```

---

## Keyboard Shortcut

Bind rviber to a key:

**Tools → Modify Keyboard Shortcuts → search "rviber" → assign shortcut**

Recommended: `Ctrl+Shift+A` (Windows/Linux) or `Cmd+Shift+A` (Mac)

---

## How It Works

```
1. You select R code in the editor
        ↓
2. rstudioapi reads the selection
        ↓
3. rviber builds a prompt (e.g. "Fix this R code: ...")
        ↓
4. httr2 sends HTTP POST to the LLM API (Groq/Gemini/Ollama/...)
        ↓
5. AI responds with fixed/explained/generated code
        ↓
6. rstudioapi inserts the code back into your editor
```

Pure R. No Python. No Docker. No special tools. Just R making HTTP calls.

---

## Documentation

Full documentation is in the [GitHub Wiki](https://github.com/yourusername/rviber/wiki):

- [Installation](https://github.com/yourusername/rviber/wiki/Installation)
- [Quick Start](https://github.com/yourusername/rviber/wiki/Quick-Start)
- [All Features](https://github.com/yourusername/rviber/wiki/Features)
- [Providers & API Keys](https://github.com/yourusername/rviber/wiki/Providers-and-API-Keys)
- [Using the Panel](https://github.com/yourusername/rviber/wiki/Using-the-Panel)
- [Console Functions](https://github.com/yourusername/rviber/wiki/Console-Functions)
- [Configuration](https://github.com/yourusername/rviber/wiki/Configuration)
- [Contributing](https://github.com/yourusername/rviber/wiki/Contributing)

---

## Contributing

```r
devtools::install_github("yourusername/rviber")

# Development
devtools::load_all()   # load without installing
devtools::test()       # run tests
devtools::check()      # full R CMD CHECK
```

See [CONTRIBUTING.md](CONTRIBUTING.md) for how to add providers and features.

---

## License

MIT — see [LICENSE](LICENSE)
