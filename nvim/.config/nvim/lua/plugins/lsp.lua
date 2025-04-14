require("mason").setup()
require("mason-lspconfig").setup()
require("fidget").setup({})

require("mason-lspconfig").setup {
    ensure_installed = {
        -- "astro",
        "bashls",
        "clangd",
        -- "dockerls",
        "eslint",
        -- "elixirls"
        "gopls",
        "html",
        -- "htmx",
        -- "hls",
        -- "jsonls",
        "ts_ls",
        "marksman",
        -- "nil_ls",
        -- "ocamllsp",
        -- "sqls",
        -- "pyright",
        "rust_analyzer",
        "lua_ls",
        "zls",
        "cssls",
        "marksman",
        -- "yamlls",
    },
    handlers = {
        function(server_name)
            require("lspconfig")[server_name].setup {}
        end,

        ["lua_ls"] = function()
            local lspconfig = require("lspconfig")
            lspconfig.lua_ls.setup {
                settings = {
                    Lua = {
                        diagnostics = {
                            globals = { "vim" }
                        }
                    }
                }
            }
        end
    }
}

-- Set up lspconfig.
local capabilities = require("cmp_nvim_lsp").default_capabilities()
-- local lspconfig = require("lspconfig").diagnostics { globals = { "vim" } }
require("lspconfig")["ts_ls"].setup { capabilities = capabilities }
