# Configuration

rviber stores settings in `~/.rviber/config.json`. You never need to edit this file directly — use `rviber_setup()`, `set_provider()`, or the Settings tab in the panel.

---

## View current config

```r
rviber_config()
```

```
$provider
[1] "groq"

$model
[1] "llama-3.3-70b-versatile"

$temperature
[1] 0.3

$max_tokens
[1] 4096

$panel_mode
[1] "viewer"

$api_keys
$api_keys$groq
[1] "gsk_..."
```

---

## Change settings

```r
# Switch provider
set_provider("gemini", model = "gemini-2.0-flash")

# Change temperature (0 = precise, 1 = creative)
rviber_set_config(temperature = 0.7)

# Change max response length
rviber_set_config(max_tokens = 8192)

# Change panel mode
rviber_set_config(panel_mode = "dialog")   # floating window
rviber_set_config(panel_mode = "viewer")   # side panel
```

---

## API keys — all storage options

rviber checks for API keys in this order:

1. **Environment variable** — most secure, recommended
2. **`~/.rviber/config.json`** — saved by setup wizard or Settings tab
3. **R options** — set with `options(rviber.groq_key = "gsk_...")`

### Environment variables (recommended)

Edit `~/.Renviron`:

```r
usethis::edit_r_environ()
```

Add your keys:

```
GROQ_API_KEY="gsk_..."
GEMINI_API_KEY="AIza..."
OPENAI_API_KEY="sk-..."
ANTHROPIC_API_KEY="sk-ant-..."
MISTRAL_API_KEY="..."
TOGETHER_API_KEY="..."
```

Save and restart R. rviber picks these up automatically — nothing stored in config.

### Config file

Set via the Settings tab or:

```r
rviber_set_config(api_keys = list(groq = "gsk_..."))
```

Keys are stored in plaintext in `~/.rviber/config.json` — fine for personal machines, not for shared environments.

---

## Temperature guide

| Temperature | Best for |
|-------------|---------|
| 0.0 – 0.2 | Precise code generation, bug fixing |
| 0.3 – 0.5 | Balanced — good default |
| 0.6 – 0.8 | Creative writing, brainstorming |
| 0.9 – 1.0 | Maximum creativity (may be less accurate) |

---

## Config file location

```r
# View the config file path
file.path(Sys.getenv("HOME"), ".rviber", "config.json")

# View the file contents
jsonlite::read_json("~/.rviber/config.json")

# Delete config and start fresh
unlink("~/.rviber", recursive = TRUE)
rviber_setup()
```

---

## Per-call overrides

You can override the global provider/model for a single call:

```r
# Use a different provider just for this call
rviber_chat(
  "Explain this code",
  provider = "openai",
  model    = "gpt-4o"
)

# Use a faster model for a quick question
rviber_explain(
  provider = "groq",
  model    = "llama-3.1-8b-instant"
)
```
