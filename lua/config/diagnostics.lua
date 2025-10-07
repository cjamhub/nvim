-- Diagnostic configuration for better error display

-- Configure diagnostic display
vim.diagnostic.config({
	virtual_text = false, -- Disable inline diagnostic text
	signs = true, -- Keep error signs in gutter (E, W, etc.)
	underline = true, -- Keep underline on errors
	update_in_insert = false,
	severity_sort = true,
	float = {
		focusable = false,
		style = "minimal",
		border = "rounded",
		source = "always", -- Show source (e.g., "pyright")
		header = "",
		prefix = "",
	},
})

-- Show diagnostics only when cursor stops on a line with diagnostic
vim.api.nvim_create_autocmd("CursorHold", {
	callback = function()
		-- Check if there's a diagnostic on the current line
		local line = vim.api.nvim_win_get_cursor(0)[1] - 1
		local diagnostics = vim.diagnostic.get(0, { lnum = line })

		-- Only show if diagnostics exist on this line
		if #diagnostics > 0 then
			vim.diagnostic.open_float(nil, {
				focusable = false,
				close_events = { "BufLeave", "CursorMoved", "InsertEnter" },
				border = "rounded",
				source = "always",
				prefix = " ",
				scope = "line",
			})
		end
	end,
})

-- Set delay before CursorHold triggers (300ms)
vim.opt.updatetime = 300

-- Keymaps for diagnostics
vim.keymap.set("n", "[d", vim.diagnostic.goto_prev, { desc = "Go to previous diagnostic" })
vim.keymap.set("n", "]d", vim.diagnostic.goto_next, { desc = "Go to next diagnostic" })
vim.keymap.set("n", "<leader>d", vim.diagnostic.open_float, { desc = "Show diagnostic in float" })
vim.keymap.set("n", "<leader>q", vim.diagnostic.setloclist, { desc = "Open diagnostics list" })