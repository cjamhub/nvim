# My Neovim Configuration

A modern Neovim configuration with Go development focus, AI assistance, and debugging capabilities.

## ✨ Features

### 🔧 Core
- **Plugin Manager**: [lazy.nvim](https://github.com/folke/lazy.nvim)
- **LSP**: Go, Lua, Rust, TypeScript, Solidity support
- **Completion**: nvim-cmp with LSP, buffer, and path sources
- **Syntax Highlighting**: Treesitter with enhanced Go support

### 🧪 Testing & Debugging
- **Go Testing**: vim-test with automatic go.mod detection
- **Debugging**: nvim-dap with Go debugging via Delve
- **Environment Support**: Automatic .env.test loading for tests

### 🤖 AI Assistance
- **Avante.nvim**: AI-powered code assistance (Claude/OpenAI/Copilot)
- **Image Support**: Paste images in AI conversations
- **Multiple Providers**: Easily switch between AI providers

### 🎨 UI & Navigation
- **Telescope**: Fuzzy finder with project support
- **Git Integration**: Gitsigns for git status in gutter
- **Hop**: Fast cursor movement
- **Color Schemes**: Multiple themes (Catppuccin, Nord, Gruvbox, Solarized)

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

## 🔑 API Keys Setup

### For AI Features (Avante)
Choose one of the following providers:

#### Option 1: Claude (Anthropic)
```bash
export ANTHROPIC_API_KEY="your-anthropic-api-key"
```

#### Option 2: OpenAI
```bash
export OPENAI_API_KEY="your-openai-api-key"
```

#### Option 3: GitHub Copilot
- Requires GitHub Copilot subscription
- Change provider in `lua/plugins/avante.lua`:
  ```lua
  provider = "copilot",
  auto_suggestions_provider = "copilot",
  ```

### Switching AI Providers
Edit `lua/plugins/avante.lua` and change:
```lua
provider = "claude",        -- Change to "openai" or "copilot"
auto_suggestions_provider = "claude",  -- Match the provider above
```

## ⚡ Key Bindings

### Testing
- `,t` - Run nearest Go test
- `,T` - Run all tests in file

### Debugging
- `<F5>` - Start/Continue debugging
- `<F10>` - Step over
- `<F11>` - Step into
- `<F12>` - Step out
- `<leader>b` - Toggle breakpoint
- `<leader>dgt` - Debug Go test at cursor

### Navigation
- `<leader>ff` - Find files
- `<leader>fg` - Live grep
- `<leader>fb` - Find buffers
- `<space>` + motion - Hop to location

### LSP
- `gd` - Go to definition
- `K` - Hover documentation
- `<leader>rn` - Rename symbol
- `<leader>ca` - Code actions
- `gr` - Find references

### AI (Avante)
- `<CR>` - Submit AI prompt (normal mode)
- `<C-s>` - Submit AI prompt (insert mode)
- `<Tab>` - Switch between AI windows

## 🛠️ Project-Specific Features

### Go Testing with Environment Variables
Create `.env.test` in your project root (same directory as `go.mod`):
```bash
# .env.test
DATABASE_URL=postgres://test:test@localhost/testdb
API_KEY=test-key-123
```

Tests will automatically load these variables.

### Debugging Go Applications
1. Set breakpoints with `<leader>b`
2. Start debugging with `<F5>` or `<leader>dgt` for tests
3. Use `<F10>/<F11>/<F12>` to step through code
4. Debug UI opens automatically with variables and call stack

## 📁 Project Structure

```
~/.config/nvim/
├── init.lua                    # Entry point
├── lua/
│   ├── config/
│   │   └── lazy.lua           # Plugin manager setup
│   └── plugins/               # Plugin configurations
│       ├── avante.lua         # AI assistance
│       ├── lsp-and-completion.lua  # LSP & completion
│       ├── vim-test.lua       # Go testing
│       ├── nvim-dap.lua       # Debugging
│       ├── telescope.lua      # Fuzzy finder
│       └── ...
├── README.md                  # This file
└── .gitignore                 # Security exclusions
```

## 🔧 Customization

### Adding New Plugins
Create a new file in `lua/plugins/` or add to existing files:
```lua
-- lua/plugins/my-plugin.lua
return {
  "author/plugin-name",
  config = function()
    -- Plugin setup
  end,
}
```

### Changing Themes
Edit `lua/plugins/colourscheme.lua` and update the colorscheme name.

## 🐛 Troubleshooting

### AI Features Not Working
1. Check API key is set: `echo $ANTHROPIC_API_KEY`
2. Verify provider in `lua/plugins/avante.lua`
3. Restart Neovim after changing API keys

### Go Debugging Not Working
1. Ensure Delve is installed: `dlv version`
2. Check if `dlv` is in PATH: `which dlv`
3. Verify Go treesitter is installed: `:TSInstall go`

### Tests Not Finding go.mod
The configuration automatically searches upward for `go.mod` files, supporting monorepo structures.

## 🤝 Contributing

Feel free to fork and customize this configuration! If you add useful features, consider creating a pull request.

## 📄 License

This configuration is free to use and modify.

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
- Handles user navigation (<Tab>, <C-n>, <CR>)
- Inserts the selected completion into the buffer
It does not itself know about LSP or buffers or paths—you give it "sources."

### Completion Sources
Adapters that tell the completion engine where to look for suggestions:
- LSP source (cmp-nvim-lsp): calls your language server
- Buffer source (cmp-buffer): scans text in open buffers
- Path source (cmp-path): completes filesystem paths
- Cmdline source (cmp-cmdline): completes commands/ search in : and /
- …plus extras: git branches, emoji, Neovim API, calculations, etc.
