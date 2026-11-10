-- Editor settings. See :help '<name>' for any option, e.g. :help 'scrolloff'

local o = vim.opt

-- Line numbers and guides
o.number = true
o.relativenumber = true
o.signcolumn = "auto" -- diagnostic/git signs replace the line number, "auto", "number"
o.colorcolumn = "90"
o.textwidth = 100

-- Indentation
o.tabstop = 4
o.softtabstop = 4
o.shiftwidth = 4
o.expandtab = true
o.smartindent = true

-- Wrapping and scrolling
o.wrap = true
o.linebreak = true
o.breakindent = true
o.scrolloff = 8

-- Search
o.hlsearch = false
o.incsearch = true

-- Files
o.swapfile = false
o.backup = false
o.undofile = true       -- undo history survives closing the file
o.isfname:append("@-@") -- add "@" to filename characters, keep the defaults

-- Behaviour
o.mouse = "a"
o.updatetime = 50
o.timeoutlen = 500
o.splitbelow = true
o.splitright = true
o.termguicolors = true
o.fillchars = { eob = " " } -- hide the ~ after the end of the buffer
