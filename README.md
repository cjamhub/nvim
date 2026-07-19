# My Neovim Configuration

A minimal Neovim configuration focused on Go / Python / Rust / Solidity / TypeScript development, with database and notes support.

## ✨ Features

### 🔧 Core
- **Plugin Manager**: [lazy.nvim](https://github.com/folke/lazy.nvim)
- **LSP**: Go, Python, Lua, Rust, TypeScript, Solidity support
- **Completion**: nvim-cmp with LSP, buffer, and path sources
- **Syntax Highlighting**: Treesitter

### 🧪 Testing & Debugging
- **Go Testing**: vim-test with automatic `go.mod` detection and `.env` loading
- **Python Testing**: pytest with automatic venv/Poetry detection
- **Solidity Testing**: Foundry `forge test` with contract/function matching
- **Debugging**: nvim-dap with Go debugging via Delve

### 📝 Notes & Docs
- **Neorg**: org-style notes with daily journal and task management
- **Markdown Preview**: browser preview with mermaid diagram support

### 🔍 Git Review
- **gitsigns.nvim**: gutter hunks, stage/reset/preview, blame
- **diffview.nvim**: full-screen diff for reviewing AI-generated changes or any commit

### 🎨 UI & Navigation
- **Telescope**: Fuzzy finder with project support
- **Hop**: Fast cursor movement
- **Color Scheme**: Nord

## 📦 Installation

### Prerequisites
```bash
# Install Neovim 0.10+
brew install neovim  # macOS
# or apt install neovim  # Linux

# Install Go debugger (for debugging support)
go install github.com/go-delve/delve/cmd/dlv@latest

# Install required tools
npm install -g prettier  # For formatting

# Python development (optional)
# Mason will install pyright (LSP), black (formatter), and ruff (linter)
# For Poetry support:
curl -sSL https://install.python-poetry.org | python3 -
```

### Setup
1. **Clone this configuration:**
   ```bash
   git clone <this-repo-url> ~/.config/nvim
   ```

2. **Start Neovim:**
   ```bash
   nvim
   ```
   Plugins will auto-install on first launch.

## ⚡ Key Bindings

### Testing
- `<leader>t` / `,t` - Run nearest test (Go/Python/Solidity)
- `<leader>T` / `,T` - Run all tests in file (Go/Python/Solidity)

### Debugging
- `<F5>` - Start/Continue debugging
- `<F10>` - Step over
- `<F11>` - Step into
- `<F12>` - Step out
- `<F7>` - Toggle debug UI
- `<leader>b` - Toggle breakpoint
- `<leader>B` - Conditional breakpoint
- `<leader>dr` - Open REPL
- `<leader>dt` - Terminate debug session
- `<leader>dgt` - Debug Go test at cursor
- `<leader>dgl` - Debug last Go test

### Navigation
- `<leader>ff` - Find files
- `<leader>fg` - Live grep
- `<leader>fb` - Find buffers
- `<leader>fh` - Help tags
- `<leader>fp` - Projects
- `<leader>f.` - Recent files
- `<leader>fc` - Diagnostics list
- `<C-s>` - Fuzzy find in current buffer
- `<leader><leader>` - Hop to word

### LSP
- `gd` - Go to definition
- `gD` - Go to declaration
- `gi` - Go to implementation
- `gr` - Find references
- `K` - Hover documentation
- `<leader>rn` - Rename symbol
- `<leader>ca` - Code actions

### Diagnostics
- `[d` / `]d` - Previous / next diagnostic
- `<leader>d` - Show diagnostic in float
- `<leader>q` - Open diagnostics list

### Formatting
- `<leader>f` - Format buffer (also runs automatically on save)

### Python Development
- `<leader>pv` - Refresh Python venv detection (manual)

### Git Review
- `]h` / `[h` - Next / previous hunk
- `<leader>hp` - Preview hunk
- `<leader>hs` / `<leader>hr` - Stage / reset hunk (works on visual range too)
- `<leader>hS` / `<leader>hR` - Stage / reset whole buffer
- `<leader>hu` - Undo last stage
- `<leader>hb` - Blame current line (full)
- `<leader>hB` - Toggle inline blame
- `<leader>hd` / `<leader>hD` - Diff against index / against HEAD~
- `ih` - Hunk text object (e.g. `vih`, `dih`)
- `<leader>gv` / `<leader>gV` - Open / close Diffview (working tree vs HEAD)
- `<leader>gh` / `<leader>gH` - File history (current file / all)

### Notes (Neorg)
- `<leader>tt` - Today's journal
- `<leader>ty` - Yesterday's journal
- `<leader>td` / `tu` / `th` / `tp` / `tc` / `ti` - Mark task done / undone / on-hold / pending / cancelled / important

### Markdown Preview
- `<leader>mp` - Start markdown preview in browser
- `<leader>ms` - Stop preview
- `<leader>mt` - Toggle preview

### Search and Replace Across Project
- `<leader>fg` - Search term across project
- `<C-q>` - Send Telescope results to quickfix
- `:cfdo %s/old/new/gc | update` - Replace with confirmation

## 🛠️ Project-Specific Features

### Python Development with Poetry

This configuration automatically detects and uses Poetry-managed virtual environments.

#### Initial Setup
1. **Install Poetry** (if not already installed):
   ```bash
   curl -sSL https://install.python-poetry.org | python3 -
   ```

2. **Configure Poetry** (optional - to create venv in project):
   ```bash
   poetry config virtualenvs.in-project true
   ```

#### Using Poetry Projects
1. **Create or activate Poetry environment**:
   ```bash
   cd your-poetry-project
   poetry install
   poetry shell
   ```

2. **Open Neovim**:
   ```bash
   nvim .
   ```

The configuration will automatically:
- Detect `pyproject.toml` with `[tool.poetry]` section
- Find Poetry's virtualenv using `poetry env info --path`
- Configure pyright LSP to use Poetry's Python interpreter
- Set up pytest to use Poetry's virtualenv

#### Python Virtual Environment Detection Priority
1. **Poetry projects**: Detected via `pyproject.toml` → uses `poetry env info`
2. **Standard venv**: If `$VIRTUAL_ENV` is set, uses that
3. **Local venv folders**: Searches for `venv/`, `.venv/`, `env/`, `.env/`
4. **Fallback**: Uses system Python

#### Manual Refresh
If you change virtual environments, refresh the detection:
```
<leader>pv    # Or :PythonSetVenv
```

#### Python Diagnostics
Diagnostics appear when cursor stops on an error line (300ms delay):
- No inline virtual text (cleaner interface)
- Floating window with error details
- Error signs in gutter
- Underlines on error lines

### Go Testing with Environment Variables
Create `.env` in your project root (same directory as `go.mod`):
```bash
# .env
DATABASE_URL=postgres://test:test@localhost/testdb
API_KEY=test-key-123
```

Tests will automatically source these variables before running `go test`.

### Debugging Go Applications
1. Set breakpoints with `<leader>b`
2. Start debugging with `<F5>` or `<leader>dgt` for tests
3. Use `<F10>/<F11>/<F12>` to step through code
4. Debug UI opens automatically with variables and call stack

### Project-wide Search and Replace Workflow
1. **Search**: `<leader>fg` and type your search term
2. **Collect Results**: Press `<C-q>` to send all results to quickfix
3. **Replace**: `:cfdo %s/oldword/newword/gc | update`
   - `g` = replace all occurrences in each line
   - `c` = ask for confirmation on each replacement
   - `update` = save file if changed

**Alternative without confirmation**:
```vim
:cfdo %s/oldword/newword/g | update
```

## 📁 Project Structure

```
~/.config/nvim/
├── init.lua                    # Entry point
├── lua/
│   ├── config/
│   │   ├── lazy.lua            # Plugin manager setup
│   │   ├── python-venv.lua     # Auto venv switching for pyright
│   │   └── diagnostics.lua     # Diagnostic display config
│   ├── plugins/                # Plugin configurations
│   │   ├── lsp-and-completion.lua
│   │   ├── treesitter.lua
│   │   ├── autopairs.lua
│   │   ├── formatting.lua      # conform.nvim (format on save)
│   │   ├── telescope.lua
│   │   ├── hop.lua
│   │   ├── gitsigns.lua
│   │   ├── diffview.lua
│   │   ├── vim-test.lua
│   │   ├── nvim-dap.lua
│   │   ├── neorg.lua
│   │   ├── markdown-preview.lua
│   │   └── colourscheme.lua
│   ├── utils/
│   │   └── python.lua          # Shared Poetry / venv detection
│   └── personal/               # Machine-local overrides (gitignored)
├── README.md
└── .gitignore
```

## 🔧 Customization

### Adding New Plugins
Create a new file in `lua/plugins/`:
```lua
-- lua/plugins/my-plugin.lua
return {
  "author/plugin-name",
  config = function()
    -- Plugin setup
  end,
}
```

### Changing Theme
Add the colorscheme spec to `lua/plugins/colourscheme.lua`, then update the `vim.cmd.colorscheme(...)` call in `init.lua`.

## 🐛 Troubleshooting

### Go Debugging Not Working
1. Ensure Delve is installed: `dlv version`
2. Check if `dlv` is in PATH: `which dlv`
3. Verify Go treesitter is installed: `:TSInstall go`

### Tests Not Finding go.mod
The configuration automatically searches upward for `go.mod` files, supporting monorepo structures.

---

## Technical Notes

### LSP Configuration
The LSP is a standardized JSON-RPC protocol that lets editors talk to language‐specific "servers" that provide features like:
- Completions (what symbols are valid here)
- Diagnostics (errors, warnings)
- Hover info (type/signature tooltips)
- Go-to-definition, find references, rename, etc.

### Completion Engine
A generic framework within Neovim that:
- Lists candidate completions in a popup menu
- Handles user navigation (`<Tab>`, `<C-n>`, `<CR>`)
- Inserts the selected completion into the buffer

It does not itself know about LSP or buffers or paths—you give it "sources."

### Completion Sources
Adapters that tell the completion engine where to look for suggestions:
- LSP source (cmp-nvim-lsp): calls your language server
- Buffer source (cmp-buffer): scans text in open buffers
- Path source (cmp-path): completes filesystem paths
- Cmdline source (cmp-cmdline): completes commands/search in `:` and `/`
- vim-dadbod-completion: column/table names from the active DB connection
