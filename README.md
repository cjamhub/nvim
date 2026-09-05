# My Neovim Configuration

A minimal Neovim configuration focused on Go / Python / Rust / Solidity / TypeScript development.

## ✨ Features

### 🔧 Core
- **Plugin Manager**: [lazy.nvim](https://github.com/folke/lazy.nvim)
- **LSP**: Go, Python (pyright + ruff), Lua, Rust (rustaceanvim), TypeScript, Solidity support
- **Completion**: blink.cmp with LSP, buffer, path, and snippet sources
- **Syntax Highlighting**: Treesitter

### 🧪 Testing
- **Go Testing**: vim-test with automatic `go.mod` detection and `.env` loading
- **Python Testing**: pytest with automatic venv/Poetry detection
- **Rust Testing**: `cargo test` via vim-test's `cargotest` runner
- **Solidity Testing**: Foundry `forge test` with contract/function matching
- One keymap for all four: `<leader>t` runs the test under the cursor

### 📝 Docs
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

# Install required tools
npm install -g prettier  # For formatting

# Rust development
# rustaceanvim needs a working rustup toolchain; Mason keeps rust-analyzer updated
rustup component add rust-analyzer

# Solidity development
# forge is used both for testing and for LSP remapping detection
curl -L https://foundry.paradigm.xyz | bash && foundryup

# Python development (optional)
# Mason will install pyright (type checking) and ruff (format + lint)
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
- `<leader>t` - Run nearest test (Go/Python/Rust/Solidity), output in a terminal split

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

### Solidity Remappings
`lsp-and-completion.lua` runs `forge remappings` in the project root and feeds the result straight into `solidity_ls`, so import remapping (e.g. `@openzeppelin/=lib/openzeppelin-contracts/`) works for whatever dependencies the project actually uses — nothing is hardcoded to a specific library.

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
blink.cmp ships these built in, no separate packages needed:
- `lsp`: calls your language server
- `buffer`: scans text in open buffers
- `path`: completes filesystem paths
- `snippets`: expands vscode-style snippets (via `friendly-snippets`)
- Cmdline completion (`:` and `/`) is handled by blink's own `cmdline` module
