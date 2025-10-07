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

		-- Function to setup Python test with venv
		local function setup_python_test()
			-- If VIRTUAL_ENV is set, use venv's python
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
