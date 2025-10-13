-- Auto-detect and switch Python venv when changing directories

local M = {}

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
			-- Remove trailing newline
			return result:gsub("%s+$", "")
		end
	end
	return nil
end

-- Function to find venv in directory
local function find_venv_in_dir(dir)
	if not dir then
		return nil
	end

	-- First, check if this is a Poetry project
	if is_poetry_project(dir) then
		local poetry_venv = get_poetry_venv(dir)
		if poetry_venv then
			vim.notify("Found Poetry virtualenv: " .. poetry_venv, vim.log.levels.INFO)
			return poetry_venv
		end
	end

	-- Fall back to standard venv detection
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
	local venv_result = find_venv_in_dir(root_dir)

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