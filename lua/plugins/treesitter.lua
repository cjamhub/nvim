-- master branch only supports Neovim <= 0.11; main is required for 0.12+ and
-- has a different API: no more `.configs.setup()`/`ensure_installed`/
-- `highlight.enable` table -- parsers are installed explicitly and
-- highlighting is enabled per filetype via `vim.treesitter.start()`.
local parsers = {
	"lua",
	"python",
	"javascript",
	"typescript",
	"rust",
	"go",
	"markdown",
	"circom",
	"solidity",
}

return {
	"nvim-treesitter/nvim-treesitter",
	branch = "main",
	build = ":TSUpdate",
	lazy = false, -- this plugin does not support lazy-loading
	config = function()
		require("nvim-treesitter").install(parsers)

		vim.api.nvim_create_autocmd("FileType", {
			pattern = parsers,
			callback = function()
				vim.treesitter.start()
			end,
		})
	end,
}
