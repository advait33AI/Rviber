# rviber — Documentation

> An AI vibe coder built into RStudio. Chat, generate, fix, explain, complete, and plot R code — powered by Groq, Gemini, OpenAI, Anthropic, Ollama, or any provider. All without leaving RStudio.

---

## Quick links

| | |
|--|--|
| [Installation](Installation) | Install rviber in RStudio |
| [Quick Start](Quick-Start) | Up and running in 2 minutes |
| [Features](Features) | Everything rviber can do |
| [Providers & API Keys](Providers-and-API-Keys) | Groq, Gemini, OpenAI, Anthropic, Ollama and more |
| [Using the Panel](Using-the-Panel) | Chat tab, Generate tab, Plot tab, Settings tab |
| [Console Functions](Console-Functions) | Use rviber from the R console |
| [Keyboard Shortcuts](Keyboard-Shortcuts) | Speed up your workflow |
| [Configuration](Configuration) | Customize rviber |
| [Contributing](Contributing) | Add providers or features |

---

## What is rviber?

rviber is an R package that puts an AI coding assistant directly inside RStudio. It works as three things at once:

- An **RStudio Addin** — appears in the Addins menu, opens as a side panel or floating window
- An **R Package** — all features callable as plain R functions from the console
- A **Shiny Dashboard** — a full chat UI with tabs for Chat, Generate, Plot, and Settings

```
RStudio Editor
      │
      │  select code → click Addin
      ▼
┌──────────────────────────────────┐
│  rviber AI Panel                 │
│                                  │
│  [Explain] [Fix] [Improve]       │
│  [Complete] [Run] [Clear]        │
│                                  │
│  Chat history...                 │
│  > explain this code             │
│  AI: This function takes...      │
│                                  │
│  Provider: Groq ▼  Model: ▼      │
│  ________________________________│
│  Type a message...               │
│                         [Send]   │
└──────────────────────────────────┘
      │
      │  AI response inserted back into editor
```

---

## Feature overview

| Feature | How to use |
|---------|-----------|
| Chat with AI | Open panel → type anything |
| Explain selected code | Select code → Addins → Explain |
| Fix bugs | Select code → Addins → Fix Bugs |
| Improve / refactor | Select code → Addins → Improve |
| Autocomplete | Addins → Complete My Code |
| Generate from English | Addins → Generate Code |
| Generate ggplot2 charts | Addins → Generate Plot |
| Run & debug | Select code → Addins → Run+Debug |

---

## 60-second start

```r
# Step 1 — install
install.packages("devtools")
devtools::install_github("yourusername/rviber")

# Step 2 — setup (pick provider + paste API key)
library(rviber)
rviber_setup()

# Step 3 — open the panel
rviber_addin()
# or: Addins menu → rviber: Open AI Assistant
```

---

## Supported providers

| Provider | Free tier | Notes |
|----------|-----------|-------|
| Groq | Yes (generous) | Fastest, recommended default |
| Google Gemini | Yes | Flash model is free |
| OpenAI | No | GPT-4o, GPT-4o-mini |
| Anthropic | No | Claude models |
| Mistral | Limited | European alternative |
| Together AI | Pay-per-use | Open source models |
| Ollama | Always free | 100% local, no internet |
| Custom | Optional | Any OpenAI-compatible URL |
