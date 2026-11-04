-- Statusline: Neovim's default parts plus mode, git and language servers.
--
--   NORMAL │ main +3 -1 ~2 │ lua/config/lsp.lua [+]     lua_ls │ E:1 W:2 │ 12,5  Top
--
-- The %-codes are explained in :help 'statusline'.

local sep = " | " -- put between parts; change it to " | ", "  ", ...

local M = {}

local mode_names = {
    n = "NORMAL",
    no = "PENDING", -- after an operator like d or y
    v = "VISUAL",
    V = "V-LINE",
    ["\22"] = "V-BLOCK", -- Ctrl-v
    s = "SELECT",
    S = "S-LINE",
    ["\19"] = "S-BLOCK", -- Ctrl-s
    i = "INSERT",
    R = "REPLACE",
    c = "COMMAND",
    t = "TERMINAL",
}

-- While Neovim fills in a %{...} item, it temporarily makes the window being
-- drawn the current one; vim.g.actual_curwin is the window you're really in.
-- So vim.b and buffer 0 below mean "the buffer of this statusline".
local function is_active()
    return vim.api.nvim_get_current_win() == tonumber(vim.g.actual_curwin)
end

function M.mode()
    if not is_active() then
        return ""                           -- the mode only applies to the window you're in
    end
    local mode = vim.api.nvim_get_mode().mode -- e.g. "n", "i", "niI"
    return mode_names[mode] or mode_names[mode:sub(1, 1)] or mode
end

-- Branch from mini.git, line counts from mini.diff (see lua/config/git.lua)
function M.git()
    local branch = (vim.b.minigit_summary or {}).head_name
    if not branch then
        return "" -- not a git file
    end
    local text = branch
    local diff = vim.b.minidiff_summary or {}
    if (diff.add or 0) > 0 then text = text .. " +" .. diff.add end
    if (diff.delete or 0) > 0 then text = text .. " -" .. diff.delete end
    if (diff.change or 0) > 0 then text = text .. " ~" .. diff.change end
    return text
end

-- Names of the language servers attached to this buffer
function M.lsp()
    local names = {}
    for _, client in ipairs(vim.lsp.get_clients({ bufnr = 0 })) do
        table.insert(names, client.name)
    end
    return table.concat(names, ",")
end

-- Loading progress, e.g. "40%(1)" while jdtls starts (default statusline)
function M.progress()
    return is_active() and vim.ui.progress_status() or ""
end

-- Error and warning counts, e.g. "E:1 W:2" (default statusline)
function M.diagnostics()
    return vim.diagnostic.status()
end

-- One part followed by its separator, inside a %( %) group: when the part is
-- empty, Neovim hides the whole group, so the separator disappears with it.
-- `colored` uses %{% %}, which applies the colour codes in the result.
local function part(name, colored)
    local open = colored and "%{%" or "%{"
    local close = colored and "%}" or "}"
    return "%(" .. open .. "v:lua.require'config.statusline'." .. name .. "()" .. close .. sep .. "%)"
end

vim.o.statusline = table.concat({
    part("mode"),
    part("git"),
    "%<%f",        -- file path; %< cuts from here when the window is narrow
    "%( %h%w%m%r%)", -- [Help] [Preview] [+] (unsaved) [RO]

    "%=",          -- everything after this goes to the right

    part("progress"),
    part("lsp"),
    part("diagnostics", true),
    "%-14.(%l,%c%V%) %P", -- line,column and position, like the default
})

-- The mode is in the statusline now, so drop the "-- INSERT --" message.
-- Delete this line if you want both.
vim.o.showmode = false

-- Redraw when the mode or the attached servers change. Scheduled so a server
-- that is detaching is already gone when the statusline is drawn.
vim.api.nvim_create_autocmd({ "ModeChanged", "LspAttach", "LspDetach" }, {
    callback = vim.schedule_wrap(function()
        vim.cmd.redrawstatus()
    end),
})

return M
