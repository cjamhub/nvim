-- Markdown preview in browser
return {
	"iamcco/markdown-preview.nvim",
	cmd = { "MarkdownPreviewToggle", "MarkdownPreview", "MarkdownPreviewStop" },
	ft = { "markdown" },
	build = function()
		vim.fn.system("cd " .. vim.fn.stdpath("data") .. "/lazy/markdown-preview.nvim/app && npm install")
		-- Configure git to ignore yarn.lock to prevent update conflicts
		vim.fn.system(
			"cd "
				.. vim.fn.stdpath("data")
				.. "/lazy/markdown-preview.nvim && git update-index --assume-unchanged app/yarn.lock"
		)
	end,
	init = function()
		vim.g.mkdp_filetypes = { "markdown" }
	end,
	config = function()
		-- Configuration
		vim.g.mkdp_auto_start = 0 -- Don't auto-start preview
		vim.g.mkdp_auto_close = 1 -- Auto-close when changing from markdown buffer
		vim.g.mkdp_refresh_slow = 0 -- Auto refresh on save
		vim.g.mkdp_browser = "" -- Use system default browser
		vim.g.mkdp_echo_preview_url = 1 -- Echo preview page URL

		-- Keymaps
		vim.keymap.set("n", "<leader>mp", "<cmd>MarkdownPreview<cr>", { desc = "Markdown Preview" })
		vim.keymap.set("n", "<leader>ms", "<cmd>MarkdownPreviewStop<cr>", { desc = "Stop Markdown Preview" })
		vim.keymap.set("n", "<leader>mt", "<cmd>MarkdownPreviewToggle<cr>", { desc = "Toggle Markdown Preview" })
	end,
}
