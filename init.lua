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

require("lazy").setup({
	spec = {
		{ "catppuccin/nvim", name = "catppuccin", priority = 1000 },
		{ "echasnovski/mini.nvim", branch = "main" },
        { "folke/noice.nvim", lspevent = "VeryLazy", dependencies = "MunifTanjim/nui.nvim" },
        { "tpope/vim-rsi" },
	},
	-- colorscheme that will be used when installing plugins.
	install = { colorscheme = { "catppuccin" } },
	-- automatically check for plugin updates
	checker = { enabled = true },
})

-- Plugins Setup

-- Colorscheme
vim.cmd.colorscheme("catppuccin")

-- Basics
require("mini.basics").setup()
vim.opt.tabstop = 4
vim.opt.shiftwidth = 4
vim.opt.expandtab = true
vim.opt.scrolloff = 4
vim.opt.autoindent = true
vim.opt.relativenumber = true

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

-- Editor
require("mini.ai").setup()
require("mini.jump").setup()
require("mini.pairs").setup()
require("mini.surround").setup()

-- Completion
vim.cmd("set completeopt+=noselect")

vim.api.nvim_create_autocmd('LspAttach', {
  callback = function(ev)
    local client = vim.lsp.get_client_by_id(ev.data.client_id)
    if client:supports_method('textDocument/completion') then
      vim.lsp.completion.enable(true, client.id, ev.buf, { autotrigger = true })
    end
  end,
})

-- Diagnostics
vim.diagnostic.config({
  virtual_text = { current_line = true }
})

-- LSP
vim.lsp.enable({'luals'})
