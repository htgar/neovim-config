return {
  {
    "jay-babu/mason-null-ls.nvim",
    event = { "BufReadPre", "BufNewFile" },
    dependencies = {
      "williamboman/mason.nvim",
      "nvimtools/none-ls.nvim",
      "nvim-lua/plenary.nvim",
    },
    config = function()
      local null_ls = require 'null-ls'
      null_ls.setup()

      require('mason-null-ls').setup({
        ensure_installed = { 'stylua', 'jq' },
        handlers = {
          function() end, -- disables automatic setup of all null-ls sources
          stylua = function(source_name, methods)
            null_ls.register(null_ls.builtins.formatting.stylua)
          end,
          shfmt = function(source_name, methods)
            -- custom logic
            require('mason-null-ls').default_setup(source_name, methods) -- to maintain default behavior
          end,
        },
      })
    end,
  }
}
