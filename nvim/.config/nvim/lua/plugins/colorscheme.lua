return {
    "rebelot/kanagawa.nvim",

    lazy = false,
    priority = 1000,

    config = function()
        vim.opt.termguicolors = true

        local function apply_transparency()
            local groups = {
                "Normal",
                "NormalFloat",
                "NormalNC",
                "SignColumn",
                "LineNr",
                "LineNrAbove",
                "LineNrBelow",
                "CursorLineNr",
                "EndOfBuffer",
                "MsgArea",
                "MsgSeparator",
                "StatusLine",
                "StatusLineNC",
                "FoldColumn",
                "CursorLine",
                "CursorColumn",
            }

            for _, group in ipairs(groups) do
                vim.api.nvim_set_hl(0, group, { bg = "none" })
            end

            local sign_groups = {
                "GitSignsAdd",
                "GitSignsChange",
                "GitSignsDelete",
                "GitSignsTopdelete",
                "GitSignsChangedelete",
                "GitSignsUntracked",

                "DiagnosticSignError",
                "DiagnosticSignWarn",
                "DiagnosticSignInfo",
                "DiagnosticSignHint",
                "DiagnosticSignOk",
            }

            for _, group in ipairs(sign_groups) do
                local ok, hl = pcall(vim.api.nvim_get_hl, 0, {
                    name = group,
                    link = false,
                })

                if ok then
                    hl.bg = nil
                    vim.api.nvim_set_hl(0, group, hl)
                end
            end
        end

        vim.cmd.colorscheme("kanagawa")

        apply_transparency()

        vim.api.nvim_create_autocmd("ColorScheme", {
            pattern = "*",
            callback = apply_transparency,
        })
    end,
}
