local function ignored()
    return {
        "--glob=!**/.git/**",
        "--glob=!**/.idea/**",
        "--glob=!**/.vscode/**",
        "--glob=!**/build/**",
        "--glob=!**/dist/**",
    }
end

require("telescope").setup({
    defaults = {
        vimgrep_arguments = vim.list_extend({
            "rg", "--follow", "--hidden", "--no-heading", "--with-filename",
            "--line-number", "--column", "--smart-case",
        }, ignored()),
        prompt_prefix = " > ",
        layout_strategy = "horizontal",
        sorting_strategy = "ascending",
        layout_config = {
            width = 0.6,
            height = 0.6,
            horizontal = { prompt_position = "bottom" },
        },
    },
    pickers = {
        find_files = {
            hidden = true,
            find_command = vim.list_extend({ "rg", "--files", "--hidden" }, ignored()),
        },
    },
})

local map = vim.keymap.set
map("n", "<leader>ff", "<cmd>Telescope find_files<CR>")
map("n", "<leader>fh", "<cmd>Telescope help_tags<CR>")
map("n", "<leader>fg", "<cmd>Telescope live_grep<CR>")
map("n", "<C-p>", "<cmd>Telescope git_files<CR>")
