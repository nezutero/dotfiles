local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
    vim.fn.system({
        "git", "clone", "--filter=blob:none",
        "https://github.com/folke/lazy.nvim.git", "--branch=stable",
        lazypath
    })
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup({
    {
        "nvim-telescope/telescope.nvim",
        dependencies = { "nvim-lua/plenary.nvim" }
    },
    { "rebelot/kanagawa.nvim" },
    {
        "nvim-treesitter/nvim-treesitter",
        build = ":TSUpdate",
    },
    { "neovim/nvim-lspconfig" },
    { "hrsh7th/cmp-nvim-lsp" },
    { "hrsh7th/cmp-nvim-lua" },
    { "hrsh7th/cmp-buffer" },
    { "hrsh7th/cmp-path" },
    { "tpope/vim-fugitive" },
    { "L3MON4D3/LuaSnip" },
    { "saadparwaiz1/cmp_luasnip" },
    { "hrsh7th/cmp-cmdline" },
    { "hrsh7th/nvim-cmp" },
    {
        "williamboman/mason-lspconfig.nvim",
        dependencies = {
            "williamboman/mason.nvim",
            "neovim/nvim-lspconfig",
            "j-hui/fidget.nvim",
        }
    },
    {
        "folke/trouble.nvim",
        dependencies = {
            "nvim-tree/nvim-web-devicons"
        },
        opts = {},
        cmd = "Trouble",
        keys = {
            {
                "<leader>xx",
                "<cmd>Trouble diagnostics toggle<cr>",
                desc = "Diagnostics (Trouble)",
            },
            {
                "<leader>xX",
                "<cmd>Trouble diagnostics toggle filter.buf=0<cr>",
                desc = "Buffer Diagnostics (Trouble)",
            },
            {
                "<leader>cs",
                "<cmd>Trouble symbols toggle focus=false<cr>",
                desc = "Symbols (Trouble)",
            },
            {
                "<leader>cl",
                "<cmd>Trouble lsp toggle focus=false win.position=right<cr>",
                desc = "LSP Definitions / references / ... (Trouble)",
            },
            {
                "<leader>xL",
                "<cmd>Trouble loclist toggle<cr>",
                desc = "Location List (Trouble)",
            },
            {
                "<leader>xQ",
                "<cmd>Trouble qflist toggle<cr>",
                desc = "Quickfix List (Trouble)",
            },
        },
    },
    { "lewis6991/gitsigns.nvim" },
    {
        "ThePrimeagen/harpoon",
        branch = "harpoon2",
        dependencies = { "nvim-lua/plenary.nvim" }
    },
    {
        "nvim-lualine/lualine.nvim",
        dependencies = {
            "nvim-tree/nvim-web-devicons",
            "linrongbin16/lsp-progress.nvim"
        },
    },
    { "nvim-tree/nvim-web-devicons" },
    { "hrsh7th/cmp-nvim-lsp-signature-help" }, {
    "linrongbin16/lsp-progress.nvim",
    event = { "VimEnter" },
    dependencies = { "nvim-tree/nvim-web-devicons" },
    {
        "lukas-reineke/indent-blankline.nvim",
        main = "ibl",
        ---@module "ibl"
        ---@type ibl.config
        opts = {},
    },
    config = function() require("lsp-progress").setup() end
},
    {
        "norcalli/nvim-colorizer.lua",
        config = function() require("colorizer").setup() end

    },
    { "mbbill/undotree" },
    {
        "hedyhli/markdown-toc.nvim",
        ft = "markdown",
        cmd = { "Mtoc" },
        opts = {
            toc_list = {
                markers = '1.',
            },
        },
    },
    {
        "folke/zen-mode.nvim",
        config = function()
            require("zen-mode").setup({
                window = {
                    backdrop = 1,
                    width = 90,
                    height = 1,
                    padding = {
                        left = 0,
                        right = 0,
                    },
                    options = {
                        number = false,
                        relativenumber = false,
                        signcolumn = "no",
                        foldcolumn = "0",
                        list = false,
                    }
                },
                plugins = {
                    twilight = { enabled = false },
                    gitsigns = { enabled = false },
                    tmux = { enabled = false },
                    kitty = { enabled = false },
                    alacritty = {
                        enabled = true,
                        font = "16",
                    },
                },
                on_open = function()
                    vim.api.nvim_set_hl(0, 'ZenBg', { bg = 'NONE' })
                end,
            })
        end
    },
})
