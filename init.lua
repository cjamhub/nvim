vim.g.mapleader = " "
vim.g.maplocalleader = " "

vim.schedule(function()
	vim.o.clipboard = "unnamedplus"
end)

vim.o.breakindent = true
vim.o.undofile = true

vim.opt.shiftwidth = 4
vim.opt.tabstop = 4
vim.opt.expandtab = true

vim.o.signcolumn = "yes"
vim.g.have_nerd_font = true
vim.o.mouse = "a"

vim.keymap.set("n", "<Leader>e", ":e%:h<CR>")
vim.keymap.set("n", "<C-k>", ":tabnext<CR>")
vim.keymap.set("n", "<C-j>", ":tabprev<CR>")

-- fixed scratch file for quick notes
vim.keymap.set("n", "<Leader>tt", function()
	local scratch = vim.fn.expand("~/Workspace/Jam/notes/scratch.md")
	vim.fn.mkdir(vim.fn.fnamemodify(scratch, ":h"), "p")
	vim.cmd("edit " .. vim.fn.fnameescape(scratch))
end, { desc = "Open scratch file" })

require("config.lazy")
require("config.python-venv")
require("config.diagnostics")

-- vim.o.background = "light"
vim.opt.termguicolors = true
vim.cmd.colorscheme("nord")

local function git_branch()
	local handle = io.popen("git rev-parse --abbrev-ref HEAD 2>/dev/null")
	if handle then
		local branch = handle:read("*l")
		handle:close()
		if branch and branch ~= "HEAD" then
			return " " .. branch
		end
	end
	return ""
end

vim.o.statusline = "%f %h%m%r%=%{v:lua.git_branch()} %y %p%% %l:%c"
_G.git_branch = git_branch
