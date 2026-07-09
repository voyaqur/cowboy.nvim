# 🤠 cowboy.nvim
**cowboy.nvim** is a simple yet extensible muscle-memory training Neovim plugin with an aim to break your bad habits. For instance, just do `10j` intead of pressing `j` 10 times continuously.

## Features
- **Rate-limiting:** break your bad habits by throttling rapid, repetitive keypresses when they cross your designed threshold.
- **Extensibility:** Organize your rules cleanly into semantic groups with ease, allowing multiple sets of keystrokes with different threshold and timeout.

## Installation
Use your favorite package manager, native Neovim's package manager as an example:

### Native (`vim.pack`)
```lua
vim.pack.add({ src = "https://github.com/voyaqur/cowboy.nvim", name = "cowboy.nvim" })
```

## Configuration
You can customize or extend the enforcement engine by defining distinct tracking rules inside the `groups` table. 

* **`group_name`**: *(string)* A unique identifier for your rule set (e.g., `navigation`, `window_jumps`).
* **`keys`**: *(string[])* A list of targeted key sequences or chords to intercept and rate-limit.
* **`threshold`**: *(number)* The maximum number of consecutive, prefix-free presses allowed before the key is blocked.
* **`timeout`**: *(number)* The rolling time window (in milliseconds) required to reset the spam counter.
* **`callback`**: *(function|nil)* *Optional.* A custom execution handler `fun(key: string, count: number): boolean?`. Return `true` to block the keystroke, or `false`/`nil` to pass it through.

*Default Configuration:*

```lua
require('cowboy').setup({
    enabled = true,
    groups = {
        navigation = {
            keys = { "h", "j", "k", "l", "+", "-" },
            threshold = 10,
            timeout = 2000,
        },
    },
})
```
## Inspiration 
While searching for plugins to improve my setup, fix niche things, I stumbled upon a code snippet (`discipline.nvim`) from [craftzdog/dotfiles-public](https://github.com/craftzdog/dotfiles-public). Hence it gave me an idea to make this plugin to carry something powerful that can break my bad habits within my personal Neovim workflow with ease.

