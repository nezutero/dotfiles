require("trouble").setup()
vim.keymap.set("n", "<leader>t", "<cmd>Trouble<CR>", { silent = true })

vim.keymap.set("n", "<leader>u", "<cmd>UndotreeToggle<CR>")
