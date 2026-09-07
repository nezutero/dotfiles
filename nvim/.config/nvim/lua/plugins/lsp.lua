return {
    "neovim/nvim-lspconfig",

    dependencies = {
        "williamboman/mason.nvim",
        "williamboman/mason-lspconfig.nvim",
        "hrsh7th/cmp-nvim-lsp",
        "j-hui/fidget.nvim",
    },

    config = function()
        require("mason").setup()
        require("mason-lspconfig").setup({
            ensure_installed = {
                "pyright",
                "clangd",
                "jdtls",
                "lua_ls",
                "gopls",
                "html",
                "cssls",
                "rust_analyzer",
                "zls",
                "bashls",
            },
            automatic_installation = true,
        })

        local capabilities =
            require("cmp_nvim_lsp").default_capabilities()

        local servers = {
            pyright = {},

            clangd = {
                cmd = {
                    "clangd",
                    "--background-index",
                    "--query-driver=/run/current-system/sw/bin/*",
                },
            },

            jdtls = {},

            lua_ls = {
                settings = {
                    Lua = {
                        diagnostics = {
                            globals = { "vim" },
                        },
                    },
                },
            },

            gopls = {},

            html = {},

            cssls = {},

            rust_analyzer = {},

            zls = {},

            bashls = {},
        }

        for server, opts in pairs(servers) do
            opts.capabilities = capabilities
            vim.lsp.config(server, opts)
            vim.lsp.enable(server)
        end

        vim.api.nvim_create_autocmd("LspAttach", {
            callback = function(ev)
                local opts = { buffer = ev.buf, silent = true }

                vim.keymap.set("n", "gd", vim.lsp.buf.definition, opts)
                vim.keymap.set("n", "gD", vim.lsp.buf.declaration, opts)
                vim.keymap.set("n", "gr", vim.lsp.buf.references, opts)
                vim.keymap.set("n", "gi", vim.lsp.buf.implementation, opts)
                vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)
                vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, opts)
                vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, opts)
                vim.keymap.set("n", "<leader>e", vim.diagnostic.open_float, opts)
                vim.keymap.set("n", "[d", vim.diagnostic.goto_prev, opts)
                vim.keymap.set("n", "]d", vim.diagnostic.goto_next, opts)
                vim.keymap.set("i", "<C-k>", vim.lsp.buf.signature_help, opts)
            end,
        })
    end,
}
