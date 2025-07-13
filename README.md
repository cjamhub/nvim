# Configuration

- [ ] basic setting in `init.lua`
- [ ] plugins and plugin related setting add in `lua/plugins`

# LSP, Completion Configuration
## Basic Concepts

### LSP
The LSP is a standardized JSON-RPC protocol that lets editors talk to language‐specific “servers” that provide features like:
- Completions (what symbols are valid here)
- Diagnostics (errors, warnings)
- Hover info (type/signature tooltips)
- Go-to-definition, find references, rename, etc.

### Completion Engine
A generic framework within Neovim that:
- Lists candidate completions in a popup menu
- Handles user navigation (<Tab>, <C-n>, <CR>)
- Inserts the selected completion into the buffer
It does not itself know about LSP or buffers or paths—you give it “sources.”

### Completion Sources
Adapters that tell the completion engine where to look for suggestions:
- LSP source (cmp-nvim-lsp): calls your language server
- Buffer source (cmp-buffer): scans text in open buffers
- Path source (cmp-path): completes filesystem paths
- Cmdline source (cmp-cmdline): completes commands/ search in : and /
- …plus extras: git branches, emoji, Neovim API, calculations, etc.

### Snippet Engine
A system for expanding small “templates” with placeholders and jump-points.

### Formatting Helpers
### Install & Manager tools (like Mason)


