-- Bootstrap lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
	local lazyrepo = "https://github.com/folke/lazy.nvim.git"
	local out = vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath })
	if vim.v.shell_error ~= 0 then
		vim.api.nvim_echo({
			{ "Failed to clone lazy.nvim:\n", "ErrorMsg" },
			{ out, "WarningMsg" },
			{ "\nPress any key to exit..." },
		}, true, {})
		vim.fn.getchar()
		os.exit(1)
	end
end
vim.opt.rtp:prepend(lazypath)

-- Leader Settings
vim.g.mapleader = " "
vim.g.maplocalleader = "\\"

-- Plugin Definitions
require("lazy").setup({
	spec = {
		{ "catppuccin/nvim", name = "catppuccin", priority = 1000 },
		{ "echasnovski/mini.nvim", branch = "main" },
		{ "folke/noice.nvim", lspevent = "VeryLazy", dependencies = "MunifTanjim/nui.nvim" },
		{ "tpope/vim-rsi" },
		{ "rafamadriz/friendly-snippets" },
		{ "stevearc/conform.nvim" },
		{ "williamboman/mason.nvim" },
		{ "williamboman/mason-lspconfig.nvim" },
		{ "neovim/nvim-lspconfig" },
		{ "nvim-treesitter/nvim-treesitter", build = ":TSUpdate" },
		{ "folke/snacks.nvim", priority = 1000, lazy = false },
		{ "folke/which-key.nvim", event = "VeryLazy" },
	},
	-- colorscheme that will be used when installing plugins.
	install = { colorscheme = { "catppuccin" } },
	-- automatically check for plugin updates
	checker = { enabled = true },
})

-- Plugins Setup

-- Colorscheme
require("catppuccin").setup({
	integrations = {
		snacks = {
			enabled = true,
			indent_scope_color = "mauve",
		},
	},
	custom_highlights = function(colors)
		return {
			Folded = { bg = colors.none, fg = colors.none },
		}
	end,
})

vim.cmd.colorscheme("catppuccin")

-- Basics
require("mini.basics").setup()
vim.opt.tabstop = 4
vim.opt.shiftwidth = 4
vim.opt.expandtab = true
vim.opt.scrolloff = 4
vim.opt.autoindent = true
vim.opt.relativenumber = true
vim.opt.confirm = true
vim.opt.wrap = true

-- UI
require("mini.icons").setup()
require("mini.statusline").setup()

require("noice").setup({
	lsp = {
		-- override markdown rendering so that **cmp** and other plugins use **Treesitter**
		override = {
			["vim.lsp.util.convert_input_to_markdown_lines"] = true,
			["vim.lsp.util.stylize_markdown"] = true,
			["cmp.entry.get_documentation"] = true, -- requires hrsh7th/nvim-cmp
		},

		signature = {
			auto_open = { enabled = false },
		},
	},
	popupmenu = {
		enabled = false,
	},
	-- you can enable a preset for easier configuration
	presets = {
		bottom_search = true, -- use a classic bottom cmdline for search
		command_palette = true, -- position the cmdline and popupmenu together
		long_message_to_split = true, -- long messages will be sent to a split
		inc_rename = false, -- enables an input dialog for inc-rename.nvim
		lsp_doc_border = true, -- add a border to hover docs and signature help
	},
})

-- Whichkey
require("which-key").setup({
	preset = "modern",
})

require("which-key").add({
	{ "<leader>f", group = "File" },
	{ "<leader>f_", hidden = true },
	{ "<leader>l", group = "LSP" },
	{ "<leader>l_", hidden = true },
	{ "<leader>s", group = "Search" },
	{ "<leader>s_", hidden = true },
	{ "<leader>t", group = "Tools" },
	{ "<leader>t_", hidden = true },
})

-- Snacks
require("snacks").setup({
	bigfile = { enabled = true },
	indent = { enabled = true },
	scope = { enabled = true },
	scroll = { enabled = true },
	picker = { enabled = true },
})

-- Files and Search
require("mini.files").setup({
	mappings = {
		go_in_plus = "<CR>",
	},
})

vim.keymap.set("n", "<leader>ff", "<Cmd>lua Snacks.picker.files()<CR>", { desc = "Find Files" })
vim.keymap.set("n", "<leader>fe", "<Cmd>lua MiniFiles.open()<CR>", { desc = "Explorer" })
vim.keymap.set("n", "<leader>fg", "<Cmd>lua Snacks.picker.grep()<CR>", { desc = "Grep Files" })
vim.keymap.set("n", "<leader>sj", "<Cmd>lua Snacks.picker.jumps()<CR>", { desc = "Jump List" })
vim.keymap.set("n", "<leader>sl", "<Cmd>lua Snacks.picker.loclist()<CR>", { desc = "Location List" })

