-- Test runner for Go, Python, Rust, and Solidity: <leader>t runs the test under the cursor
return {
	"vim-test/vim-test",
	config = function()
		local python_utils = require("utils.python")

		vim.g["test#strategy"] = "neovim"

		vim.g["test#go#runner"] = "gotest"
		vim.g["test#go#gotest#options"] = {
			nearest = "-v -race -count=1",
		}

		vim.g["test#python#runner"] = "pytest"
		vim.g["test#python#pytest#options"] = "-v -s" -- -s shows print output

		-- cargo finds Cargo.toml upward on its own, no lcd needed
		vim.g["test#rust#runner"] = "cargotest"
		vim.g["test#rust#cargotest#options"] = "-- --nocapture"

		-- custom runner, see run_solidity_test below
		vim.g["test#custom_runners"] = { solidity = { "forge" } }
		vim.g["test#solidity#forge#executable"] = "forge test"

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

		local function setup_python_test()
			local cwd = vim.fn.getcwd()

			if python_utils.is_poetry_project(cwd) then
				local poetry_venv = python_utils.get_poetry_venv(cwd)
				if poetry_venv then
					local poetry_pytest = poetry_venv .. "/bin/pytest"
					if vim.fn.executable(poetry_pytest) == 1 then
						vim.g["test#python#pytest#executable"] = poetry_pytest
						return
					end
				end
			end

			if vim.env.VIRTUAL_ENV then
				vim.g["test#python#pytest#executable"] = vim.env.VIRTUAL_ENV .. "/bin/pytest"
			else
				local venv_paths = { "venv/bin/pytest", ".venv/bin/pytest", "env/bin/pytest" }
				for _, venv_path in ipairs(venv_paths) do
					if vim.fn.executable(venv_path) == 1 then
						vim.g["test#python#pytest#executable"] = venv_path
						return
					end
				end
				vim.g["test#python#pytest#executable"] = "pytest"
			end
		end

		local function run_solidity_test()
			local contract_name = nil
			local lines = vim.fn.getline(1, "$")
			for _, line in ipairs(lines) do
				local match = line:match("contract%s+(%w+)%s+is")
				if match then
					contract_name = match
					break
				end
			end
			if not contract_name then
				contract_name = vim.fn.expand("%:t:r")
			end

			local path = vim.fn.expand("%:p:h")
			while path ~= "/" do
				if vim.fn.filereadable(path .. "/foundry.toml") == 1 then
					vim.cmd("lcd " .. path)
					break
				end
				path = vim.fn.fnamemodify(path, ":h")
			end

			local current_line = vim.fn.line(".")
			local func_name = nil

			local line_text = vim.fn.getline(current_line)
			func_name = line_text:match("function%s+(%w+)")

			if not func_name then
				for i = current_line - 1, 1, -1 do
					line_text = vim.fn.getline(i)
					func_name = line_text:match("function%s+(%w+)")
					if func_name then
						break
					end
					-- stop at the enclosing contract or after 50 lines
					if line_text:match("contract%s+") or (current_line - i) > 50 then
						break
					end
				end
			end

			local cmd
			if func_name then
				cmd = "forge test --match-test " .. func_name .. " -vvvv"
			else
				cmd = "forge test --match-contract " .. contract_name .. " -vvvv"
			end

			vim.cmd("split | terminal " .. cmd)
		end

		local function run_nearest_test()
			local filetype = vim.bo.filetype
			if filetype == "go" then
				setup_go_test_dir()
				vim.cmd("TestNearest")
			elseif filetype == "python" then
				setup_python_test()
				vim.cmd("TestNearest")
			elseif filetype == "rust" then
				vim.cmd("TestNearest")
			elseif filetype == "solidity" then
				run_solidity_test()
			end
		end

		vim.keymap.set("n", "<leader>t", run_nearest_test, { desc = "Run nearest test", silent = true })
	end,
}
