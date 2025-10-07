vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- clipboard
vim.schedule(function()
	vim.o.clipboard = "unnamedplus"
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

-- mouse
vim.o.mouse = "a"

-- basic keymaps
vim.keymap.set("n", "<Leader>e", ":e%:h<CR>")
vim.keymap.set("n", "<C-k>", ":tabnext<CR>")
vim.keymap.set("n", "<C-j>", ":tabprev<CR>")

require("config.lazy")
require("config.python-venv") -- Auto-detect Python venv
require("config.diagnostics") -- Better diagnostic display

-- vim.o.background = "light"
vim.opt.termguicolors = true
vim.cmd.colorscheme("nord")

-- statusline
local function git_branch()
	local handle = io.popen("git rev-parse --abbrev-ref HEAD 2>/dev/null")
	if handle then
		local branch = handle:read("*l")
		handle:close()
		if branch and branch ~= "HEAD" then
			return " " .. branch
		end
	end
	return ""
end

vim.o.statusline = "%f %h%m%r%=%{v:lua.git_branch()} %y %p%% %l:%c"
_G.git_branch = git_branch
