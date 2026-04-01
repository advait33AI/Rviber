# Providers & API Keys

rviber supports every major LLM provider. You can switch provider anytime — in the Settings tab, with `set_provider()`, or by re-running `rviber_setup()`.

---

## Provider overview

| Provider | Free tier | Speed | Best for |
|----------|-----------|-------|----------|
| **Groq** | Yes — generous | Fastest | Default, everyday coding |
| **Google Gemini** | Yes — Flash model | Fast | Free alternative to OpenAI |
| **Ollama** | Always free | Medium | Privacy, no internet needed |
| **OpenAI** | No | Fast | GPT-4o quality |
| **Anthropic** | No | Fast | Claude quality |
| **Mistral** | Limited | Fast | European alternative |
| **Together AI** | Pay-per-use | Fast | Open source models |
| **Custom** | Varies | Varies | Self-hosted, LM Studio, vLLM |

---

## Groq — recommended for beginners

Fast inference, generous free tier, no credit card required.

**Get a key:** [console.groq.com](https://console.groq.com) → Sign up → API Keys → Create API Key

```r
set_provider("groq", model = "llama-3.3-70b-versatile")
```

Available models:
- `llama-3.3-70b-versatile` — best quality (recommended)
- `llama-3.1-8b-instant` — fastest, good for quick tasks
- `mixtral-8x7b-32768` — long context window
- `gemma2-9b-it` — Google's open model

---

## Google Gemini — free alternative

Flash model is free. Good quality for code tasks.

**Get a key:** [aistudio.google.com](https://aistudio.google.com) → Get API key

```r
set_provider("gemini", model = "gemini-2.0-flash")
```

Available models:
- `gemini-2.0-flash` — free, fast
- `gemini-1.5-pro` — higher quality, usage limits apply
- `gemini-1.5-flash` — balanced

---

## OpenAI

Best overall quality. Requires payment after free trial.

**Get a key:** [platform.openai.com](https://platform.openai.com) → API keys → Create new secret key

```r
set_provider("openai", model = "gpt-4o")
```

Available models:
- `gpt-4o` — best quality
- `gpt-4o-mini` — cheaper, still very good
- `gpt-4-turbo` — long context

---

## Anthropic Claude

Strong at code explanation and reasoning.

**Get a key:** [console.anthropic.com](https://console.anthropic.com) → API Keys

```r
set_provider("anthropic", model = "claude-opus-4-5")
```

Available models:
- `claude-opus-4-5` — most capable
- `claude-sonnet-4-5` — balanced
- `claude-haiku-4-5` — fastest, cheapest

---

## Ollama — 100% local, free forever

Runs entirely on your machine. No API key. No internet. Nothing leaves your computer.

**Install Ollama:** [ollama.ai](https://ollama.ai)

```bash
# In your terminal — pull a model (one time)
ollama pull codellama       # good for R/code
ollama pull llama3          # general purpose
ollama pull deepseek-coder  # specialist code model
ollama pull phi3            # small and fast

# Start the server (keep this running)
ollama serve
```

```r
set_provider("ollama", model = "codellama")
rviber_addin()
```

> Ollama is ideal when you want privacy — your R code and data never leave your machine.

---

## Mistral AI

```r
set_provider("mistral", model = "mistral-large-latest")
```

**Get a key:** [console.mistral.ai](https://console.mistral.ai)

---

## Together AI

Access many open-source models.

```r
set_provider("together", model = "meta-llama/Llama-3-70b-chat-hf")
```

**Get a key:** [api.together.xyz](https://api.together.xyz)

---

## Custom / self-hosted

Works with any OpenAI-compatible endpoint — LM Studio, vLLM, text-generation-webui, etc.

```r
# LM Studio (local, no key needed)
# Download: https://lmstudio.ai — load a model → click Start Server

set_provider("custom")

# Then in the Settings tab:
# Custom endpoint URL: http://localhost:1234/v1
# API Key: (leave blank)
# Model: local-model
```

---

## Setting your API key

### Option 1 — rviber_setup() wizard (easiest)

```r
rviber_setup()
# Follow the prompts — key is saved to ~/.rviber/config.json
```

### Option 2 — Settings tab in the panel

Open the panel → Settings tab → paste key → Save Settings

### Option 3 — Environment variables (most secure)

Add to `~/.Renviron`:

```
GROQ_API_KEY="gsk_..."
GEMINI_API_KEY="AIza..."
OPENAI_API_KEY="sk-..."
ANTHROPIC_API_KEY="sk-ant-..."
MISTRAL_API_KEY="..."
TOGETHER_API_KEY="..."
```

Then restart R. rviber reads these automatically — no key stored in config.

**Edit `.Renviron` easily:**
```r
usethis::edit_r_environ()
# Add your keys, save, restart R
```

### Option 3 — Direct in R session (temporary)

```r
Sys.setenv(GROQ_API_KEY = "gsk_...")
# Only lasts for the current R session
```

---

## Switching providers

Switch anytime — mid-session, between projects, or from within the panel:

```r
# From the console
set_provider("groq",      model = "llama-3.3-70b-versatile")
set_provider("gemini",    model = "gemini-2.0-flash")
set_provider("openai",    model = "gpt-4o")
set_provider("anthropic", model = "claude-opus-4-5")
set_provider("ollama",    model = "codellama")

# Or just pick the provider — rviber uses the first model automatically
set_provider("groq")
```

From the **Settings tab** in the panel: use the Provider and Model dropdowns → click Save Settings. The badge in the panel header updates immediately.

---

## Adding a new provider

rviber supports any OpenAI-compatible API. To add a provider that isn't listed:

```r
library(rviber)

register_provider(
  id       = "my_provider",
  name     = "My Provider",
  base_url = "https://api.myprovider.com/v1",
  models   = c("my-model-v1", "my-model-v2"),
  key_env  = "MY_PROVIDER_API_KEY"
)

set_provider("my_provider", model = "my-model-v1")
```
