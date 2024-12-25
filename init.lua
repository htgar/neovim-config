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

-- Setup lazy.nvim
require("lazy").setup({
  spec = {
    { "catppuccin/nvim", name = "catppuccin", priority = 1000 },
    { "folke/which-key.nvim", event = "VeryLazy" },
    { "neovim/nvim-lspconfig" },
    { "nvim-treesitter/nvim-treesitter" },
    { "echasnovski/mini.nvim", branch = "main" },
    { "stevearc/oil.nvim", opts = {} },
    { "folke/noice.nvim", event = "VeryLazy", dependencies = { "MunifTanjim/nui.nvim" } },
    { "ibhagwan/fzf-lua" },

  },
  -- colorscheme that will be used when installing plugins.
  install = { colorscheme = { "catppuccin" } },
  -- automatically check for plugin updates
  checker = { enabled = true },
})


-- Plugins Setup

-- Colorscheme
vim.cmd.colorscheme("catppuccin")

-- Basic Settings
require("mini.basics").setup()
vim.opt.tabstop = 4
vim.opt.shiftwidth = 4
vim.opt.expandtab = true
vim.opt.scrolloff = 4
vim.opt.autoindent = true
vim.opt.relativenumber = true

-- Whichkey
require("which-key").setup({
    defaults = {
        preset = modern,
    },
})

require("which-key").add({
    { "<leader>f", group = "File" },
    { "<leader>f_", hidden = true },
    { "<leader>g", group = "Git" },
    { "<leader>g_", hidden = true },
    { "<leader>l", group = "Lsp" },
    { "<leader>l_", hidden = true },
})


-- Editor
require("mini.ai").setup()
require("mini.bracketed").setup()
require("mini.cursorword").setup()
require("mini.indentscope").setup({ symbol="|" })
require("mini.operators").setup()
require("mini.pairs").setup()
require("mini.surround").setup()
require("mini.splitjoin").setup()

-- Git
require("mini.diff").setup()
require("mini.git").setup()

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
  },
  -- you can enable a preset for easier configuration
  presets = {
    bottom_search = true, -- use a classic bottom cmdline for search
    command_palette = true, -- position the cmdline and popupmenu together
    long_message_to_split = true, -- long messages will be sent to a split
    inc_rename = false, -- enables an input dialog for inc-rename.nvim
    lsp_doc_border = false, -- add a border to hover docs and signature help
  },
})

-- Fzf + Oil
local actions = require'fzf-lua.actions'
require 'fzf-lua'.setup({
    actions = {
        files = {
            -- instead of the default action 'actions.file_edit_or_qf'
            -- it's important to define all other actions here as this
            -- table does not get merged with the global defaults
            ["default"]       = actions.file_edit,
            ["ctrl-s"]        = actions.file_split,
            ["ctrl-v"]        = actions.file_vsplit,
            ["ctrl-t"]        = actions.file_tabedit,
            ["alt-q"]         = actions.file_sel_to_qf,
        },
        grep = {
            actions = {
                ['ctrl-q'] = {
                    fn = actions.file_edit_or_qf, prefix = 'select-all+'
                },
            },
        },
    },
})
vim.keymap.set("n", "<Leader>ff", "<CMD>FzfLua files<CR>", { desc = "Find Files" })
vim.keymap.set("n", "<Leader>fg", "<CMD>FzfLua live_grep<CR>", { desc = "Grep Files" })
vim.keymap.set("n", "-", "<CMD>Oil<CR>", { desc = "Open parent directory" })

-- Treesitter
require("nvim-treesitter.configs").setup({
  highlight = { enable = true },
  auto_install = true,
})

-- Autocomplete
require("mini.completion").setup()
require("mini.snippets").setup()

