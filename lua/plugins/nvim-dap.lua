return {
	{
		"mfussenegger/nvim-dap",
		dependencies = {
			"rcarriga/nvim-dap-ui",
			"nvim-neotest/nvim-nio",
			"leoluz/nvim-dap-go",
			"theHamsta/nvim-dap-virtual-text", -- Show variable values inline
		},
		config = function()
			local dap = require("dap")
			local dapui = require("dapui")

			-- Setup nvim-dap-go (Go debugging)
			require("dap-go").setup({
				delve = {
					path = "dlv", -- Make sure you have: go install github.com/go-delve/delve/cmd/dlv@latest
					initialize_timeout_sec = 20,
					port = "${port}",
					args = { "--check-go-version=false" },
					build_flags = "", -- Add build tags if needed: "-tags=unit,integration"
					detached = vim.fn.has("win32") == 0, -- false for Windows, true for Linux/Mac
				},
			})

			-- Setup DAP UI
			dapui.setup({
				layouts = {
					{
						elements = {
							{ id = "scopes", size = 0.33 },
							{ id = "breakpoints", size = 0.17 },
							{ id = "stacks", size = 0.25 },
							{ id = "watches", size = 0.25 },
						},
						size = 0.33,
						position = "right",
					},
					{
						elements = {
							{ id = "repl", size = 0.45 },
							{ id = "console", size = 0.55 },
						},
						size = 0.27,
						position = "bottom",
					},
				},
			})

			-- Setup virtual text (show variable values inline)
			require("nvim-dap-virtual-text").setup({
				enabled = true,
				enabled_commands = true,
				highlight_changed_variables = true,
				highlight_new_as_changed = false,
				show_stop_reason = true,
				commented = false,
			})

			-- Auto-open/close UI when debugging starts/ends
			dap.listeners.after.event_initialized["dapui_config"] = function()
				dapui.open({})
			end
			dap.listeners.before.event_terminated["dapui_config"] = function()
				dapui.close({})
			end
			dap.listeners.before.event_exited["dapui_config"] = function()
				dapui.close({})
			end

			-- DEBUGGING KEYMAPS
			-- Basic debugging controls
			vim.keymap.set("n", "<F5>", dap.continue, { desc = "Debug: Start/Continue" })
			vim.keymap.set("n", "<F10>", dap.step_over, { desc = "Debug: Step Over" })
			vim.keymap.set("n", "<F11>", dap.step_into, { desc = "Debug: Step Into" })
			vim.keymap.set("n", "<F12>", dap.step_out, { desc = "Debug: Step Out" })

			-- Breakpoint management
			vim.keymap.set("n", "<leader>b", dap.toggle_breakpoint, { desc = "Debug: Toggle Breakpoint" })
			vim.keymap.set("n", "<leader>B", function()
				dap.set_breakpoint(vim.fn.input("Breakpoint condition: "))
			end, { desc = "Debug: Set Conditional Breakpoint" })

			-- Debug UI
			vim.keymap.set("n", "<F7>", dapui.toggle, { desc = "Debug: Toggle UI" })
			vim.keymap.set("n", "<leader>dr", dap.repl.open, { desc = "Debug: Open REPL" })
			vim.keymap.set("n", "<leader>dt", dap.terminate, { desc = "Debug: Terminate" })

			-- Go-specific debug keymaps
			vim.keymap.set("n", "<leader>dgt", function()
				require("dap-go").debug_test()
			end, { desc = "Debug: Go Test at Cursor" })

			vim.keymap.set("n", "<leader>dgl", function()
				require("dap-go").debug_last_test()
			end, { desc = "Debug: Last Go Test" })

			-- ADDITIONAL DEBUG COMMANDS (use with :lua command)
			--
			-- Debug current file's main function:
			-- :lua require('dap-go').debug_test()
			--
			-- Set conditional breakpoint:
			-- :lua require('dap').set_breakpoint(vim.fn.input('Breakpoint condition: '))
			--
			-- Clear all breakpoints:
			-- :lua require('dap').clear_breakpoints()
			--
			-- List all breakpoints:
			-- :lua require('dap').list_breakpoints()
			--
			-- TIPS:
			-- 1. Set breakpoints with <leader>b before starting debug
			-- 2. Use F5 to start debugging
			-- 3. Use F10/F11/F12 to step through code
			-- 4. Variable values show inline when debugging
			-- 5. Use <leader>dgt to debug the test under cursor
			-- 6. Debug UI opens automatically when debugging starts
			-- 7. Make sure 'dlv' is in your PATH: go install github.com/go-delve/delve/cmd/dlv@latest
		end,
	},
}