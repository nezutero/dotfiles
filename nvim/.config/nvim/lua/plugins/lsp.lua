require("mason").setup()
require("mason-lspconfig").setup()
require("fidget").setup({})

require("mason-lspconfig").setup {
    ensure_installed = {
        "bashls",
        "clangd",
        "eslint",
        "gopls",
        "html",
        "ts_ls",
        "marksman",
        "rust_analyzer",
        "lua_ls",
        "zls",
        "cssls",
    },
    handlers = {
        function(server_name)
            vim.lsp.config[server_name] = {
                capabilities = require("cmp_nvim_lsp").default_capabilities(),
            }
        end,

        ["lua_ls"] = function()
            vim.lsp.config.lua_ls = {
                capabilities = require("cmp_nvim_lsp").default_capabilities(),
                settings = {
                    Lua = {
                        diagnostics = {
                            globals = { "vim" }
                        }
                    }
                }
            }
        end,

        ["ts_ls"] = function()
            vim.lsp.config.ts_ls = {
                capabilities = require("cmp_nvim_lsp").default_capabilities(),
            }
        end,
    }
}
