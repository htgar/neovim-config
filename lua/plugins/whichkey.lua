return { 
  {
    "folke/which-key.nvim",
    event = "VeryLazy", 
    config = function() 
      require("which-key").setup({
        defaults = {
          preset = modern,
        },
      })

      require("which-key").add(
      -- Document existing key chains
      {
        { "<leader>f", group = "File" },
        { "<leader>f_", hidden = true },
        { "<leader>g", group = "Git" },
        { "<leader>g_", hidden = true },
        { "<leader>l", group = "Lsp" },
        { "<leader>l_", hidden = true },
      }
      )
    end,
  }, 
}
