return {
	{
		"nvim-neotest/neotest",
		dependencies = {
			"nvim-neotest/nvim-nio",
			"nvim-lua/plenary.nvim",
			"antoinemadec/FixCursorHold.nvim",
			"nvim-treesitter/nvim-treesitter",
			"nvim-neotest/neotest-go",
		},
		config = function()
			require("neotest").setup({
				adapters = {
					require("neotest-go")({
						experimental = {
							test_table = true,
						},
						args = { "-count=1", "-timeout=60s" },
					}),
				},
				output = {
					enabled = true,
					open_on_run = false,
				},
				output_panel = {
					enabled = true,
					open = "botright split | resize 15",
				},
			})

			vim.keymap.set("n", ",t", function()
				require("neotest").run.run()
			end, { desc = "Run nearest test" })

			vim.keymap.set("n", "<leader>tf", function()
				require("neotest").run.run(vim.fn.expand("%"))
			end, { desc = "Run tests in current file" })

			vim.keymap.set("n", "<leader>td", function()
				require("neotest").run.run({ strategy = "dap" })
			end, { desc = "Debug nearest test" })

			vim.keymap.set("n", "<leader>ts", function()
				require("neotest").summary.toggle()
			end, { desc = "Toggle test summary" })

			vim.keymap.set("n", "<leader>to", function()
				require("neotest").output.open({ enter = true, auto_close = true, short = false })
			end, { desc = "Show test output" })

			vim.keymap.set("n", "<space>to", function()
				require("neotest").output_panel.toggle()
			end, { desc = "Toggle test output panel" })
		end,
	},
}
