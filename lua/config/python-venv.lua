-- Auto-detect and switch Python venv when changing directories

local M = {}

-- Function to find venv in directory
local function find_venv_in_dir(dir)
	if not dir then
		return nil
	end

	for _, venv_name in ipairs({ "venv", ".venv", "env", ".env" }) do
		local venv_path = dir .. "/" .. venv_name
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

-- Update Pyright configuration with new venv
local function update_pyright_venv(root_dir)
	local venv_name = find_venv_in_dir(root_dir)

	for _, client in ipairs(vim.lsp.get_clients()) do
		if client.name == "pyright" then
			if venv_name then
				client.config.settings.python.venvPath = root_dir
				client.config.settings.python.venv = venv_name
				client.notify("workspace/didChangeConfiguration", { settings = client.config.settings })
				vim.notify("Switched to venv: " .. root_dir .. "/" .. venv_name, vim.log.levels.INFO)
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