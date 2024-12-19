return {
	{
		"echasnovski/mini.nvim",
		version = false,
		config = function()
			-- Mini Basics
			require("mini.basics").setup()
			vim.opt.tabstop = 2
			vim.opt.shiftwidth = 2
			vim.opt.expandtab = true
			vim.opt.scrolloff = 4
			vim.opt.autoindent = true
            vim.opt.relativenumber = true

			require("mini.ai").setup()
			require("mini.bracketed").setup()
			require("mini.bufremove").setup()
			require("mini.cursorword").setup()
			require("mini.diff").setup()
			require("mini.git").setup()
			local rhs = "<Cmd>lua MiniGit.show_at_cursor()<CR>"
			vim.keymap.set({ "n", "x" }, "<Leader>gs", rhs, { desc = "Show at cursor" })
			require("mini.pairs").setup({
				mappings = {
					["`"] = false,
				},
			})
			require("mini.surround").setup()

			-- UI
			local hipatterns = require("mini.hipatterns")
			hipatterns.setup({
				highlighters = {
					-- Highlight hex color strings (`#rrggbb`) using that color
					hex_color = hipatterns.gen_highlighter.hex_color(),
				},
			})
			require("mini.statusline").setup()
			require("mini.indentscope").setup({
				symbol = "|",
			})
		end,
	},
}
