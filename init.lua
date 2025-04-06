-- Bootstrap lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
    local lazyrepo = "https://github.com/folke/lazy.nvim.git"
    local out = vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath })
    if vim.v.shell_error ~= 0 then
        vim.api.nvim_echo({
            { "Failed to clone lazy.nvim:\n", "ErrorMsg" },
            { out,                            "WarningMsg" },
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
        { "catppuccin/nvim",                 name = "catppuccin",   priority = 1000 },
        { "echasnovski/mini.nvim",           branch = "main" },
        { "folke/noice.nvim",                lspevent = "VeryLazy", dependencies = "MunifTanjim/nui.nvim" },
        { "tpope/vim-rsi" },
        { "rafamadriz/friendly-snippets" },
        { "garymjr/nvim-snippets" },
        { "neovim/nvim-lspconfig" },
        { "nvim-treesitter/nvim-treesitter", build = ":TSUpdate" },
        { "folke/snacks.nvim",               priority = 1000,       lazy = false },
        { "OXY2DEV/markview.nvim",           lazy = false },
    },
    -- colorscheme that will be used when installing plugins.
    install = { colorscheme = { "catppuccin" } },
    -- automatically check for plugin updates
    checker = { enabled = true },
})
-- Plugins Setup

-- Colorscheme
require("catppuccin").setup {
    integrations = {
        snacks = {
            enabled = true,
            indent_scope_color = "mauve",
        },
    },
    custom_highlights = function(colors)
        return {
            Folded = { bg = colors.none, fg = colors.none }
        }
    end
}

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
vim.opt.conceallevel = 0

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
        bottom_search = true,         -- use a classic bottom cmdline for search
        command_palette = true,       -- position the cmdline and popupmenu together
        long_message_to_split = true, -- long messages will be sent to a split
        inc_rename = false,           -- enables an input dialog for inc-rename.nvim
        lsp_doc_border = true,        -- add a border to hover docs and signature help
    },
})

-- Snacks
require("snacks").setup({
    bigfile = { enabled = true },
    indent = { enabled = true },
    scope = { enabled = true },
    scroll = { enabled = true },
    picker = { enabled = true },
})

vim.keymap.set("n", "<leader>ff", "<Cmd>lua Snacks.picker.files()<CR>", { desc = "Find Files" })
vim.keymap.set("n", "<leader>fg", "<Cmd>lua Snacks.picker.grep()<CR>", { desc = "Grep Files" })

-- Editor
require("mini.ai").setup()
require("mini.jump").setup()
require("mini.pairs").setup()
require("mini.surround").setup()

-- Completion and Formatting
vim.api.nvim_create_autocmd('LspAttach', {
    group = vim.api.nvim_create_augroup('my.lsp', {}),
    callback = function(args)
        local client = assert(vim.lsp.get_client_by_id(args.data.client_id))
        if client:supports_method('textDocument/implementation') then
            -- Create a keymap for vim.lsp.buf.implementation ...
        end
        -- Enable auto-completion. Note: Use CTRL-Y to select an item. |complete_CTRL-Y|
        if client:supports_method('textDocument/completion') then
            -- Optional: trigger autocompletion on EVERY keypress. May be slow!
            -- local chars = {}; for i = 32, 126 do table.insert(chars, string.char(i)) end
            -- client.server_capabilities.completionProvider.triggerCharacters = chars
            vim.lsp.completion.enable(true, client.id, args.buf, { autotrigger = true })
        end
        -- Auto-format ("lint") on save.
        -- Usually not needed if server supports "textDocument/willSaveWaitUntil".
        if not client:supports_method('textDocument/willSaveWaitUntil')
            and client:supports_method('textDocument/formatting') then
            vim.api.nvim_create_autocmd('BufWritePre', {
                group = vim.api.nvim_create_augroup('my.lsp', { clear = false }),
                buffer = args.buf,
                callback = function()
                    vim.lsp.buf.format({ bufnr = args.buf, id = client.id, timeout_ms = 1000 })
                end,
            })
        end
    end,
})

-- Snippets
require("snippets").setup({
    create_autocmd = true,
    create_cmp_source = false,
    friendly_snippets = true,
})

vim.keymap.set({ 'i', 's' }, '<Tab>', function()
    if vim.snippet.active({ direction = 1 }) then
        return '<Cmd>lua vim.snippet.jump(1)<CR>'
    else
        return '<Tab>'
    end
end, { desc = '...', expr = true, silent = true })


vim.keymap.set({ 'i', 's' }, '<S-Tab>', function()
    if vim.snippet.active({ direction = -1 }) then
        return '<Cmd>lua vim.snippet.jump(-1)<CR>'
    else
        return '<Tab>'
    end
end, { desc = '...', expr = true, silent = true })

-- Git
require("mini.diff").setup()

-- Diagnostics
vim.diagnostic.config({
    virtual_text = {}
})

-- Fold
vim.opt.foldmethod = "expr"
vim.opt.foldexpr = "v:lua.vim.treesitter.foldexpr()"
vim.opt.foldtext = ""
vim.opt.foldlevel = 99
vim.opt.foldlevelstart = 1
vim.opt.foldnestmax = 2
vim.opt.foldopen = "all"
vim.opt.foldclose = "all"

-- Treesitter
require 'nvim-treesitter.configs'.setup {
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
}

-- LSP
require 'lspconfig'.lua_ls.setup {
    on_init = function(client)
        if client.workspace_folders then
            local path = client.workspace_folders[1].name
            if path ~= vim.fn.stdpath('config') and (vim.loop.fs_stat(path .. '/.luarc.json') or vim.loop.fs_stat(path .. '/.luarc.jsonc')) then
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

-- Markview
require("markview").setup({
    preview = {
        hybrid_modes = { "n", "i" },
    }
})
