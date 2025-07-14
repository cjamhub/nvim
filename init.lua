vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

-- clipboard
vim.schedule(function()
  vim.o.clipboard = 'unnamedplus'
end)

-- Enable break indent
vim.o.breakindent = true

-- Save undo history
vim.o.undofile = true

-- tab/indentation
vim.opt.shiftwidth = 4
vim.opt.tabstop = 4
vim.opt.expandtab = true

-- for sign column
vim.o.signcolumn = "yes"

-- font
vim.g.have_nerd_font = true
-- for color
vim.opt.termguicolors  = true

-- mouse
vim.o.mouse = 'a'

-- basic keymaps
vim.keymap.set('n', '<Leader>e', ':e%:h<CR>')
vim.keymap.set('n', '<C-k>', ':tabnext<CR>')
vim.keymap.set('n', '<C-j>', ':tabprev<CR>')

require("config.lazy")

vim.cmd.colorscheme("catppuccin")
