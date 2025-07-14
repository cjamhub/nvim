return {
    'akinsho/toggleterm.nvim',
    version = "*",
    config = function()
        require('toggleterm').setup({
            size = 20,
            open_mapping = [[<c-\>]],
            hide_numbers = true,
            shade_filetypes = {},
            shade_terminals = true,
            shading_factor = 2,
            start_in_insert = true,
            insert_mappings = true,
            persist_size = true,
            direction = 'float',
            close_on_exit = true,
            shell = vim.o.shell,
            float_opts = {
                border = 'curved',
                winblend = 0,
                highlights = {
                    border = "Normal",
                    background = "Normal",
                },
            },
        })

        local map = vim.keymap.set
        map('n', '<C-/>', '<cmd>ToggleTerm direction=float<cr>', { desc = 'Toggle floating terminal' })
        map('t', '<C-/>', '<C-\\><C-n><cmd>ToggleTerm direction=float<cr>', { desc = 'Toggle floating terminal' })

        -- map('n', '<leader>th', '<cmd>ToggleTerm size=10 direction=horizontal<cr>', { desc = 'Toggle horizontal terminal' })
        -- map('n', '<leader>tv', '<cmd>ToggleTerm size=80 direction=vertical<cr>', { desc = 'Toggle vertical terminal' })

        -- Terminal mode mappings
        -- map('t', '<esc>', '<c-\><c-n>', { desc = 'Exit terminal mode' })
        -- map('t', '<C-h>', '<c-\><c-n><c-w>h', { desc = 'Navigate left' })
        -- map('t', '<C-j>', '<c-\><c-n><c-w>j', { desc = 'Navigate down' })
        -- map('t', '<C-k>', '<c-\><c-n><c-w>k', { desc = 'Navigate up' })
        -- map('t', '<C-l>', '<c-\><c-n><c-w>l', { desc = 'Navigate right' })
    end,
}
