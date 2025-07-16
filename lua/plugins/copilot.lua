return {
	"github/copilot.vim",
	config = function()
		-- Disable default tab mapping to avoid conflicts
		vim.g.copilot_no_tab_map = true

		-- Enable Copilot for specific file types
		vim.g.copilot_filetypes = {
			["*"] = false,
			["norg"] = true,
			["solidity"] = true,
			["rust"] = true,
			["go"] = true,
			["lua"] = true,
			["python"] = true,
			["javascript"] = true,
			["typescript"] = true,
			["javascriptreact"] = true,
			["typescriptreact"] = true,
			["json"] = true,
			["yaml"] = true,
			["toml"] = true,
			["markdown"] = true,
		}

		-- Key mappings for Copilot
		vim.keymap.set("i", "<C-l>", 'copilot#Accept("\\<CR>")', {
			expr = true,
			replace_keycodes = false,
		})

		vim.keymap.set("i", "<C-j>", "copilot#Previous()", { expr = true })
		vim.keymap.set("i", "<C-k>", "copilot#Next()", { expr = true })

		-- Optional: Dismiss Copilot suggestion
		-- vim.keymap.set("i", "<C-D>", "copilot#Dismiss()", { expr = true })
	end,
}
