# Using the Panel

The rviber panel is a Shiny app that runs inside RStudio. It has 4 tabs.

## Opening the panel

```r
rviber_addin()
# or: Addins menu → rviber: Open AI Assistant
```

**Panel mode vs dialog mode:**
- **Side panel** (default) — opens in RStudio's Viewer pane on the right
- **Floating window** — opens as a separate dialog box

Switch between modes in the Settings tab, or:

```r
rviber_addin(mode = "dialog")   # floating window
rviber_addin(mode = "viewer")   # side panel
```

---

## Tab 1 — Chat

The main chat interface.

### Action buttons

At the top of the Chat tab are 6 quick-action buttons. They all work on your **currently selected code** in the editor:

| Button | What it does |
|--------|-------------|
| **Explain** | Explains the selected code in plain English |
| **Fix bugs** | Fixes errors in selected code and replaces it in the editor |
| **Improve** | Refactors selected code to be cleaner and more idiomatic |
| **Complete** | Continues your code from where you left off |
| **Run+Debug** | Executes selected code and explains the output |
| **Clear** | Clears the chat history |

### Chat box

Type any question or instruction and press **Send** (or **Ctrl+Enter** / **Cmd+Enter**).

Examples:
```
How do I reshape a wide dataframe to long format with tidyr?
What does this warning mean: NAs introduced by coercion?
Write a function that validates email addresses
Can you review this code for performance issues?
```

### Provider badge

The header shows your current provider and model, e.g. `Groq / llama-3.3-70b-versatile`. Click the Settings tab to change it.

---

## Tab 2 — Generate

Generate complete R code from a plain English description.

1. Type a description of what you want
2. Check **Insert code into editor** if you want it pasted at your cursor
3. Click **Generate Code**

**Example descriptions:**
```
Read all .csv files from the "data/" folder, combine them into one dataframe,
remove duplicate rows, and save the result as "combined.csv"

Create a function called clean_names() that converts column names to snake_case,
removes special characters, and replaces spaces with underscores

Fit a logistic regression model predicting churn from age, tenure and monthly_charges,
show the summary and plot the ROC curve
```

The generated code includes all necessary `library()` calls and comments.

---

## Tab 3 — Plot

Generate ggplot2 chart code from a plain English description.

1. Describe the chart you want
2. Optionally select a **data frame** from the dropdown — rviber will inspect its columns automatically
3. Check **Insert code into editor**
4. Click **Generate Plot Code**

**Example descriptions:**
```
A violin plot of petal length by species from the iris dataset,
filled by species using the viridis palette, with jittered points overlaid

A faceted bar chart of mean sales by product category,
one facet per region, sorted by sales descending, clean minimal theme

A heatmap of correlation between all numeric columns in mtcars,
with values displayed inside each cell
```

The generated code always uses ggplot2, applies a clean theme, and includes proper axis labels, title, and caption.

---

## Tab 4 — Settings

Configure your AI provider, model, and panel behaviour.

### Provider section

- **Provider** dropdown — switch between Groq, Gemini, OpenAI, Anthropic, Ollama, etc.
- **Model** dropdown — updates automatically when you change provider
- **API Key** field — paste your key here (saved to `~/.rviber/config.json`)
- **Custom endpoint URL** — for Ollama or self-hosted models (e.g. `http://localhost:11434/v1`)

### Behaviour section

- **Temperature** — controls creativity. Lower (0.1–0.3) = more precise code. Higher (0.7–1.0) = more creative responses
- **Max tokens** — maximum length of AI responses. 2048 is fine for most tasks; increase for long code generation
- **Panel mode** — Side panel (Viewer pane) or Floating window

Click **Save Settings** to apply. The provider badge in the header updates immediately.

---

## Tips

- **Ctrl+Enter** in the chat box sends the message — you don't need to click Send
- If the AI writes code with a code fence (```r ... ```), you can copy it directly or use the **Fix** / **Improve** buttons to work on it further
- The chat history persists within a session — if you want a fresh start, click **Clear**
- You can have the panel open while editing code — select text in the editor and click the action buttons at any time
