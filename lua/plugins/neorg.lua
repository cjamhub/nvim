return {
	"nvim-neorg/neorg",
	dependencies = { "nvim-lua/plenary.nvim", "nvim-treesitter/nvim-treesitter" },
	version = "*", -- Pin Neorg to the latest stable release
	config = function()
		-- norg_meta.so is built by luarocks into lazy-rocks/, but nvim-treesitter
		-- only searches its own parser/ dir. Symlink it across once so neorg
		-- stops complaining about a missing parser on startup.
		local data = vim.fn.stdpath("data")
		local rocks_parser = data .. "/lazy-rocks/tree-sitter-norg-meta/lib/lua/5.1/parser/norg_meta.so"
		local ts_parser = data .. "/lazy/nvim-treesitter/parser/norg_meta.so"
		if vim.fn.filereadable(rocks_parser) == 1 and vim.fn.filereadable(ts_parser) == 0 then
			vim.fn.system({ "ln", "-sf", rocks_parser, ts_parser })
		end

		vim.opt.conceallevel = 2

		-- Disable auto-folding for neorg files
		vim.api.nvim_create_autocmd("FileType", {
			pattern = "norg",
			callback = function()
				vim.opt_local.foldenable = false
			end,
		})

		require("neorg").setup({
			load = {
				["core.defaults"] = {},
				["core.concealer"] = {},
				["core.dirman"] = {
					config = {
						workspaces = {
							notes = "~/Workspace/Jam/notes",
						},
						default_workspace = "notes",
					},
				},
			},
		})

		vim.keymap.set("n", "<Leader>tt", ":Neorg journal today<CR><CR>", { desc = "Open today's draft" })
	end,
}
