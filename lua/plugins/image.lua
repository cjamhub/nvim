return {
	"3rd/image.nvim",
	config = function()
		require("image").setup({
			backend = "kitty",
			processor = "magick_cli",
			integrations = {
				neorg = {
					enabled = true,
					filetypes = { "norg" },
				},
				markdown = {
					enabled = true,
					clear_in_insert_mode = false,
					download_remote_images = true,
					only_render_image_at_cursor = false,
					filetypes = { "markdown", "vimwiki" },
				},
			},
			max_width = nil,
			max_height = nil,
			max_height_window_percentage = 50,
			window_overlap_clear_enabled = false,
		})
	end,
}