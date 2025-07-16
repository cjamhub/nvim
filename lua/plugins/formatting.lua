return {
	"stevearc/conform.nvim",
	event = { "BufWritePre" },
	cmd = { "ConformInfo" },
	keys = {
		{
			"<leader>f",
			function()
				require("conform").format({ async = true, lsp_fallback = true })
			end,
			mode = "",
			desc = "Format buffer",
		},
	},
	opts = {
		formatters_by_ft = {
			lua = { "stylua" },
			go = { "gofmt" },
			rust = { "rustfmt" },
			solidity = { "forge_fmt" },
		},
		formatters = {
			gofmt = {
				command = "gofmt",
				args = { "-s" },
			},
			forge_fmt = {
				command = "forge",
				args = { "fmt", "--raw", "-" },
				stdin = true,
			},
		},
		format_on_save = {
			timeout_ms = 500,
			lsp_fallback = true,
		},
	},
	init = function()
		vim.o.formatexpr = "v:lua.require'conform'.formatexpr()"
	end,
}
