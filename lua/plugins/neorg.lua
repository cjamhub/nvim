return {
	"nvim-neorg/neorg",
	dependencies = { "nvim-lua/plenary.nvim", "nvim-treesitter/nvim-treesitter" },
	version = "*", -- Pin Neorg to the latest stable release
	config = function()
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
				["core.integrations.nvim-cmp"] = {},
				["core.export"] = {},
				["core.export.markdown"] = {
					config = {
						extensions = "all",
					},
				},
				["core.dirman"] = {
					config = {
						workspaces = {
							notes = "~/Workspace/Jam/notes",
						},
						default_workspace = "notes",
					},
				},
				["core.keybinds"] = {
					config = {
						hook = function(keybinds)
							keybinds.map_event("norg", "n", "<Leader>td", "core.qol.todo_items.todo.task_done")
							keybinds.map_event("norg", "n", "<Leader>tu", "core.qol.todo_items.todo.task_undone")
							keybinds.map_event("norg", "n", "<Leader>th", "core.qol.todo_items.todo.task_on_hold")
							keybinds.map_event("norg", "n", "<Leader>tp", "core.qol.todo_items.todo.task_pending")
							keybinds.map_event("norg", "n", "<Leader>tc", "core.qol.todo_items.todo.task_cancelled")
							keybinds.map_event("norg", "n", "<Leader>ti", "core.qol.todo_items.todo.task_important")
						end,
					},
				},
			},
			-- logger = {
			--     level = 'info',
			-- },
		})
	end,
	vim.keymap.set("n", "<Leader>tt", ":Neorg journal today<CR><CR>", {}),
	vim.keymap.set("n", "<Leader>ty", ":Neorg journal yesterday<CR><CR>", {}),
}
