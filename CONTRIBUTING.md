# Contributing to rviber

Thank you for your interest!

## Development Setup

```r
# Clone the repo, then in RStudio:
install.packages("devtools")
devtools::install_deps()
devtools::load_all()   # load without installing — fast dev cycle
```

## Adding a New LLM Provider

One function call in `R/providers.R`:

```r
register_provider(
  id       = "my_provider",
  name     = "My Provider",
  base_url = "https://api.myprovider.com/v1",
  models   = c("my-model-large", "my-model-small"),
  key_env  = "MY_PROVIDER_API_KEY"
)
```

If the provider is NOT OpenAI-compatible, add a custom handler in `llm_chat()` (like the Anthropic case).

## Running Tests

```r
devtools::test()
```

## Checking the Package

```r
devtools::check()   # full R CMD CHECK
devtools::document() # regenerate docs from roxygen
```

## PR Guidelines

- Keep PRs focused
- Add tests for new features
- Run `devtools::check()` before opening a PR — no ERRORs or WARNINGs
- Update `NEWS.md` with your change
