return {
  {
    "echasnovski/mini.nvim",
    version = false,
    config = function()
      -- Settings
      require("mini.basics").setup()
      -- Options (Not covered by Mini Basic)
      vim.opt.tabstop = 2
      vim.opt.shiftwidth = 2
      vim.opt.expandtab = true

      vim.opt.relativenumber = true

      -- Editing
      local gen_ai_spec = require('mini.extra').gen_ai_spec
      require('mini.ai').setup({
        custom_textobjects = {
          B = gen_ai_spec.buffer(),
          D = gen_ai_spec.diagnostic(),
          I = gen_ai_spec.indent(),
          L = gen_ai_spec.line(),
          N = gen_ai_spec.number(),
        },
      })

      require("mini.bracketed").setup()
      require("mini.comment").setup()
      require("mini.cursorword").setup()
      require('mini.pairs').setup()
      require('mini.surround').setup()

      -- UI
      local hipatterns = require('mini.hipatterns')
      hipatterns.setup({
        highlighters = {
          -- Highlight standalone 'FIXME', 'HACK', 'TODO', 'NOTE'
          fixme = { pattern = '%f[%w]()FIXME()%f[%W]', group = 'MiniHipatternsFixme' },
          hack  = { pattern = '%f[%w]()HACK()%f[%W]',  group = 'MiniHipatternsHack'  },
          todo  = { pattern = '%f[%w]()TODO()%f[%W]',  group = 'MiniHipatternsTodo'  },
          note  = { pattern = '%f[%w]()NOTE()%f[%W]',  group = 'MiniHipatternsNote'  },

          -- Highlight hex color strings (`#rrggbb`) using that color
          hex_color = hipatterns.gen_highlighter.hex_color(),
        },
      })
      require("mini.statusline").setup()
      require('mini.indentscope').setup{
        symbol = "|",
      }
      require('mini.trailspace').setup()

      -- Core Stuff
      require("mini.files").setup{
        options = {
          use_as_default_explorer = true,
        }
      }
      require('mini.completion').setup()
      require('mini.pick').setup()
      require('mini.visits').setup()

      -- Misc
      require('mini.extra').setup()

    end
  },
}
