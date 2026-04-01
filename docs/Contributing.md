# Contributing

Thank you for your interest in contributing to rviber!

---

## Development setup

```r
# Clone the repo
# Then in RStudio, open rviber.Rproj

install.packages("devtools")
devtools::install_deps()    # install all dependencies
devtools::load_all()        # load without installing — fast dev cycle
```

Changes to R files take effect immediately after `devtools::load_all()` — no reinstall needed.

---

## Running tests

```r
devtools::test()
```

---

## Checking the package

```r
devtools::check()    # full R CMD CHECK — must pass before a PR
devtools::document() # regenerate docs from roxygen comments
```

---

## Adding a new LLM provider

One function call in `R/providers.R`:

```r
register_provider(
  id       = "my_provider",
  name     = "My Provider",
  base_url = "https://api.myprovider.com/v1",
  models   = c("my-model-large", "my-model-small"),
  key_env  = "MY_PROVIDER_API_KEY"  # env var name for the API key
)
```

If the provider is **not OpenAI-compatible** (different request format), add a custom handler in `R/providers.R` inside `llm_chat()` — follow the Anthropic example already there.

Then:
- Add the provider to the table in the [Providers & API Keys](Providers-and-API-Keys) wiki page
- Add a test in `tests/testthat/test-providers.R`

---

## Adding a new feature

1. Add the R function in `R/actions.R`
2. Add the system prompt in `R/prompts.R`
3. Wire it up in the panel UI in `R/ui.R` and `R/server.R`
4. Register the addin in `inst/rstudio/addins/addins.dcf`
5. Export from `NAMESPACE` (or add `@export` roxygen tag and run `devtools::document()`)
6. Add tests in `tests/testthat/`
7. Document in `man/` (via roxygen) and in the wiki

---

## PR checklist

Before opening a pull request:

- [ ] `devtools::check()` passes — no ERRORs, no WARNINGs
- [ ] `devtools::test()` passes
- [ ] New feature has tests
- [ ] New public functions have roxygen documentation
- [ ] `NEWS.md` updated with a brief description of the change
- [ ] Wiki updated if you changed public API or added a feature

---

## Code style

- Use base R or tidyverse — avoid heavy dependencies
- roxygen2 for all exported functions
- `snake_case` for function names
- Keep functions focused — one function, one job

---

## Reporting bugs

Open an issue at [github.com/yourusername/rviber/issues](https://github.com/yourusername/rviber/issues)

Include:
- R version (`R.version.string`)
- rviber version (`packageVersion("rviber")`)
- RStudio version
- Provider and model you were using
- Steps to reproduce
- Error message or unexpected behaviour
