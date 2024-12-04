local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable", -- latest stable release
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup("plugins", {
  git = {
      url_format = "git@github.com:%s.git"
  },
  ui = {
      icons = {
          cmd = "⌘",
          config = "🛠",
          event = "📅",
          ft = "📂",
          init = "⚙",
          keys = "🗝", plugin = "🔌",
          runtime = "💻",
          require = "🌙",
          source = "📄",
          start = "🚀",
          task = "📌",
          lazy = "💤 ",
      },
  },
})

require('Comment').setup()
require('leap').add_default_mappings()

require('other-nvim').setup({
  mappings = {
    "rails"
  }
})

require("plenary.filetype").add_file("meta")

require("telescope").load_extension("fzf")
require("telescope").load_extension("myles")
require("telescope").load_extension("biggrep")
require("telescope").load_extension("hg")

require'nvim-treesitter.configs'.setup {
  textobjects = {
    lsp_interop = {
      enable = true,
      border = 'none',
      floating_preview_opts = {},
      peek_definition_code = {
        ["<leader>df"] = "@function.outer",
        ["<leader>dF"] = "@class.outer",
      },
    },
    select = {
      enable = true,

      -- Automatically jump forward to textobj, similar to targets.vim
      lookahead = true,

      keymaps = {
        -- You can use the capture groups defined in textobjects.scm
        ["af"] = "@function.outer",
        ["if"] = "@function.inner",
        ["ac"] = "@class.outer",
        -- You can optionally set descriptions to the mappings (used in the desc parameter of
        -- nvim_buf_set_keymap) which plugins like which-key display
        ["ic"] = { query = "@class.inner", desc = "Select inner part of a class region" },
        -- You can also use captures from other query groups like `locals.scm`
        ["as"] = { query = "@scope", query_group = "locals", desc = "Select language scope" },
      },
      -- You can choose the select mode (default is charwise 'v')
      --
      -- Can also be a function which gets passed a table with the keys
      -- * query_string: eg '@function.inner'
      -- * method: eg 'v' or 'o'
      -- and should return the mode ('v', 'V', or '<c-v>') or a table
      -- mapping query_strings to modes.
      selection_modes = {
        ['@parameter.outer'] = 'v', -- charwise
        ['@function.outer'] = 'V', -- linewise
        ['@class.outer'] = '<c-v>', -- blockwise
      },
      -- If you set this to `true` (default is `false`) then any textobject is
      -- extended to include preceding or succeeding whitespace. Succeeding
      -- whitespace has priority in order to act similarly to eg the built-in
      -- `ap`.
      --
      -- Can also be a function which gets passed a table with the keys
      -- * query_string: eg '@function.inner'
      -- * selection_mode: eg 'v'
      -- and should return true of false
      include_surrounding_whitespace = true,
    },
    swap = {
      enable = true,
      swap_next = {
        ["<leader>a"] = "@parameter.inner",
      },
      swap_previous = {
        ["<leader>A"] = "@parameter.inner",
      },
    },
    move = {
      enable = true,
      set_jumps = true, -- whether to set jumps in the jumplist
      goto_next_start = {
        ["]m"] = "@function.outer",
        ["]]"] = { query = "@class.outer", desc = "Next class start" },
        --
        -- You can use regex matching (i.e. lua pattern) and/or pass a list in a "query" key to group multiple queires.
        ["]o"] = "@loop.*",
        -- ["]o"] = { query = { "@loop.inner", "@loop.outer" } }
        --
        -- You can pass a query group to use query from `queries/<lang>/<query_group>.scm file in your runtime path.
        -- Below example nvim-treesitter's `locals.scm` and `folds.scm`. They also provide highlights.scm and indent.scm.
        ["]s"] = { query = "@scope", query_group = "locals", desc = "Next scope" },
        ["]z"] = { query = "@fold", query_group = "folds", desc = "Next fold" },
      },
      goto_next_end = {
        ["]M"] = "@function.outer",
        ["]["] = "@class.outer",
      },
      goto_previous_start = {
        ["[m"] = "@function.outer",
        ["[["] = "@class.outer",
      },
      goto_previous_end = {
        ["[M"] = "@function.outer",
        ["[]"] = "@class.outer",
      },
      -- Below will go to either the start or the end, whichever is closer.
      -- Use if you want more granular movements
      -- Make it even more gradual by adding multiple queries and regex.
      goto_next = {
        ["]d"] = "@conditional.outer",
      },
      goto_previous = {
        ["[d"] = "@conditional.outer",
      }
    },
  },
}

require("meta").setup()
-- These are known core modules that ppl would likely want to keep hidden
-- to avoid having them polute the trace while debugging.
local TRACE_FILTER_RULES = {
    exact = {
        ['www/unknown'] = 1,
        ['flib/init/zeusgodofthunder/__entrypoint.php'] = 1,
        ['flib/init/routing/ZeusGodOfThunderAlite.php'] = 1,
    },
    startswith = {
        'flib/purpose/cipp/',
        'flib/core/asio/'
    },
}
require('meta.slog').setup({
    filters = {
        log = function(log)
            local level = log.attributes.level
            if level == 'mustfix' or level == 'fatal' or level == 'slog' then
            return true
            end
            return false
        end,
        trace = function(trace)
            local filename = require('meta.slog.util').get_relative_filename(trace.fileName)
            if TRACE_FILTER_RULES.exact[filename] ~= nil then
                return false
            end
            if vim.tbl_contains(TRACE_FILTER_RULES.startswith, function (prefix)
                return vim.startswith(filename, prefix)
            end, { predicate = true }) then
                return false
            end
            return true
        end
    }
})

require('meta.metamate').init({
  completionKeymap='<C-_>',
  filetypes = {"php", "python", "javascript"}
})
