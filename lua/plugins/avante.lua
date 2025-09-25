return {
	{
		"yetone/avante.nvim",
		event = "VeryLazy",
		lazy = false,
		version = false,
		opts = {
			-- NOTE: Claude API requires separate payment (not included in Claude Pro subscription)
			-- To switch providers after credits run out:
			-- Option 1: Change to "openai" if you have OpenAI API credits
			-- Option 2: Change to "copilot" if you have GitHub Copilot subscription
			-- Option 3: Use local models with "ollama" (free but requires local setup)
			-- Example: provider = "openai", auto_suggestions_provider = "openai"
			provider = "copilot",
			-- auto_suggestions_provider = "claude",
			providers = {
				claude = {
					endpoint = "https://api.anthropic.com",
					model = "claude-3-5-sonnet-20241022",
					extra_request_body = {
						temperature = 0,
						max_tokens = 2048,
					},
				},

				-- OpenAI configuration (if you have OpenAI API credits)
				-- To use: provider = "openai", auto_suggestions_provider = "openai"
				-- Set API key: export OPENAI_API_KEY="your-key-here"
				openai = {
					endpoint = "https://api.openai.com/v1",
					model = "gpt-4-turbo-preview", -- or "gpt-3.5-turbo" for cheaper option
					timeout = 30000,
					extra_request_body = {
						temperature = 0,
						max_tokens = 2048,
					},
				},
				-- Copilot configuration (ready to use when you switch)
				-- Just change provider = "copilot" above when needed
				copilot = {
					endpoint = "https://api.githubcopilot.com",
					model = "gpt-4o-2024-08-06",
					proxy = nil,
					allow_insecure = false,
					extra_request_body = {
						temperature = 0,
						max_tokens = 4096,
					},
				},
			},
			behaviour = {
				auto_suggestions = false,
				auto_set_highlight_group = true,
				auto_set_keymaps = true,
				auto_apply_diff_after_generation = false,
				support_paste_from_clipboard = false,
			},
			mappings = {
				diff = {
					ours = "co",
					theirs = "ct",
					all_theirs = "ca",
					both = "cb",
					cursor = "cc",
					next = "]x",
					prev = "[x",
				},
				-- suggestion = {
				-- 	-- Auto-suggestion keymaps (when auto_suggestions = true)
				-- 	-- Note: <M-l> means Alt+l on Linux/Windows, Option+l on Mac
				-- 	accept = "<M-l>",     -- Accept the AI suggestion
				-- 	next = "<M-]>",       -- Next suggestion
				-- 	prev = "<M-[>",       -- Previous suggestion
				-- 	dismiss = "<C-]>",    -- Dismiss suggestion
				-- },
				jump = {
					next = "]]",
					prev = "[[",
				},
				submit = {
					normal = "<CR>",
					insert = "<C-s>",
				},
				sidebar = {
					switch_windows = "<Tab>",
					reverse_switch_windows = "<S-Tab>",
				},
			},
			hints = { enabled = true },
			windows = {
				position = "right",
				wrap = true,
				width = 30,
				sidebar_header = {
					align = "center",
					rounded = true,
				},
			},
			highlights = {
				diff = {
					current = "DiffText",
					incoming = "DiffAdd",
				},
			},
			diff = {
				autojump = true,
				list_opener = "copen",
			},
		},
		build = "make",
		dependencies = {
			"nvim-treesitter/nvim-treesitter",
			"stevearc/dressing.nvim",
			"nvim-lua/plenary.nvim",
			"MunifTanjim/nui.nvim",
			"nvim-tree/nvim-web-devicons",
			{
				"HakonHarnes/img-clip.nvim",
				event = "VeryLazy",
				opts = {
					default = {
						embed_image_as_base64 = false,
						prompt_for_file_name = false,
						drag_and_drop = {
							insert_mode = true,
						},
						use_absolute_path = true,
					},
				},
			},
			{
				"MeanderingProgrammer/render-markdown.nvim",
				opts = {
					file_types = { "markdown", "Avante" },
				},
				ft = { "markdown", "Avante" },
			},
		},
	},
}
