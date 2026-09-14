{
  config,
  pkgs,
  inputs,
  ...
}:
{
  imports = [
    inputs.nvf.homeManagerModules.default
  ];

  programs.nvf = {
    enable = true;
    settings.vim = {
      viAlias = false;
      vimAlias = true;

      globals.mapleader = " ";

      options = {
        number = true;
        relativenumber = true;
        tabstop = 4;
        softtabstop = 4;
        shiftwidth = 4;
        expandtab = true;
        mouse = "a";
        smartindent = true;
        wrap = true;
        swapfile = false;
        backup = false;
        undofile = true;
        undodir = "${config.home.homeDirectory}/.nvim/undodir";
        hlsearch = false;
        incsearch = true;
        scrolloff = 8;
        updatetime = 50;
        colorcolumn = "90";
        textwidth = 100;
        breakindent = true;
        linebreak = true;
        fillchars = {
          eob = " ";
        };
        isfname = [ "@-@" ];
      };

      keymaps = [
        {
          key = "<leader>ww";
          mode = [ "n" ];
          action = ":Ex<CR>";
        }
        {
          key = "J";
          mode = [ "v" ];
          action = ":m '>+1<CR>gv=gv";
        }
        {
          key = "K";
          mode = [ "v" ];
          action = ":m '<-2<CR>gv=gv";
        }
        {
          key = "<leader>p";
          mode = [ "x" ];
          action = "\"_dP";
        }
        {
          key = "<leader>y";
          mode = [
            "n"
            "v"
          ];
          action = "\"+y";
        }
        {
          key = "<leader>Y";
          mode = [ "n" ];
          action = "\"+Y";
        }
        {
          key = "<leader>f";
          mode = [ "n" ];
          lua = true;
          action = "vim.lsp.buf.format";
        }
        {
          key = "<C-k>";
          mode = [ "n" ];
          action = "<cmd>cnext<CR>zz";
        }
        {
          key = "<C-j>";
          mode = [ "n" ];
          action = "<cmd>cprev<CR>zz";
        }
        {
          key = "<leader>k";
          mode = [ "n" ];
          action = "<cmd>lnext<CR>zz";
        }
        {
          key = "<leader>j";
          mode = [ "n" ];
          action = "<cmd>lprev<CR>zz";
        }
        {
          key = "<leader>x";
          mode = [ "n" ];
          action = "<cmd>!chmod +x %<CR>";
          silent = true;
        }
        {
          key = "<leader>ff";
          mode = [ "n" ];
          action = "<cmd>Telescope find_files<CR>";
        }
        {
          key = "<leader>fh";
          mode = [ "n" ];
          action = "<cmd>Telescope help_tags<CR>";
        }
        {
          key = "<leader>fg";
          mode = [ "n" ];
          action = "<cmd>Telescope live_grep<CR>";
        }
        {
          key = "<C-p>";
          mode = [ "n" ];
          action = "<cmd>Telescope git_files<CR>";
        }
        {
          key = "<leader>t";
          mode = [ "n" ];
          action = "<cmd>Trouble<CR>";
          silent = true;
        }
        {
          key = "<leader>u";
          mode = [ "n" ];
          action = "<cmd>UndotreeToggle<CR>";
        }
      ];

      lsp = {
        enable = true;
        mappings = {
          goToDefinition = "gd";
          goToDeclaration = "gD";
          listReferences = "gr";
          listImplementations = "gi";
          hover = "K";
          renameSymbol = "<leader>rn";
          codeAction = "<leader>ca";
          openDiagnosticFloat = "<leader>e";
          previousDiagnostic = "[d";
          nextDiagnostic = "]d";
          signatureHelp = "<C-k>";
        };
        trouble.enable = true;
      };

      diagnostics = {
        enable = true;
        config = {
          update_in_insert = false;
          virtual_text = true;
          float = {
            focusable = false;
            style = "minimal";
            border = "rounded";
            source = "always";
            header = "";
            prefix = "";
          };
        };
      };

      languages = {
        enableTreesitter = true;
        enableFormat = false;

        bash.enable = true;
        clang.enable = true;
        go.enable = true;
        html.enable = true;
        css.enable = true;
        rust.enable = true;
        zig.enable = true;
        markdown.enable = true;
        lua.enable = true;
        nix = {
          enable = true;
          lsp.servers = [ "nil" ];
        };
      };

      autocomplete.nvim-cmp.enable = true;

      telescope = {
        enable = true;
        setupOpts = {
          defaults = {
            vimgrep_arguments = [
              "rg"
              "--follow"
              "--hidden"
              "--no-heading"
              "--with-filename"
              "--line-number"
              "--column"
              "--smart-case"
              "--glob=!**/.git/**"
              "--glob=!**/.idea/**"
              "--glob=!**/.vscode/**"
              "--glob=!**/build/**"
              "--glob=!**/dist/**"
            ];
            prompt_prefix = " > ";
            layout_strategy = "horizontal";
            layout_config = {
              width = 0.6;
              height = 0.6;
            };
          };
          prompt_position = "bottom";
          sorting_strategy = "ascending";
          pickers.find_files = {
            hidden = true;
            find_command = [
              "rg"
              "--files"
              "--hidden"
              "--glob=!**/.git/**"
              "--glob=!**/.idea/**"
              "--glob=!**/.vscode/**"
              "--glob=!**/build/**"
              "--glob=!**/dist/**"
            ];
          };
        };
      };

      statusline.lualine = {
        enable = true;
        setupOpts.theme = {
          sections = {
            lualine_a = [ "mode" ];
            lualine_b = [
              "branch"
              "diff"
              "diagnostics"
            ];
            lualine_x = [
              "encoding"
              "filetype"
            ];
            lualine_y = [ "lsp_status" ];
            lualine_z = [ "progress" ];
          };
        };
      };

      treesitter.enable = true;
      git.gitsigns.enable = true;
      utility.undotree.enable = true;
      luaConfigRC.telescopeTheme = ''
        vim.cmd([[
          hi TelescopeNormal guibg=NONE ctermbg=NONE
          hi TelescopePromptNormal guibg=NONE ctermbg=NONE
          hi TelescopeResultsNormal guibg=NONE ctermbg=NONE
          hi TelescopePreviewNormal guibg=NONE ctermbg=NONE

          hi TelescopeBorder guifg=Grey guibg=NONE ctermfg=Grey ctermbg=NONE
          hi TelescopePromptBorder guifg=Grey guibg=NONE ctermfg=Grey ctermbg=NONE
          hi TelescopeResultsBorder guifg=Grey guibg=NONE ctermfg=Grey ctermbg=NONE
          hi TelescopePreviewBorder guifg=Grey guibg=NONE ctermfg=Grey ctermbg=NONE

          hi TelescopeTitle guifg=Grey guibg=NONE ctermfg=Grey ctermbg=NONE
          hi TelescopePromptTitle guifg=Grey guibg=NONE ctermfg=Grey ctermbg=NONE
          hi TelescopeResultsTitle guifg=Grey guibg=NONE ctermfg=Grey ctermbg=NONE
          hi TelescopePreviewTitle guifg=Grey guibg=NONE ctermfg=Grey ctermbg=NONE

          hi TelescopePromptPrefix guifg=Orange guibg=NONE ctermfg=Yellow ctermbg=NONE
          hi TelescopeMatching guifg=Orange gui=bold cterm=bold
          hi TelescopeSelection guifg=White guibg=NONE gui=bold
          hi TelescopeSelectionCaret guifg=Orange guibg=NONE gui=bold
          hi TelescopeMultiSelection guifg=Grey guibg=NONE

          hi VertSplit guibg=NONE ctermbg=NONE
        ]])
      '';
      luaConfigRC.transparency = ''
        local function apply_transparency()
          local groups = {
            "Normal", "NormalFloat", "NormalNC", "SignColumn",
            "LineNr", "LineNrAbove", "LineNrBelow", "CursorLineNr",
            "EndOfBuffer", "MsgArea", "MsgSeparator",
            "StatusLine", "StatusLineNC", "FoldColumn",
            "CursorLine", "CursorLineSign", "CursorLineFold", "CursorColumn",
            "WinSeparator", "VertSplit",
          }
          for _, group in ipairs(groups) do
            vim.api.nvim_set_hl(0, group, { bg = "none" })
          end

          local sign_groups = {
            "DiagnosticSignError", "DiagnosticSignWarn",
            "DiagnosticSignInfo", "DiagnosticSignHint", "DiagnosticSignOk",
          }
          for _, group in ipairs(sign_groups) do
            local ok, hl = pcall(vim.api.nvim_get_hl, 0, { name = group, link = false })
            if ok then
              hl.bg = nil
              vim.api.nvim_set_hl(0, group, hl)
            end
          end
        end

        apply_transparency()
        vim.api.nvim_create_autocmd("ColorScheme", {
          pattern = "*",
          callback = apply_transparency,
        })
        vim.api.nvim_create_autocmd({ "BufEnter", "BufWinEnter" }, {
          callback = apply_transparency,
        })
      '';
    };
  };

  stylix.targets.nvf.enable = true;
}
