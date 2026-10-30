-- Compiles each parser once into ~/.local/share/nvim/site/parser.
-- Parsers already installed are skipped, so this costs nothing on later starts.
require("nvim-treesitter").install({
    "bash", "c", "cpp", "css", "go", "gomod", "gosum", "gowork", "html",
    "java", "javascript", "json", "lua", "luadoc", "markdown", "markdown_inline",
    "nix", "python", "query", "rust", "toml", "tsx", "typescript", "vim",
    "vimdoc", "yaml", "zig",
})

vim.api.nvim_create_autocmd("FileType", {
    callback = function(args)
        if pcall(vim.treesitter.start, args.buf) then
            vim.bo[args.buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
        end
    end,
})
