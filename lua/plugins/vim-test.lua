-- Lightweight test runner for Go
return {
	"vim-test/vim-test",
	config = function()
		-- Configure vim-test for Go
		vim.g["test#strategy"] = "neovim"
		vim.g["test#go#runner"] = "gotest"
		vim.g["test#go#gotest#options"] = "-v -race -count=1"

		-- Function to find and change to go.mod directory
		local function setup_go_test_dir()
			local path = vim.fn.expand("%:p:h")
			while path ~= "/" do
				if vim.fn.filereadable(path .. "/go.mod") == 1 then
					-- Change vim's working directory to where go.mod is
					vim.cmd("lcd " .. path)

					-- Check if .env.test exists in the same directory as go.mod
					if vim.fn.filereadable(".env.test") == 1 then
						-- Load .env.test before running tests
						vim.g["test#go#gotest#executable"] = "set -a; . ./.env.test; set +a; go test"
					else
						-- No .env.test, just use standard go test
						vim.g["test#go#gotest#executable"] = "go test"
					end
					return
				end
				path = vim.fn.fnamemodify(path, ":h")
			end
		end

		-- Simple keymaps that will definitely work
		vim.keymap.set("n", ",t", function()
			setup_go_test_dir()
			vim.cmd("TestNearest")
		end, { desc = "Run nearest test", silent = true })

		vim.keymap.set("n", ",T", function()
			setup_go_test_dir()
			vim.cmd("TestFile")
		end, { desc = "Run all tests in file", silent = true })
		-- vim.keymap.set("n", ",a", ":TestSuite<CR>", { desc = "Run all tests", silent = true })
		-- vim.keymap.set("n", ",l", ":TestLast<CR>", { desc = "Run last test", silent = true })

		-- The output will show in a terminal split
		-- To close the output window, just use :q or <C-w>q
	end,
}

