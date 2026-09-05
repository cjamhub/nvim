return {
	{
		"mason-org/mason-lspconfig.nvim",
		dependencies = {
			{ "mason-org/mason.nvim", opts = {} },
			{ "neovim/nvim-lspconfig" },
			{
				"WhoIsSethDaniel/mason-tool-installer.nvim",
				opts = {
					ensure_installed = {
						"stylua",
						"prettier",
						"rust-analyzer", -- consumed by rustaceanvim, not mason-lspconfig
					},
				},
			},
		},
		config = function()
			require("mason").setup()

			vim.lsp.config("*", { capabilities = require("blink.cmp").get_lsp_capabilities() })

			require("mason-lspconfig").setup({
				ensure_installed = {
					"lua_ls",
					"gopls",
					"solidity_ls",
					"ts_ls",
					"pyright",
					"ruff",
				},
				-- excludes: rustaceanvim owns rust_analyzer; pyright/ruff/solidity_ls
				-- get explicit vim.lsp.config below instead of bare defaults (see CLAUDE.md)
				automatic_enable = {
					exclude = { "rust_analyzer", "pyright", "ruff", "solidity_ls", "solidity_ls_nomicfoundation" },
				},
			})

			-- remappings pulled from `forge remappings` so they aren't hardcoded to one library
			vim.lsp.config("solidity_ls", {
				settings = {
					solidity = { includePath = { "node_modules" }, remappings = {} },
				},
				on_init = function(client)
					local remappings = {}
					local handle = io.popen("cd " .. client.root_dir .. " && forge remappings 2>/dev/null")
					if handle then
						local output = handle:read("*a")
						handle:close()
						for line in output:gmatch("[^\r\n]+") do
							local key, value = line:match("^(.-)=(.+)$")
							if key and value then
								remappings[key:gsub("/$", "")] = value:gsub("/$", "")
							end
						end
					end
					client.settings = vim.tbl_deep_extend("force", client.settings, {
						solidity = { remappings = remappings },
					})
					client:notify("workspace/didChangeConfiguration", { settings = client.settings })
				end,
			})
			vim.lsp.enable("solidity_ls")

			local python_utils = require("utils.python")
			vim.lsp.config("pyright", {
				settings = {
					python = {
						analysis = {
							autoSearchPaths = true,
							useLibraryCodeForTypes = true,
							diagnosticMode = "workspace",
						},
					},
				},
				before_init = function(_, config)
					local venv_result = python_utils.find_venv(config.root_dir)
					if venv_result then
						if venv_result:match("^/") then
							config.settings.python.pythonPath = venv_result .. "/bin/python"
						else
							config.settings.python.venvPath = config.root_dir
							config.settings.python.venv = venv_result
						end
					end
				end,
			})
			vim.lsp.enable("pyright")

			-- defer hover to pyright, ruff only does diagnostics/actions
			vim.lsp.config("ruff", {
				on_attach = function(client)
					client.server_capabilities.hoverProvider = false
				end,
			})
			vim.lsp.enable("ruff")
		end,
	},

	{
		"mrcjkb/rustaceanvim",
		version = "^6",
		lazy = false,
		ft = { "rust" },
		init = function()
			vim.g.rustaceanvim = {
				server = {
					capabilities = require("blink.cmp").get_lsp_capabilities(),
					default_settings = {
						["rust-analyzer"] = {
							check = { command = "clippy" },
						},
					},
				},
			}
		end,
	},

	{
		"saghen/blink.cmp",
		version = "1.*",
		dependencies = { "rafamadriz/friendly-snippets" },
		opts = {
			keymap = {
				preset = "super-tab",
				["<C-f>"] = { "accept", "fallback" },
			},
			completion = {
				documentation = { auto_show = true },
				ghost_text = { enabled = true },
			},
			sources = {
				default = { "lsp", "path", "buffer", "snippets" },
			},
			cmdline = {
				enabled = true,
			},
			signature = { enabled = true },
		},
		opts_extend = { "sources.default" },
	},

	vim.keymap.set("n", "gd", vim.lsp.buf.definition, {}),
	vim.keymap.set("n", "gD", vim.lsp.buf.declaration, {}),
	vim.keymap.set("n", "K", vim.lsp.buf.hover, {}),
	vim.keymap.set("n", "gi", vim.lsp.buf.implementation, {}),
	vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, {}),
	vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, {}),
	vim.keymap.set("n", "gr", vim.lsp.buf.references, {}),
}
