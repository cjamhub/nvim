local python_utils = require("utils.python")

local function update_pyright_venv(root_dir)
	local venv_result = python_utils.find_venv(root_dir)

	for _, client in ipairs(vim.lsp.get_clients()) do
		if client.name == "pyright" then
			if venv_result then
				if venv_result:match("^/") then
					client.config.settings.python.pythonPath = venv_result .. "/bin/python"
					client.notify("workspace/didChangeConfiguration", { settings = client.config.settings })
					vim.notify("Switched to Poetry venv: " .. venv_result, vim.log.levels.INFO)
				else
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

vim.api.nvim_create_user_command("PythonSetVenv", function()
	update_pyright_venv(vim.fn.getcwd())
end, { desc = "Refresh Python venv detection" })

vim.api.nvim_create_autocmd("DirChanged", {
	pattern = "*",
	callback = function()
		if vim.bo.filetype == "python" then
			update_pyright_venv(vim.fn.getcwd())
		end
	end,
})

vim.keymap.set("n", "<leader>pv", "<cmd>PythonSetVenv<cr>", { desc = "Refresh Python venv" })
