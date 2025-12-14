-- Markdown table formatting
return {
	"dhruvasagar/vim-table-mode",
	ft = { "markdown", "org" },
	config = function()
		-- Use markdown-compatible tables
		vim.g.table_mode_corner = "|"

		-- Keymaps
		vim.keymap.set("n", "<leader>tm", ":TableModeToggle<CR>", { desc = "Toggle Table Mode" })
		vim.keymap.set("n", "<leader>tr", ":TableModeRealign<CR>", { desc = "Realign Table" })
	end,
}
