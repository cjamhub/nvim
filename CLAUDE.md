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

- **LSP setup uses the core `vim.lsp.config`/`vim.lsp.enable` API, not `lspconfig.SERVER.setup()`.** The installed `mason-lspconfig` no longer supports the old `handlers` table at all (it's silently ignored — confirmed by reading its source); `require('lspconfig').SERVER.setup()` still works but is deprecated and prints a warning. `lsp-and-completion.lua` sets shared capabilities via `vim.lsp.config('*', {...})`, then customizes `pyright`/`ruff`/`solidity_ls` via `vim.lsp.config(name, {...})` + `vim.lsp.enable(name)`. `lua_ls`/`gopls`/`ts_ls` are left to `mason-lspconfig`'s `automatic_enable`.
- **`automatic_enable` auto-enables any server whose Mason binary is present, independent of `ensure_installed`.** This bit us twice: it auto-enabled `rust_analyzer` solely because `mason-tool-installer` fetches the `rust-analyzer` binary for rustaceanvim, and separately auto-enabled `solidity_ls_nomicfoundation` because that binary happened to already be installed on a dev machine — both produced a duplicate, misconfigured LSP client alongside the intended one. Both are explicitly excluded via `automatic_enable = { exclude = {...} }`. If a duplicate/misconfigured client shows up for a new server, check this list first.
- **Rust is not wired through mason-lspconfig at all.** `mrcjkb/rustaceanvim` is its own plugin entry (configured via `vim.g.rustaceanvim`), owns workspace/root detection itself, and needs `check = { command = "clippy" }` (not the older `checkOnSave = { command = ... }` shape — that now errors on current rust-analyzer, which wants `checkOnSave` as a plain boolean).
- **Solidity testing bypasses vim-test.** `lua/plugins/vim-test.lua` declares a custom `forge` runner but the `<leader>t` keymap dispatches on filetype and calls `run_solidity_test` directly for Solidity. It greps the buffer for `contract X is` / `function Y` and runs `forge test --match-test` or `--match-contract` in a terminal split. Editing the test keymap means updating the filetype dispatcher, not vim-test config.
- **Solidity remappings are detected at runtime.** `solidity_ls`'s `on_init` shells out to `forge remappings` in `client.root_dir` and pushes the result via `workspace/didChangeConfiguration` — nothing is hardcoded to a specific library, so it works across foundry projects with different dependencies. `cmd`/`filetypes`/root markers are left to lspconfig's own default (`vscode-solidity-server`) — don't hardcode `cmd` here, it drifts from whatever binary Mason actually installs (this broke once already).
- **Go test env loading.** When the buffer is under a `go.mod`, the test runner `lcd`s into that directory and, if `.env` exists, prepends `set -a; . ./.env; set +a;` to the test executable. The README mentions `.env.test`, but the code reads `.env` — trust the code.
- **Python lint/format is ruff, type-checking is pyright.** `conform.nvim` formats Python with `ruff_format` on save; the `ruff` LSP config disables its own `hoverProvider` in `on_attach` so pyright's hover wins, avoiding duplicate hover popups. `black` is intentionally not installed anymore.
- **`<leader>t` and `<leader>tt` share a prefix.** vim-test's "run nearest test" is bound to `<leader>t`; neorg's daily-journal shortcut is `<leader>tt`. Pressing `<leader>t` alone waits out `timeoutlen` before firing, since Neovim has to see whether a second `t` is coming. This is expected, not a bug.
- **Personal/machine-specific config goes in `lua/personal/`** (gitignored). `lua/plugins/telescope.lua` does `pcall(require, "personal.telescope")` for project base directories — absence is silently tolerated. Use the same `pcall` pattern when adding other host-specific overrides.
- **`lazy-lock.json` is tracked** (since the "chore: track lazy-lock.json" commit) — it's the version pin, commit it along with plugin changes. The `lazy.nvim` checker runs daily (`frequency = 86400`).

## Formatting

`conform.nvim` (`lua/plugins/formatting.lua`) formats on save (`timeout_ms = 500`, `lsp_fallback = true`). Formatters by filetype: `stylua` (lua), `gofmt -s` (go), `rustfmt` (rust), `ruff_format` (python), `forge fmt --raw -` (solidity), `prettier` (json/js/ts/jsx/tsx). Manual: `<leader>f`. Lua files in this repo use **tabs** (`shiftwidth=4`, `tabstop=4`, no `expandtab`) — stylua respects that; preserve it when hand-editing.

## Conventions and gotchas

- `.gitignore` excludes: `db-connections.lua`, `lua/personal/`, `.env*` (except `.env.example`), `*soljson-latest.js`, `TODO.md`, `NOTES.md`. `lazy-lock.json` is deliberately not in this list (see below). `db-connections.lua` doesn't currently exist in the repo (tracked or otherwise) — it's just a reserved filename for whenever local DB config gets added.
- Mason-managed LSP servers (via `mason-lspconfig` `ensure_installed`): `lua_ls`, `gopls`, `solidity_ls`, `ts_ls`, `pyright`, `ruff`. Rust is handled separately by `rustaceanvim` — don't add `rust_analyzer` back to this list. Mason tool-installer also fetches `stylua`, `prettier`, `rust-analyzer`. To add a plain server, just append to `ensure_installed` (it'll auto-enable via `automatic_enable`); to add one needing custom `vim.lsp.config(...)`, add it to `automatic_enable`'s `exclude` list too (see above) so it isn't double-enabled.
- `<leader>` is space. `<localleader>` is also space. The test keymap is `<leader>t` (run nearest test) — no separate comma-prefixed bindings.
- `.luarc.json` points lua-ls at `~/.local/share/nvim/lazy` so plugin Lua resolves during editing.

## Current plugin scope (post-cleanup)

After the September 2026 trim, the active plugin set is intentionally minimal — no AI plugins, no inline terminal, no full git porcelain (use external `git`), no debugger. If a request implies a feature outside this set, ask before re-adding rather than assuming. Remaining plugins by file in `lua/plugins/`:

- `lsp-and-completion.lua` — mason, nvim-lspconfig, `rustaceanvim` (Rust), `blink.cmp` completion engine
- `treesitter.lua`, `autopairs.lua`, `formatting.lua` (conform)
- `telescope.lua` (+ fzf-native, project), `hop.lua`
- `gitsigns.lua` (gutter hunks), `diffview.lua` (review diffs)
- `vim-test.lua` — Go/Python/Rust/Solidity, single `<leader>t` keymap
- `neorg.lua` (daily-journal draft only), `markdown-preview.lua`
- `colourscheme.lua` (nord only)

## README

The repository's `README.md` is the user-facing docs (keymaps, setup, troubleshooting). When changing user-visible behavior — keymaps, plugin choices, supported languages — update the relevant `README.md` section too.
