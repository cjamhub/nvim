return {
    'phaazon/hop.nvim',
    branch = 'v2',
    config = function()
        require('hop').setup({
            keys = 'etovxqpdygfblzhckisuran'
        })

        vim.keymap.set('n', '<leader><leader>', function()
            require('hop').hint_words()
        end, { desc = 'Hop to word' })
    end,
    enabled = true
}