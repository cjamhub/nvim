return {
	"sindrets/diffview.nvim",
	dependencies = { "nvim-lua/plenary.nvim" },
	cmd = {
		"DiffviewOpen",
		"DiffviewClose",
		"DiffviewToggleFiles",
		"DiffviewFocusFiles",
		"DiffviewRefresh",
		"DiffviewFileHistory",
	},
	keys = {
		{ "<leader>gv", "<cmd>DiffviewOpen<cr>", desc = "Diffview: working tree vs HEAD" },
		{ "<leader>gV", "<cmd>DiffviewClose<cr>", desc = "Diffview: close" },
		{ "<leader>gh", "<cmd>DiffviewFileHistory %<cr>", desc = "Diffview: current file history" },
		{ "<leader>gH", "<cmd>DiffviewFileHistory<cr>", desc = "Diffview: branch file history" },
	},
	opts = {
		enhanced_diff_hl = true,
		view = {
			default = { layout = "diff2_horizontal" },
			merge_tool = { layout = "diff3_mixed" },
		},
		file_panel = {
			listing_style = "tree",
			win_config = { width = 35 },
		},
	},
}
