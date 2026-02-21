vim.env._JAVA_OPTIONS = "-Djdk.xml.totalEntitySizeLimit=0 -Djdk.xml.entityExpansionLimit=0"

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
            vim.lsp.enable(server_name)
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
            vim.lsp.enable('lua_ls')
        end,

        ["ts_ls"] = function()
            vim.lsp.config.ts_ls = {
                capabilities = require("cmp_nvim_lsp").default_capabilities(),
            }
            vim.lsp.enable('ts_ls')
        end,

        ["ltex"] = function()
            vim.lsp.config.ltex = {
                capabilities = require("cmp_nvim_lsp").default_capabilities(),
                filetypes = { "markdown", "md", "tex", "text" },
                flags = { debounce_text_changes = 300 },
                settings = {
                    ltex = {
                        language = "fr",
                        sentenceCacheSize = 2000,
                        additionalRules = {
                            enablePickyRules = true,
                            motherTongue = "fr",
                        },
                        trace = { server = "verbose" },
                        disabledRules = {},
                        hiddenFalsePositives = {},
                    }
                },
                on_attach = on_attach,
            }
        end,
    }
}
