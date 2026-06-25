local function mode()
    local modes = {
        n = "[NORMAL]",
        no = "[N-PENDING]",
        i = "[INSERT]",
        ic = "[INSERT]",
        v = "[VISUAL]",
        V = "[V-LINE]",
        ["\22"] = "[V-BLOCK]",
        c = "[COMMAND]",
        R = "[REPLACE]",
        s = "[SELECT]",
        S = "[S-LINE]",
        t = "[TERMINAL]",
    }

    local m = vim.api.nvim_get_mode().mode
    return modes[m] or ("[" .. m .. "]")
end

function _G.statusline_mode()
    return mode()
end

function _G.git_info()
    local ok, gsd = pcall(function()
        return vim.b.gitsigns_status_dict
    end)

    if not ok or not gsd or not gsd.head or gsd.head == "" then
        return ""
    end

    local parts = { " " .. gsd.head }

    if (gsd.added or 0) > 0 then
        table.insert(parts, "+" .. gsd.added)
    end
    if (gsd.changed or 0) > 0 then
        table.insert(parts, "~" .. gsd.changed)
    end
    if (gsd.removed or 0) > 0 then
        table.insert(parts, "-" .. gsd.removed)
    end

    return " " .. table.concat(parts, " ")
end

vim.o.statusline = table.concat({
    "%{%v:lua.statusline_mode()%}",
    " ",
    "%f",
    " %m%r",
    "%{%v:lua.git_info()%}",
    "%=",
    "%y",
    " ",
    "%{&fileencoding != '' ? &fileencoding : &encoding}",
    " ",
    "%l:%c",
    " ",
    "%p%%",
    " ",
})
