-- Test runner for Go, Python, Rust, and Solidity: <leader>t runs the test under the cursor
return {
	"vim-test/vim-test",
	config = function()
		local python_utils = require("utils.python")

		-- Configure vim-test
		vim.g["test#strategy"] = "neovim"

		-- Go configuration
		vim.g["test#go#runner"] = "gotest"
		vim.g["test#go#gotest#options"] = {
			nearest = "-v -race -count=1",
		}

		-- Python configuration
		vim.g["test#python#runner"] = "pytest"
		vim.g["test#python#pytest#options"] = "-v -s" -- -s shows print output

		-- Rust configuration (cargo finds Cargo.toml upward on its own, no lcd needed)
		vim.g["test#rust#runner"] = "cargotest"
		vim.g["test#rust#cargotest#options"] = "-- --nocapture"

		-- Solidity configuration (custom, see run_solidity_test below)
		vim.g["test#custom_runners"] = { solidity = { "forge" } }
		vim.g["test#solidity#forge#executable"] = "forge test"

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
			local cwd = vim.fn.getcwd()

			-- First, check if this is a Poetry project
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

		-- Function to run the nearest Solidity test with Foundry
		local function run_solidity_test()
			-- Find the contract name from file content
			local contract_name = nil
			local lines = vim.fn.getline(1, "$")
			for _, line in ipairs(lines) do
				local match = line:match("contract%s+(%w+)%s+is")
				if match then
					contract_name = match
					break
				end
			end

			-- Fallback to filename if contract not found
			if not contract_name then
				contract_name = vim.fn.expand("%:t:r") -- Get filename without extension
			end

			-- Find foundry.toml to ensure we're in project root
			local path = vim.fn.expand("%:p:h")
			while path ~= "/" do
				if vim.fn.filereadable(path .. "/foundry.toml") == 1 then
					vim.cmd("lcd " .. path)
					break
				end
				path = vim.fn.fnamemodify(path, ":h")
			end

			-- Search backwards from cursor to find the nearest function
			local current_line = vim.fn.line(".")
			local func_name = nil

			-- Search current line first
			local line_text = vim.fn.getline(current_line)
			func_name = line_text:match("function%s+(%w+)")

			-- If not found, search backwards
			if not func_name then
				for i = current_line - 1, 1, -1 do
					line_text = vim.fn.getline(i)
					func_name = line_text:match("function%s+(%w+)")
					if func_name then
						break
					end
					-- Stop if we hit another contract or reached too far
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

		-- Unified keymap that dispatches by filetype
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

		-- The output will show in a terminal split
		-- To close the output window, just use :q or <C-w>q
	end,
}