-- Editor
require("mini.ai").setup()
require("mini.bracketed").setup()
require("mini.jump").setup()
require("mini.pairs").setup()
require("mini.surround").setup()

-- Snippets
local gen_loader = require("mini.snippets").gen_loader
require("mini.snippets").setup({
	snippets = {
		gen_loader.from_file("~/.config/nvim/snippets/global.json"),
		gen_loader.from_lang(),
	},
	mappings = {
		jump_next = "<Tab>",
		jump_prev = "<S-Tab>",
	},
})

-- Completion and Formatting
require("mini.completion").setup()

-- LSP Keymaps
vim.api.nvim_create_autocmd("LspAttach", {
	group = vim.api.nvim_create_augroup("my.lsp", {}),
	callback = function(args)
		vim.keymap.set("n", "<Leader>la", "<Cmd>lua vim.lsp.buf.code_action()<CR>", { desc = "Code Actions" })
		vim.keymap.set("n", "<Leader>ld", "<Cmd>lua Snacks.picker.diagnostics()<CR>", { desc = "Diagnostics" })
		vim.keymap.set("n", "<Leader>ln", "<Cmd>lua vim.lsp.buf.rename()<CR>", { desc = "Rename" })
		vim.keymap.set("n", "<Leader>lr", "<Cmd>lua vim.lsp.buf.references()<CR>", { desc = "References" })
		vim.keymap.set("n", "<Leader>ls", "<Cmd>lua Snacks.picker.lsp_symbols()<CR>", { desc = "Document Symbols" })
		vim.keymap.set(
			"n",
			"<Leader>lw",
			"<Cmd>lua Snacks.picker.lsp_workspace_symbols()<CR>",
			{ desc = "Workspace Symbols" }
		)
	end,
})

-- Git
require("mini.diff").setup()

-- Diagnostics
vim.diagnostic.config({
	virtual_text = false,
	virtual_lines = { current_line = true },
})

-- Fold
vim.opt.foldmethod = "expr"
vim.opt.foldexpr = "v:lua.vim.treesitter.foldexpr()"
vim.opt.foldtext = ""
vim.opt.foldlevel = 99

-- Treesitter
require("nvim-treesitter.configs").setup({
	auto_install = true,
	highlight = {
		enable = true,
		disable = function(lang, buf)
			local max_filesize = 100 * 1024 -- 100 KB
			local ok, stats = pcall(vim.loop.fs_stat, vim.api.nvim_buf_get_name(buf))
			if ok and stats and stats.size > max_filesize then
				return true
			end
		end,
	},
})

-- Formatting
require("conform").setup({
	formatters_by_ft = {
		lua = { "stylua" },
	},
	format_on_save = {
		-- These options will be passed to conform.format()
		timeout_ms = 500,
		lsp_format = "fallback",
	},
})

-- LSP
require("mason").setup()
require("mason-lspconfig").setup()
vim.keymap.set("n", "<Leader>tm", "<Cmd>Mason<CR>")
vim.keymap.set("n", "<Leader>tl", "<Cmd>Lazy<CR>")
require("mason-lspconfig").setup_handlers({
	-- The first entry (without a key) will be the default handler
	-- and will be called for each installed server that doesn't have
	-- a dedicated handler.
	function(server_name) -- default handler (optional)
		require("lspconfig")[server_name].setup({})
	end,
})

require("lspconfig").lua_ls.setup({
	on_init = function(client)
		if client.workspace_folders then
			local path = client.workspace_folders[1].name
			if
				path ~= vim.fn.stdpath("config")
				and (vim.loop.fs_stat(path .. "/.luarc.json") or vim.loop.fs_stat(path .. "/.luarc.jsonc"))
			then
				return
			end
		end

		client.config.settings.Lua = vim.tbl_deep_extend("force", client.config.settings.Lua, {
			runtime = {
				-- Tell the language server which version of Lua you're using
				-- (most likely LuaJIT in the case of Neovim)
				version = "LuaJIT",
			},
			-- Make the server aware of Neovim runtime files
			workspace = {
				checkThirdParty = false,
				library = {
					vim.env.VIMRUNTIME,
					-- Depending on the usage, you might want to add additional paths here.
					-- "${3rd}/luv/library"
					-- "${3rd}/busted/library",
				},
				-- or pull in all of 'runtimepath'. NOTE: this is a lot slower and will cause issues when working on your own configuration (see https://github.com/neovim/nvim-lspconfig/issues/3189)
				-- library = vim.api.nvim_get_runtime_file("", true)
			},
		})
	end,
	settings = {
		Lua = {},
	},
})
