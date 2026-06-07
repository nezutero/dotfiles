vim.opt.termguicolors = true

function SetColor(color)
    color = "kanagawa"
    vim.cmd.colorscheme(color)

    -- these are safe to fully clear
    local groups = {
        "Normal", "NormalFloat", "NormalNC",
        "SignColumn", "LineNr", "LineNrAbove",
        "LineNrBelow", "CursorLineNr", "EndOfBuffer",
        "MsgArea", "MsgSeparator", "StatusLine", "StatusLineNC",
        "FoldColumn", "CursorLine", "CursorColumn",
    }

    for _, group in ipairs(groups) do
        vim.api.nvim_set_hl(0, group, { bg = "none" })
    end

    -- GitSigns: strip bg but keep fg intact
    local gitsigns_groups = {
        "GitSignsAdd",
        "GitSignsChange",
        "GitSignsDelete",
        "GitSignsTopdelete",
        "GitSignsChangedelete",
        "GitSignsUntracked",
        -- LSP diagnostics
        "DiagnosticSignError",
        "DiagnosticSignWarn",
        "DiagnosticSignInfo",
        "DiagnosticSignHint",
        "DiagnosticSignOk",
    }

    for _, group in ipairs(gitsigns_groups) do
        local hl = vim.api.nvim_get_hl(0, { name = group, link = false })
        hl.bg = nil
        vim.api.nvim_set_hl(0, group, hl)
    end
end

SetColor()
