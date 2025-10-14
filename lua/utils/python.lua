-- Shared Python utility functions for venv and Poetry detection

local M = {}

-- Function to check if this is a Poetry project
function M.is_poetry_project(dir)
	local pyproject_path = dir .. "/pyproject.toml"
	if vim.fn.filereadable(pyproject_path) == 1 then
		local content = vim.fn.readfile(pyproject_path)
		for _, line in ipairs(content) do
			-- Check for either [tool.poetry] or poetry in build-backend
			if line:match("%[tool%.poetry%]") or line:match("poetry%.core%.masonry") then
				return true
			end
		end
	end
	return false
end

-- Function to get Poetry virtualenv path
function M.get_poetry_venv(dir)
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

-- Function to find venv in directory (returns full path for Poetry, relative name for standard venv)
function M.find_venv(dir)
	if not dir then
		return nil
	end

	-- First, check if this is a Poetry project
	if M.is_poetry_project(dir) then
		local poetry_venv = M.get_poetry_venv(dir)
		if poetry_venv then
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

return M
