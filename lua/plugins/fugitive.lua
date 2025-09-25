return {
	"tpope/vim-fugitive",
	cmd = { "G", "Git", "Gdiffsplit", "Gread", "Gwrite", "Ggrep", "Gmove", "Gdelete", "Gclog", "Gllog" },
	config = function()
		local map = vim.keymap.set

		-- Fugitive keymaps
		map("n", "<leader>gs", "<cmd>Git<cr>", { desc = "Git status" })
		map("n", "<leader>gd", "<cmd>Gdiffsplit<cr>", { desc = "Git diff split" })
		map("n", "<leader>gb", "<cmd>Git blame<cr>", { desc = "Git blame" })
		map("n", "<leader>gL", "<cmd>Gclog<cr>", { desc = "Git log (quickfix)" })
		map("n", "<leader>gp", "<cmd>Git push<cr>", { desc = "Git push" })
		map("n", "<leader>gP", "<cmd>Git pull<cr>", { desc = "Git pull" })
		map("n", "<leader>gw", "<cmd>Gwrite<cr>", { desc = "Git write (stage)" })
		map("n", "<leader>gr", "<cmd>Gread<cr>", { desc = "Git read (checkout file)" })
	end,
}