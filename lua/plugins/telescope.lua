return {
    'nvim-telescope/telescope.nvim', tag = '0.1.8',
    dependencies = {
        'nvim-lua/plenary.nvim',
        'nvim-telescope/telescope-fzf-native.nvim',
        build = 'make',          -- optional native FZF sorter
    },
    config = function()
        local telescope = require('telescope')

        telescope.setup {
            defaults = {
                path_display = { 'smart' }
            },
            extensions = {
                fzf = {
                    fuzzy = true,
                    override_generic_sorter = true,
                    override_file_sorter = true,
                }
            }
        }

        local map = vim.keymap.set
        map('n', '<leader>ff', require('telescope.builtin').find_files, { desc = 'Find Files' })
        map('n', '<leader>fg', require('telescope.builtin').live_grep,  { desc = 'Live Grep' })
        map('n', '<leader>fb', require('telescope.builtin').buffers,    { desc = 'Buffers' })
        map('n', '<leader>fh', require('telescope.builtin').help_tags,  { desc = 'Help Tags' })
        map('n', '<leader>fc', require('telescope.builtin').colorscheme,  { desc = 'Colorschemes' })
        map('n', '<leader>fx', require('telescope.builtin').diagnostics,  { desc = 'Diagnostics List' })
        map('n', '<leader>f.', require('telescope.builtin').oldfiles,  { desc = 'Old Files' })
    end
}
