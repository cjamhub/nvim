-- Mermaid diagram rendering with diagram.nvim
return {
	"3rd/diagram.nvim",
	dependencies = {
		"3rd/image.nvim",
	},
	opts = {
		renderer_options = {
			mermaid = {
				background = nil, -- nil will use the default from your theme
				theme = "default", -- or "dark", "forest", "neutral"
			},
		},
	},
	config = function(_, opts)
		require("diagram").setup(opts)

		-- Fix positioning issue in markdown files by disabling concealing
		vim.api.nvim_create_autocmd("FileType", {
			pattern = { "markdown" },
			callback = function()
				vim.opt_local.conceallevel = 0 -- Disable markdown syntax concealing
			end,
		})
	end,
}