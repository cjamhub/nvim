return {
	"nvim-telescope/telescope.nvim",
	tag = "0.1.8",
	dependencies = {
		"nvim-lua/plenary.nvim",
		"nvim-telescope/telescope-fzf-native.nvim",
		build = "make", -- optional native FZF sorter
		"nvim-telescope/telescope-project.nvim",
	},
	config = function()
		local telescope = require("telescope")

		telescope.setup({
			defaults = {
				path_display = { "smart" },
				layout_config = {
					width = 0.9,
					height = 0.9,
				},
				wrap_results = true,
			},
			pickers = {
				diagnostics = {
					theme = "ivy",
					wrap_results = true,
				},
			},
			extensions = {
				fzf = {
					fuzzy = true,
					override_generic_sorter = true,
					override_file_sorter = true,
				},
				project = {
					base_dirs = {
						"~/Workspace/Jam/",
						"~/Workspace/Durham/",
						"~/Workspace/xHubs/",
						"~/Workspace/Stakestone/",
						"~/.config/nvim/",
					},
					order_by = "asc",
					hidden_files = true,
					search_by = "title",
				},
			},
		})

		telescope.load_extension("project")

		local map = vim.keymap.set
		map("n", "<leader>ff", require("telescope.builtin").find_files, { desc = "Find Files" })
		map("n", "<leader>fg", require("telescope.builtin").live_grep, { desc = "Live Grep" })
		map("n", "<leader>fb", require("telescope.builtin").buffers, { desc = "Buffers" })
		map("n", "<leader>fh", require("telescope.builtin").help_tags, { desc = "Help Tags" })
		map("n", "<leader>tcl", require("telescope.builtin").colorscheme, { desc = "Colorscheme" })
		map("n", "<leader>fp", require("telescope").extensions.project.project, { desc = "Projects" })
		map(
			"n",
			"<C-s>",
			require("telescope.builtin").current_buffer_fuzzy_find,
			{ desc = "Fyzzy Find Current Buffer" }
		)
		map("n", "<leader>fc", function()
			require("telescope.builtin").diagnostics({ severity_bound = 0 })
		end, { desc = "Diagnostics List" })
		map("n", "<leader>f.", require("telescope.builtin").oldfiles, { desc = "Old Files" })
	end,
}
