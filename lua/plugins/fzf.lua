return {
  {
  "ibhagwan/fzf-lua",
  -- optional for icon support
  dependencies = { "echasnovski/mini.icons" },
  config = function()
    require("fzf-lua").setup({"telescope"})
    vim.keymap.set("n", "<Leader>ff", "<CMD>FzfLua files<CR>", { desc = "Find Files" })
    vim.keymap.set("n", "<Leader>fg", "<CMD>FzfLua live_grep<CR>", { desc = "Grep Files" })
  end
},
}