-- LSP
vim.api.nvim_create_autocmd('LspAttach', {
    group = vim.api.nvim_create_augroup('lsp-attach', { clear = true }),
    callback = function(event)
        -- NOTE: Remember that Lua is a real programming language, and as such it is possible
        -- to define small helper and utility functions so you don't have to repeat yourself.
        --
        -- In this case, we create a function that lets us more easily define mappings specific
        -- for LSP related items. It sets the mode, buffer and description for us each time.
        local map = function(keys, func, desc, mode)
            mode = mode or 'n'
            vim.keymap.set(mode, keys, func, { buffer = event.buf, desc = 'LSP: ' .. desc })
        end

        -- Jump to the definition of the word under your cursor.
        --  This is where a variable was first declared, or where a function is defined, etc.
        --  To jump back, press <C-t>.
        map('gd', require('fzf-lua').lsp_definitions, 'Goto Definition')

        -- WARN: This is not Goto Definition, this is Goto Declaration.
        --  For example, in C this would take you to the header.
        map('gD', require('fzf-lua').lsp_declarations, 'Goto Declaration')

        -- Find references for the word under your cursor.
        map('gr', require('fzf-lua').lsp_references, 'Goto References')

        -- Jump to the implementation of the word under your cursor.
        --  Useful when your language has ways of declaring types without an actual implementation.
        map('gI', require('fzf-lua').lsp_implementations, 'Goto Implementation')

        -- Jump to the type of the word under your cursor.
        --  Useful when you're not sure what type a variable is and you want to see
        --  the definition of its *type*, not where it was *defined*.
        map('<leader>lt', require('fzf-lua').lsp_typedefs, 'Type Definitions')

        -- Fuzzy find all the symbols in your current document.
        --  Symbols are things like variables, functions, types, etc.
        map('<leader>ls', require('fzf-lua').lsp_document_symbols, 'Document Symbols')

        -- Fuzzy find all the symbols in your current workspace.
        --  Similar to document symbols, except searches over your entire project.
        map('<leader>ws', require('fzf-lua').lsp_live_workspace_symbols, 'Workspace Symbols')

        -- Rename the variable under your cursor.
        --  Most Language Servers support renaming across files, etc.
        map('<leader>lr', vim.lsp.buf.rename, 'Rename')

        -- Execute a code action, usually your cursor needs to be on top of an error
        -- or a suggestion from your LSP for this to activate.
        map('<leader>lc', vim.lsp.buf.code_action, 'Code Action', { 'n', 'x' })

        -- The following two autocommands are used to highlight references of the
        -- word under your cursor when your cursor rests there for a little while.
        --    See `:help CursorHold` for information about when this is executed
        --
        -- When you move your cursor, the highlights will be cleared (the second autocommand).
        local client = vim.lsp.get_client_by_id(event.data.client_id)
        if client and client.supports_method(vim.lsp.protocol.Methods.textDocument_documentHighlight) then
            local highlight_augroup = vim.api.nvim_create_augroup('kickstart-lsp-highlight', { clear = false })
            vim.api.nvim_create_autocmd({ 'CursorHold', 'CursorHoldI' }, {
                buffer = event.buf,
                group = highlight_augroup,
                callback = vim.lsp.buf.document_highlight,
            })

            vim.api.nvim_create_autocmd({ 'CursorMoved', 'CursorMovedI' }, {
                buffer = event.buf,
                group = highlight_augroup,
                callback = vim.lsp.buf.clear_references,
            })

            vim.api.nvim_create_autocmd('LspDetach', {
                group = vim.api.nvim_create_augroup('kickstart-lsp-detach', { clear = true }),
                callback = function(event2)
                    vim.lsp.buf.clear_references()
                    vim.api.nvim_clear_autocmds { group = 'kickstart-lsp-highlight', buffer = event2.buf }
                end,
            })
        end

        -- The following code creates a keymap to toggle inlay hints in your
        -- code, if the language server you are using supports them
        --
        -- This may be unwanted, since they displace some of your code
        if client and client.supports_method(vim.lsp.protocol.Methods.textDocument_inlayHint) then
            map('<leader>lh', function()
                vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled { bufnr = event.buf })
            end, 'Toggle Inlay Hints')
        end
    end,
})

-- LSP Servers

-- Lua
require'lspconfig'.lua_ls.setup {
  on_init = function(client)
    if client.workspace_folders then
      local path = client.workspace_folders[1].name
      if vim.loop.fs_stat(path..'/.luarc.json') or vim.loop.fs_stat(path..'/.luarc.jsonc') then
        return
      end
    end

    client.config.settings.Lua = vim.tbl_deep_extend('force', client.config.settings.Lua, {
      runtime = {
        -- Tell the language server which version of Lua you're using
        -- (most likely LuaJIT in the case of Neovim)
        version = 'LuaJIT'
      },
      -- Make the server aware of Neovim runtime files
      workspace = {
        checkThirdParty = false,
        library = {
          vim.env.VIMRUNTIME
          -- Depending on the usage, you might want to add additional paths here.
          -- "${3rd}/luv/library"
          -- "${3rd}/busted/library",
        }
        -- or pull in all of 'runtimepath'. NOTE: this is a lot slower and will cause issues when working on your own configuration (see https://github.com/neovim/nvim-lspconfig/issues/3189)
        -- library = vim.api.nvim_get_runtime_file("", true)
      }
    })
  end,
  settings = {
    Lua = {}
  }
}
