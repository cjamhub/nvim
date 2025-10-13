return {
	-- 1) Mason for managing servers & lSP
	{
		"mason-org/mason-lspconfig.nvim",
		opts = {
			ensure_installed = {
				"lua_ls",
				"rust_analyzer",
				"gopls",
				"solidity_ls",
				"ts_ls",
				"pyright", -- Python LSP
			},
		},
		dependencies = {
			{ "mason-org/mason.nvim", opts = {} },
			{ "neovim/nvim-lspconfig" },
			{
				"WhoIsSethDaniel/mason-tool-installer.nvim",
				opts = {
					ensure_installed = {
						"stylua",
						"prettier",
						"delve",
						"black", -- Python formatter
						"ruff", -- Python linter
					},
				},
			},
		},
		config = function(_, opts)
			require("mason").setup()
			local mlsp = require("mason-lspconfig")
			mlsp.setup(opts)
			-- tell each server to use our shared capabilities
			local lspconfig = require("lspconfig")
			local caps = require("cmp_nvim_lsp").default_capabilities()
			mlsp.setup({
				-- default handler
				handlers = {
					function(server_name)
						lspconfig[server_name].setup({
							capabilities = caps,
						})
					end,
					-- Solidity LSP specific configuration
					solidity_ls = function()
						lspconfig.solidity_ls.setup({
							capabilities = caps,
							cmd = { "solidity-ls", "--stdio" },
							filetypes = { "solidity" },
							root_dir = require("lspconfig").util.root_pattern(
								"hardhat.config.js",
								"hardhat.config.ts",
								"truffle-config.js",
								"remappings.txt",
								"truffle.js",
								"foundry.toml",
								".git"
							),
							settings = {
								solidity = {
									includePath = {
										"node_modules",
									},
									remappings = {
										["@openzeppelin"] = "node_modules/@openzeppelin",
									},
								},
							},
						})
					end,
					-- Python LSP with venv support
					pyright = function()
						-- Function to check if this is a Poetry project
						local function is_poetry_project(dir)
							local pyproject_path = dir .. "/pyproject.toml"
							if vim.fn.filereadable(pyproject_path) == 1 then
								local content = vim.fn.readfile(pyproject_path)
								for _, line in ipairs(content) do
									if line:match("%[tool%.poetry%]") then
										return true
									end
								end
							end
							return false
						end

						-- Function to get Poetry virtualenv path
						local function get_poetry_venv(dir)
							local handle = io.popen("cd " .. dir .. " && poetry env info --path 2>/dev/null")
							if handle then
								local result = handle:read("*a")
								handle:close()
								if result and result ~= "" then
									return result:gsub("%s+$", "")
								end
							end
							return nil
						end

						-- Function to find virtual environment folder in root directory
						local function find_venv(workspace)
							if not workspace then
								return nil
							end

							-- First, check if this is a Poetry project
							if is_poetry_project(workspace) then
								local poetry_venv = get_poetry_venv(workspace)
								if poetry_venv then
									return poetry_venv
								end
							end

							-- Fall back to standard venv detection
							for _, venv_name in ipairs({ "venv", ".venv", "env", ".env" }) do
								local venv_path = workspace .. "/" .. venv_name
								if vim.fn.isdirectory(venv_path) == 1 then
									local python_path = venv_path .. "/bin/python3"
									if vim.fn.executable(python_path) == 0 then
										python_path = venv_path .. "/bin/python"
									end
									if vim.fn.executable(python_path) == 1 then
										return venv_name
									end
								end
							end

							return nil
						end

						lspconfig.pyright.setup({
							capabilities = caps,
							root_dir = lspconfig.util.root_pattern(
								"pyrightconfig.json",
								"pyproject.toml",
								"setup.py",
								"setup.cfg",
								"requirements.txt",
								"Pipfile",
								".git"
							),
							before_init = function(_, config)
								-- Auto-detect venv in project root
								local venv_result = find_venv(config.root_dir)
								if venv_result then
									-- Check if it's a full path (Poetry) or just a name (standard venv)
									if venv_result:match("^/") then
										-- Full path (Poetry virtualenv)
										config.settings.python.pythonPath = venv_result .. "/bin/python"
									else
										-- Relative path (standard venv)
										config.settings.python.venvPath = config.root_dir
										config.settings.python.venv = venv_result
									end
								end
							end,
							settings = {
								python = {
									analysis = {
										autoSearchPaths = true,
										useLibraryCodeForTypes = true,
										diagnosticMode = "workspace",
									},
								},
							},
						})
					end,
				},
			})
		end,
	},

	-- 2) Completion engine + source
	{
		"hrsh7th/nvim-cmp",
		dependencies = {
			"hrsh7th/cmp-nvim-lsp",
			"hrsh7th/cmp-buffer",
			"hrsh7th/cmp-path",
			"hrsh7th/cmp-cmdline",
			"L3MON4D3/LuaSnip", -- optional
			"saadparwaiz1/cmp_luasnip", -- optional
		},
		config = function()
			local cmp = require("cmp")
			local luasnip = require("luasnip")

			cmp.setup({
				-- 1) snippet
				snippet = {
					expand = function(args)
						luasnip.lsp_expand(args.body)
					end,
				},

				-- 2) keymap
				mapping = cmp.mapping.preset.insert({
					-- ["<C-l>"] = cmp.mapping.complete(),
					["<C-f>"] = cmp.mapping.confirm({ select = true }),
					["<Tab>"] = cmp.mapping(function(fallback)
						if cmp.visible() then
							cmp.select_next_item()
						elseif luasnip.expand_or_jumpable() then
							luasnip.expand_or_jump()
						else
							fallback()
						end
					end, { "i", "s" }),
					["<S-Tab>"] = cmp.mapping(function(fallback)
						if cmp.visible() then
							cmp.select_prev_item()
						elseif luasnip.jumpable(-1) then
							luasnip.jump(-1)
						else
							fallback()
						end
					end, { "i", "s" }),
				}),

				-- 3) completion resources
				sources = cmp.config.sources({
					{ name = "nvim_lsp" },
					{ name = "luasnip" },
				}, {
					{ name = "buffer" },
					{ name = "path" },
				}),

				-- 4) pop-up window behaviour
				completion = {
					autocomplete = {
						require("cmp.types").cmp.TriggerEvent.Insert,
						require("cmp.types").cmp.TriggerEvent.TextChanged,
					},
				},

				-- 5) in-line preview
				experimental = {
					ghost_text = true,
				},
			})

			-- 6) command line completion under '/'
			cmp.setup.cmdline({ "/", "?" }, {
				mapping = cmp.mapping.preset.cmdline(),
				sources = { { name = "buffer" } },
			})

			-- 7) command line completion under ':'
			cmp.setup.cmdline(":", {
				mapping = cmp.mapping.preset.cmdline(),
				sources = cmp.config.sources({
					{ name = "path" },
				}, {
					{ name = "cmdline" },
				}),
			})
		end,
	},

	vim.keymap.set("n", "gd", ":lua vim.lsp.buf.definition()<CR>", {}),
	vim.keymap.set("n", "gD", ":lua vim.lsp.buf.declaration()<CR>", {}),
	vim.keymap.set("n", "K", ":lua vim.lsp.buf.hover()<CR>", {}),
	vim.keymap.set("n", "gi", ":lua vim.lsp.buf.implementation()<CR>", {}),
	vim.keymap.set("n", "<leader>rn", ":lua vim.lsp.buf.rename()<CR>", {}),
	vim.keymap.set("n", "<leader>ca", ":lua vim.lsp.buf.code_action()<CR>", {}),
	vim.keymap.set("n", "gr", ":lua vim.lsp.buf.references()<CR>", {}),
}
