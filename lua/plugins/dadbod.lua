return {
	{
		"tpope/vim-dadbod",
		cmd = {
			"DB",
			"DBUI",
			"DBUIToggle",
			"DBUIAddConnection",
			"DBUIFindBuffer",
		},
	},
	{
		"kristijanhusak/vim-dadbod-ui",
		dependencies = {
			"tpope/vim-dadbod",
			"kristijanhusak/vim-dadbod-completion",
		},
		cmd = {
			"DBUI",
			"DBUIToggle",
			"DBUIAddConnection",
			"DBUIFindBuffer",
		},
		init = function()
			vim.g.db_ui_use_nerd_fonts = 1
			vim.g.db_ui_auto_execute_table_helpers = 1
			vim.g.db_ui_hide_schemas = { "information_schema", "mysql" }
		end,
		config = function()
			local connections_file = vim.fn.stdpath("config") .. "/db-connections.lua"
			if vim.fn.filereadable(connections_file) == 1 then
				local ok, connections = pcall(dofile, connections_file)
				if not ok then
					vim.notify(
						"Error loading database connections: " .. connections,
						vim.log.levels.ERROR
					)
				elseif type(connections) == "table" then
					vim.g.dbs = vim.tbl_deep_extend("force", vim.g.dbs or {}, connections)
				else
					vim.notify(
						"`" .. connections_file .. "` must return a table of connections",
						vim.log.levels.WARN
					)
				end
			end

			local map = function(lhs, rhs, desc)
				vim.keymap.set("n", lhs, rhs, { desc = desc })
			end

			map("<leader>db", "<cmd>DBUIToggle<CR>", "Toggle database UI")
			map("<leader>df", "<cmd>DBUIFindBuffer<CR>", "Find database buffer")
			map("<leader>da", "<cmd>DBUIAddConnection<CR>", "Add database connection")
		end,
	},
	{
		"kristijanhusak/vim-dadbod-completion",
		ft = { "sql", "mysql", "plsql" },
		dependencies = { "tpope/vim-dadbod" },
	},
}
