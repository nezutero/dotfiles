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
        "ltex",
    },
    handlers = {
        -- Default handler for all servers
        function(server_name)
            vim.lsp.config[server_name] = {
                capabilities = require("cmp_nvim_lsp").default_capabilities(),
            }
        end,

        -- Lua
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

        -- TS
        ["ts_ls"] = function()
            vim.lsp.config.ts_ls = {
                capabilities = require("cmp_nvim_lsp").default_capabilities(),
            }
        end,

        -- LTeX with custom dictionary
        ["ltex"] = function()
            -- Read spell words from file
            local spell_words = {}
            local dict_path = vim.fn.stdpath("config") .. "/spell/en.utf-8.add"
            local file = io.open(dict_path, "r")
            if file then
                for word in file:lines() do
                    table.insert(spell_words, word)
                end
                file:close()
            end

            vim.lsp.config.ltex = {
                capabilities = require("cmp_nvim_lsp").default_capabilities(),
                settings = {
                    ltex = {
                        language = "en-US",
                        enabled = true,
                        dictionary = {
                            ["en-US"] = spell_words,
                        },
                    },
                },
            }
        end,
    }
}
