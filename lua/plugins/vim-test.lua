-- Lightweight test runner for Go and Python
return {
	"vim-test/vim-test",
	config = function()
		-- Configure vim-test
		vim.g["test#strategy"] = "neovim"

		-- Go configuration
		vim.g["test#go#runner"] = "gotest"
		vim.g["test#go#gotest#options"] = "-v -race -count=1"

		-- Python configuration
		vim.g["test#python#runner"] = "pytest"
		vim.g["test#python#pytest#options"] = "-v -s" -- -s shows print output

		-- Function to find and change to go.mod directory
		local function setup_go_test_dir()
			local path = vim.fn.expand("%:p:h")
			while path ~= "/" do
				if vim.fn.filereadable(path .. "/go.mod") == 1 then
					vim.cmd("lcd " .. path)
					if vim.fn.filereadable(".env") == 1 then
						vim.g["test#go#gotest#executable"] = "set -a; . ./.env; set +a; go test"
					else
						vim.g["test#go#gotest#executable"] = "go test"
					end
					return
				end
				path = vim.fn.fnamemodify(path, ":h")
			end
		end

		-- Function to check if this is a Poetry project
		local function is_poetry_project()
			local pyproject_path = vim.fn.getcwd() .. "/pyproject.toml"
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

		-- Function to get Poetry pytest executable
		local function get_poetry_pytest()
			local handle = io.popen("poetry env info --path 2>/dev/null")
			if handle then
				local result = handle:read("*a")
				handle:close()
				if result and result ~= "" then
					local venv_path = result:gsub("%s+$", "")
					return venv_path .. "/bin/pytest"
				end
			end
			return nil
		end

		-- Function to setup Python test with venv
		local function setup_python_test()
			-- First, check if this is a Poetry project
			if is_poetry_project() then
				local poetry_pytest = get_poetry_pytest()
				if poetry_pytest and vim.fn.executable(poetry_pytest) == 1 then
					vim.g["test#python#pytest#executable"] = poetry_pytest
					return
				end
			end

			-- If VIRTUAL_ENV is set, use venv's pytest
			if vim.env.VIRTUAL_ENV then
				vim.g["test#python#pytest#executable"] = vim.env.VIRTUAL_ENV .. "/bin/pytest"
			else
				-- Try to find local venv
				local venv_paths = { "venv/bin/pytest", ".venv/bin/pytest", "env/bin/pytest" }
				for _, venv_path in ipairs(venv_paths) do
					if vim.fn.executable(venv_path) == 1 then
						vim.g["test#python#pytest#executable"] = venv_path
						return
					end
				end
				-- Fallback to system pytest
				vim.g["test#python#pytest#executable"] = "pytest"
			end
		end

		-- Unified test keymaps that work for both Go and Python
		vim.keymap.set("n", ",t", function()
			local filetype = vim.bo.filetype
			if filetype == "go" then
				setup_go_test_dir()
			elseif filetype == "python" then
				setup_python_test()
			end
			vim.cmd("TestNearest")
		end, { desc = "Run nearest test", silent = true })

		vim.keymap.set("n", ",T", function()
			local filetype = vim.bo.filetype
			if filetype == "go" then
				setup_go_test_dir()
			elseif filetype == "python" then
				setup_python_test()
			end
			vim.cmd("TestFile")
		end, { desc = "Run all tests in file", silent = true })
		-- vim.keymap.set("n", ",a", ":TestSuite<CR>", { desc = "Run all tests", silent = true })
		-- vim.keymap.set("n", ",l", ":TestLast<CR>", { desc = "Run last test", silent = true })

		-- The output will show in a terminal split
		-- To close the output window, just use :q or <C-w>q
	end,
}
