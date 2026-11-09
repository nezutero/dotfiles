-- Language servers, diagnostics and formatting.
--
-- nvim-lspconfig only provides each server's default settings (command,
-- filetypes, root markers). vim.lsp.enable() is what actually starts them.
-- The servers themselves are separate programs that must be on $PATH.

-- Tell every server what nvim-cmp can handle (snippets, completion details)
vim.lsp.config("*", {
    capabilities = require("cmp_nvim_lsp").default_capabilities(),
})

vim.lsp.config("nil_ls", {
    settings = { ["nil"] = { nix = { flake = { autoArchive = true } } } },
})

vim.lsp.enable({
    "bashls",      -- bash-language-server
    "clangd",      -- C, C++
    "gopls",       -- Go
    "superhtml",   -- HTML
    "cssls",       -- CSS (vscode-css-language-server)
    "jdtls",       -- Java
    "rust_analyzer", -- Rust
    "zls",         -- Zig
    "marksman",    -- Markdown
    "lua_ls",      -- Lua
    "basedpyright", -- Python
    "ts_ls",       -- JavaScript, TypeScript
    "nil_ls",      -- Nix
})

-- Keymaps that only exist in buffers with a server attached
vim.api.nvim_create_autocmd("LspAttach", {
    callback = function(args)
        local function map(lhs, rhs, opts)
            vim.keymap.set("n", lhs, rhs, vim.tbl_extend("force", { buffer = args.buf }, opts or {}))
        end

        map("gd", vim.lsp.buf.definition)
        map("gD", vim.lsp.buf.declaration)
        -- nowait: Neovim also has built-in grn/grr/gra/gri/grt/grx mappings, and
        -- without this, gr would pause to see if you're typing one of them.
        map("gr", vim.lsp.buf.references, { nowait = true })
        map("gi", vim.lsp.buf.implementation)
        map("<leader>rn", vim.lsp.buf.rename)
        map("<leader>ca", vim.lsp.buf.code_action)
        -- Built in, no mapping needed: K (hover), [d / ]d (previous/next
        -- diagnostic), <C-s> in insert mode (signature help).
    end,
})

vim.keymap.set("n", "<leader>f", vim.lsp.buf.format)

-- Diagnostics (errors and warnings, from servers or other sources)
vim.diagnostic.config({
    update_in_insert = false,
    virtual_text = true,
    float = {
        focusable = false,
        style = "minimal",
        border = "rounded",
        source = true,
        header = "",
        prefix = "",
    },
})

vim.keymap.set("n", "<leader>e", vim.diagnostic.open_float)
