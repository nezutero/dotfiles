return {
    "nvim-telescope/telescope.nvim",

    dependencies = {
        "nvim-lua/plenary.nvim",
    },

    config = function()
        local builtin = require("telescope.builtin")
        local telescope = require("telescope")

        telescope.setup({
            defaults = {
                vimgrep_arguments = {
                    "rg",
                    "--follow",
                    "--hidden",
                    "--no-heading",
                    "--with-filename",
                    "--line-number",
                    "--column",
                    "--smart-case",

                    "--glob=!**/.git/**",
                    "--glob=!**/.idea/**",
                    "--glob=!**/.vscode/**",
                    "--glob=!**/build/**",
                    "--glob=!**/dist/**",
                },

                prompt_prefix = " > ",
                file_sorter = require("telescope.sorters").get_fzy_sorter,
                file_previewer = require("telescope.previewers").vim_buffer_cat.new,

                layout_strategy = "horizontal",
                layout_config = {
                    width = 0.6,
                    height = 0.8,
                },
            },

            pickers = {
                find_files = {
                    hidden = true,
                    previewer = true,
                    find_command = {
                        "rg",
                        "--files",
                        "--hidden",
                        "--glob=!**/.git/**",
                        "--glob=!**/.idea/**",
                        "--glob=!**/.vscode/**",
                        "--glob=!**/build/**",
                        "--glob=!**/dist/**",
                    },
                },
            },
        })

        vim.cmd([[
            hi TelescopeBorder guifg=Grey guibg=NONE ctermfg=Grey ctermbg=NONE
            hi TelescopePrompt guifg=Grey guibg=NONE ctermfg=Grey ctermbg=NONE
            hi TelescopeResults guifg=Grey guibg=NONE ctermfg=Grey ctermbg=NONE
            hi TelescopePreviewBorder guifg=Grey guibg=NONE ctermfg=Grey ctermbg=NONE
            hi TelescopeSelection guifg=Grey guibg=NONE ctermfg=Grey ctermbg=NONE
            hi TelescopeSelectionCaret guifg=Grey guibg=NONE ctermfg=Grey ctermbg=NONE

            hi Normal guibg=NONE ctermbg=NONE
            hi SignColumn guibg=NONE ctermbg=NONE
            hi NormalNC guibg=NONE ctermbg=NONE
            hi VertSplit guibg=NONE ctermbg=NONE
            hi StatusLine guibg=NONE ctermbg=NONE
            hi StatusLineNC guibg=NONE ctermbg=NONE
        ]])

        vim.cmd("hi! link TelescopeNormal Normal")
        vim.cmd("hi! link TelescopeResultsLine Normal")
        vim.cmd("hi! link TelescopePreviewBorder TelescopeNormal")
        vim.cmd("hi! link TelescopePromptBorder TelescopeNormal")
        vim.cmd("hi! link TelescopeSelection TelescopeNormal")
        vim.cmd("hi! link TelescopeSelectionCaret TelescopeNormal")
        vim.cmd("hi! link TelescopeMultiSelection TelescopeNormal")

        vim.keymap.set("n", "<leader>ff", builtin.find_files)
        vim.keymap.set("n", "<leader>fh", builtin.help_tags)
        vim.keymap.set("n", "<leader>fg", builtin.live_grep)
        vim.keymap.set("n", "<C-p>", builtin.git_files)
    end,
}
