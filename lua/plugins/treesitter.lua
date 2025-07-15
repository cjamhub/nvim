return {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    opts = {
        ensure_installed = {
            "lua",
            "python",
            "javascript",
            "typescript",
            "rust",
            "go",
            "markdown",
            "circom",
            "solidity",
        },
        highlight = {
            enable = true
        },
        auto_install = true,
    },
    config = function(_, opts)
        require('nvim-treesitter.configs').setup(opts)
    end,
}
