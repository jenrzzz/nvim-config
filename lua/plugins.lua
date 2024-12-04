return {
  { "folke/lazy.nvim", version = "*" }, -- package manager
  {
    "vhyrro/luarocks.nvim",
    priority = 1000, -- Very high priority is required, luarocks.nvim should run as the first plugin in your config.
    config = true,
  },
  -- libraries
  {"neovim/nvim-lspconfig"},
  "nvim-lua/plenary.nvim",
  "tpope/vim-repeat",
  "glts/vim-magnum",
  "MunifTanjim/nui.nvim",
  "mfussenegger/nvim-dap",
  {"nvim-treesitter/nvim-treesitter", build = ":TSUpdate"},
  -- {
  --   "pmizio/typescript-tools.nvim",
  --   dependencies = { "nvim-lua/plenary.nvim", "neovim/nvim-lspconfig" },
  --   opts = {},
  -- },
  {
    "nvim-telescope/telescope.nvim", tag = "0.1.4",
    dependencies = { "nvim-lua/plenary.nvim" }
  },
  {
    'nvim-telescope/telescope-fzf-native.nvim',
    build = 'make'
  },
  {
    "nvimtools/none-ls.nvim",
    dependencies = { "nvim-lua/plenary.nvim" }
  },
  { dir = "/usr/share/fb-editor-support/nvim", name = "meta.nvim", dependencies = { "mfussenegger/nvim-dap" }},
  {
    'rcarriga/nvim-dap-ui',
    dependencies = {
      'mfussenegger/nvim-dap',
      'nvim-neotest/nvim-nio',
    },
    config = function()
      local dap, dapui = require('dap'), require('dapui')
      dapui.setup()

      vim.keymap.set('n', '<LEADER>ds', function()
        dap.toggle_breakpoint()
        dap.continue()
        dapui.open()
      end)
      vim.keymap.set('n', '<LEADER>dx', function()
        dap.terminate()
        dap.clear_breakpoints()
        dapui.close()
      end)
      vim.keymap.set('n', '<LEADER>dc', dap.continue)
      vim.keymap.set('n', '<LEADER>dn', dap.step_over)
      vim.keymap.set('n', '<LEADER>di', dap.step_into)
      vim.keymap.set('n', '<LEADER>do', dap.step_out)
      vim.keymap.set('n', '<LEADER>dbt', dap.toggle_breakpoint)
      vim.keymap.set('n', '<LEADER>dbx', dap.clear_breakpoints)
      vim.keymap.set('n', '<LEADER>dbl', dap.list_breakpoints)
    end,
  },
 
  -- themes
  "vim-airline/vim-airline",
  "vim-airline/vim-airline-themes",
  "jenrzzz/jellybeans.vim",
  "NLKNguyen/papercolor-theme",
  "gerw/vim-HiLinkTrace",

  -- motion
  "ggandor/leap.nvim",

  -- text objects
  "tpope/vim-surround",
  "tpope/vim-speeddating",
  "tpope/vim-unimpaired",
  "glts/vim-radical",
  {
    'numToStr/Comment.nvim',
    opts = {},
    lazy = false,
  },
  {
    "nvim-treesitter/nvim-treesitter-textobjects",
    dependencies = { "nvim-treesitter/nvim-treesitter" },
  },

  -- git
  "tpope/vim-fugitive",
  "tommcdo/vim-fugitive-blame-ext",

  -- hg
  "phleet/vim-mercenary",

  -- plugins
  "vijaymarupudi/nvim-fzf",
  "vijaymarupudi/nvim-fzf-commands",
  {"LintaoAmons/scratch.nvim", event = "VeryLazy"},
  "rgroli/other.nvim",
  {
    'tpope/vim-projectionist',
    config = function()
      local jest_alternate = {
        ['**/__tests__/*.test.js'] = {
          alternate = '{}.js',
          type = 'test',
        },
        ['*.js'] = {
          alternate = '{dirname}/__tests__/{basename}.test.js',
          type = 'source',
        },
      }
      vim.g.projectionist_heuristics = {
        ['jest.config.js|jest.config.ts'] = jest_alternate,
        ['.arcconfig'] = vim.tbl_deep_extend('keep', {
          ['**/__tests__/*Test.php'] = {
            alternate = '{}.php',
            type = 'test',
          },
          ['*.php'] = {
            alternate = '{dirname}/__tests__/{basename}Test.php',
            type = 'source',
          },
        }, jest_alternate),
      }
    end,
  },
  "tpope/vim-dispatch",
  "wsdjeg/vim-fetch",
  "hhvm/vim-hack",
  -- "dpayne/CodeGPT.nvim",
  -- "github/copilot.vim",
  -- "farseer90718/vim-taskwarrior",
  "onsails/lspkind.nvim",
  {
    "hedyhli/outline.nvim",
    lazy = true,
    cmd = { "Outline", "OutlineOpen" },
    keys = { -- Example mapping to toggle outline
      { "<leader>o", "<cmd>Outline<CR>", desc = "Toggle outline" },
    },
    opts = {
      symbols = {
        icon_source = "lspkind"
      }
    },
  },
}
