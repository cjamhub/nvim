-- Auto-detect and switch Python venv when changing directories

local M = {}
local python_utils = require("utils.python")

-- Update Pyright configuration with new venv
local function update_pyright_venv(root_dir)
	local venv_result = python_utils.find_venv(root_dir)

	for _, client in ipairs(vim.lsp.get_clients()) do
		if client.name == "pyright" then
			if venv_result then
				-- Check if it's a full path (Poetry) or just a name (standard venv)
				if venv_result:match("^/") then
					-- Full path (Poetry virtualenv)
					client.config.settings.python.pythonPath = venv_result .. "/bin/python"
					client.notify("workspace/didChangeConfiguration", { settings = client.config.settings })
					vim.notify("Switched to Poetry venv: " .. venv_result, vim.log.levels.INFO)
				else
					-- Relative path (standard venv)
					client.config.settings.python.venvPath = root_dir
					client.config.settings.python.venv = venv_result
					client.notify("workspace/didChangeConfiguration", { settings = client.config.settings })
					vim.notify("Switched to venv: " .. root_dir .. "/" .. venv_result, vim.log.levels.INFO)
				end
			else
				vim.notify("No venv found in: " .. root_dir, vim.log.levels.WARN)
			end
			return
		end
	end
end

-- Command to manually refresh venv detection
vim.api.nvim_create_user_command("PythonSetVenv", function()
	local cwd = vim.fn.getcwd()
	update_pyright_venv(cwd)
end, { desc = "Refresh Python venv detection" })

-- Auto-detect venv when changing directory
vim.api.nvim_create_autocmd("DirChanged", {
	pattern = "*",
	callback = function()
		-- Only run for Python buffers
		if vim.bo.filetype == "python" then
			local new_dir = vim.fn.getcwd()
			update_pyright_venv(new_dir)
		end
	end,
})

-- Keymap for quick venv switch
vim.keymap.set("n", "<leader>pv", "<cmd>PythonSetVenv<cr>", { desc = "Refresh Python venv" })

return M