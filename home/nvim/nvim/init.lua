-- Entry point: Neovim runs this file first (needs Neovim 0.12+).
--
-- Each require() loads one file from lua/config/. The dot is a folder
-- separator: require("config.lsp") loads lua/config/lsp.lua.
-- Order matters: "plugins" must come before the files that configure plugins.
--
-- Programs expected on $PATH: git, ripgrep, the tree-sitter CLI, a C compiler,
-- and the language servers listed in lua/config/lsp.lua.

-- Leader keys first, before any file creates a <leader> mapping
vim.g.mapleader = " "
vim.g.maplocalleader = ","

require("config.options")    -- editor settings
require("config.keymaps")    -- core keymaps (no plugins)
require("config.plugins")    -- install + load plugins; everything below uses them
require("config.ui")         -- colorscheme
require("config.statusline") -- mode, git, file, diagnostics, servers
require("config.treesitter") -- syntax highlighting, indentation
require("config.lsp")        -- language servers, diagnostics, format
require("config.completion") -- nvim-cmp
require("config.telescope")  -- fuzzy finder
require("config.git")        -- git commands, diff signs
require("config.tools")      -- trouble, undotree
