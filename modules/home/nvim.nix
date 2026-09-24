{
  config,
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
        java.enable = true;
        rust.enable = true;
        zig.enable = true;
        markdown.enable = true;
        lua.enable = true;
        python.enable = true;
        typescript.enable = true;
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
            sorting_strategy = "ascending";
            layout_config = {
              width = 0.6;
              height = 0.6;
              horizontal.prompt_position = "bottom";
            };
          };
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

      theme = {
        enable = true;
        name = "tokyonight";
        style = "night";
        transparent = true;
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
      visuals.indent-blankline.enable = true;
    };
  };

  stylix.targets.nvf.enable = false;
}
