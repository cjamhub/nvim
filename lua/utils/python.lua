local M = {}

function M.is_poetry_project(dir)
	local pyproject_path = dir .. "/pyproject.toml"
	if vim.fn.filereadable(pyproject_path) == 1 then
		local content = vim.fn.readfile(pyproject_path)
		for _, line in ipairs(content) do
			if line:match("%[tool%.poetry%]") or line:match("poetry%.core%.masonry") then
				return true
			end
		end
	end
	return false
end

function M.get_poetry_venv(dir)
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

-- Returns an absolute path for a Poetry venv, or a bare directory name
-- (e.g. "venv") for a standard one. Callers branch on result:match("^/").
function M.find_venv(dir)
	if not dir then
		return nil
	end

	if M.is_poetry_project(dir) then
		local poetry_venv = M.get_poetry_venv(dir)
		if poetry_venv then
			return poetry_venv
		end
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

return M
