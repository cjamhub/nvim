# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this is

A personal Neovim config managed with [lazy.nvim](https://github.com/folke/lazy.nvim). There is no build, lint, or test command — changes are validated by reloading Neovim. Plugin specs live under `lua/plugins/`; each file `return`s a lazy.nvim spec table and is auto-imported by `lua/config/lazy.lua` (`{ import = "plugins" }`). Adding a new file under `lua/plugins/` is enough to register a plugin; no manifest edit needed.

## Entry points and load order

`init.lua` sets leader keys, global options, then calls in order:

1. `require("config.lazy")` — bootstraps lazy.nvim and imports every spec under `lua/plugins/`.
2. `require("config.python-venv")` — installs the `DirChanged` autocmd that re-points pyright at the correct venv when `cwd` changes.
3. `require("config.diagnostics")` — global `vim.diagnostic.config` (no virtual text; floats on `CursorHold` after 300ms).

Colorscheme (`nord`) is set in `init.lua`, **not** in `lua/plugins/colourscheme.lua` — that plugin file only installs themes.

## Shared utilities — read before editing

`lua/utils/python.lua` (`is_poetry_project`, `get_poetry_venv`, `find_venv`) is the **single source of truth** for Python environment detection. It is consumed by two unrelated subsystems that must stay aligned:

- `lua/plugins/lsp-and-completion.lua` → `pyright.before_init` (sets `pythonPath` or `venvPath`/`venv`).
- `lua/plugins/vim-test.lua` → `setup_python_test` (sets `g:test#python#pytest#executable`).
- `lua/config/python-venv.lua` → `update_pyright_venv` (live-switches the running pyright client via `workspace/didChangeConfiguration`).

`find_venv` returns either an **absolute path** (Poetry, starts with `/`) or a **bare directory name** like `venv` (standard). Every caller branches on `result:match("^/")` — preserve that contract if you change the return shape.

## Non-obvious architectural details

- **Rust LSP root detection is custom.** `lspconfig.rust_analyzer` is set up inside its own `mason-lspconfig` handler with a hand-rolled `root_dir` that walks up looking for a `Cargo.toml` containing `[workspace]`. Don't replace it with `util.root_pattern("Cargo.toml")` — that breaks workspace members. Clippy runs on save via `checkOnSave.command = "clippy"`.
- **Solidity testing bypasses vim-test.** `lua/plugins/vim-test.lua` declares a custom `forge` runner but the `,t` / `,T` keymaps dispatch on filetype and call `run_solidity_test` directly. It greps the buffer for `contract X is` / `function Y` and runs `forge test --match-test` or `--match-contract` in a terminal split. Editing test keymaps means updating the filetype dispatcher, not vim-test config.
- **Go test env loading.** When the buffer is under a `go.mod`, the test runner `lcd`s into that directory and, if `.env` exists, prepends `set -a; . ./.env; set +a;` to the test executable. The README mentions `.env.test`, but the code reads `.env` — trust the code.
- **Personal/machine-specific config goes in `lua/personal/`** (gitignored). `lua/plugins/telescope.lua` does `pcall(require, "personal.telescope")` for project base directories — absence is silently tolerated. Use the same `pcall` pattern when adding other host-specific overrides.
- **`lazy-lock.json` is gitignored** (unusual for lazy.nvim repos). Don't try to commit a "version pin" — that's intentional. The `lazy.nvim` checker runs daily (`frequency = 86400`).

## Formatting

`conform.nvim` (`lua/plugins/formatting.lua`) formats on save (`timeout_ms = 500`, `lsp_fallback = true`). Formatters by filetype: `stylua` (lua), `gofmt -s` (go), `rustfmt` (rust), `forge fmt --raw -` (solidity), `prettier` (json/js/ts/jsx/tsx). Manual: `<leader>f`. Lua files in this repo use **tabs** (`shiftwidth=4`, `tabstop=4`, no `expandtab`) — stylua respects that; preserve it when hand-editing.

## Conventions and gotchas

- `.gitignore` excludes: `db-connections.lua`, `lua/personal/`, `lazy-lock.json`, `.env*` (except `.env.example`), `*soljson-latest.js`, `TODO.md`, `NOTES.md`. The repo currently ships a tracked `db-connections.lua` (added before the ignore rule); leave it alone unless explicitly asked.
- Mason-managed servers: `lua_ls`, `rust_analyzer`, `gopls`, `solidity_ls`, `ts_ls`, `pyright`. Mason tool-installer also fetches `stylua`, `prettier`, `delve`, `black`, `ruff`. To add a server, append to both lists — the default handler in `lsp-and-completion.lua` will wire it up unless you need a custom one (Rust, Solidity, Pyright are custom).
- `<leader>` is space. `<localleader>` is also space. Test keymaps use `,` (comma) as the prefix, not leader.
- `.luarc.json` points lua-ls at `~/.local/share/nvim/lazy` so plugin Lua resolves during editing.

## Current plugin scope (post-cleanup)

After the Nov 2026 trim, the active plugin set is intentionally minimal — no git plugins (use external `git` / `lazygit`), no AI plugins, no inline terminal. If a request implies these features, ask before re-adding rather than assuming. Remaining plugins by file in `lua/plugins/`:

- `lsp-and-completion.lua` — mason, nvim-lspconfig, nvim-cmp + sources, LuaSnip
- `treesitter.lua`, `autopairs.lua`, `formatting.lua` (conform)
- `telescope.lua` (+ fzf-native, project), `hop.lua`
- `vim-test.lua`, `nvim-dap.lua` (Go debug only)
- `neorg.lua`, `markdown-preview.lua`
- `colourscheme.lua` (nord only)

## README

The repository's `README.md` is the user-facing docs (keymaps, setup, troubleshooting). When changing user-visible behavior — keymaps, plugin choices, supported languages — update the relevant `README.md` section too.
