vim.api.nvim_create_autocmd("PackChanged", {
    callback = function(ev)
        if ev.data.spec.name == "nvim-treesitter" and ev.data.kind == "update" then
            if not ev.data.active then
                vim.cmd.packadd("nvim-treesitter")
            end
            vim.cmd("TSUpdate")
        end
    end,
})

local function gh(repo)
    return "https://github.com/" .. repo
end

vim.pack.add({
    gh("folke/tokyonight.nvim"),           -- ui.lua
    gh("nvim-mini/mini.nvim"),             -- ui.lua, git.lua
    gh("nvim-treesitter/nvim-treesitter"), -- treesitter.lua
    gh("neovim/nvim-lspconfig"),           -- lsp.lua
    gh("hrsh7th/nvim-cmp"),                -- completion.lua
    gh("hrsh7th/cmp-nvim-lsp"),            -- completion.lua, lsp.lua
    gh("hrsh7th/cmp-buffer"),              -- completion.lua
    gh("hrsh7th/cmp-path"),                -- completion.lua
    gh("nvim-lua/plenary.nvim"),           -- needed by telescope
    gh("nvim-telescope/telescope.nvim"),   -- telescope.lua
    gh("folke/trouble.nvim"),              -- tools.lua
    gh("mbbill/undotree"),                 -- tools.lua
})
