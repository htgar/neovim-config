return {
    	{
		"stevearc/oil.nvim",
		opts = {},
		-- Optional dependencies
        dependencies = { { "echasnovski/mini.icons", opts = {} } },
		config = function()
			require("oil").setup()
			vim.keymap.set("n", "-", "<CMD>Oil<CR>", { desc = "Open parent directory" })
			vim.keymap.set("n", "<Leader>fe", "<CMD>Oil<CR>", { desc = "File Explorer" })
		end,
	},
}
