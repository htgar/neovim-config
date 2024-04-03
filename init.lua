local lazypath = vim.fn.stdpath('data') .. '/lazy/lazy.nvim'
if not vim.loop.fs_stat(lazypath) then
    vim.fn.system({
        'git',
        'clone',
        '--filter=blob:none',
        'https://github.com/folke/lazy.nvim.git',
        '--branch=stable', -- latest stable release
        lazypath,
    })
end
vim.opt.rtp:prepend(lazypath)

vim.g.mapleader = ' ' -- Make sure to set `mapleader` before lazy so your mappings are correct
local nmap_leader = function(suffix, rhs, desc)
  vim.keymap.set('n', '<Leader>' .. suffix, rhs, { desc = desc })
end
local xmap_leader = function(suffix, rhs, desc)
  vim.keymap.set('x', '<Leader>' .. suffix, rhs, { desc = desc })
end

require('lazy').setup({
    -- Colorscheme
    {
    'catppuccin/nvim',
    name = 'catppuccin', 
    priority = 1000, 
    config = function()
        vim.cmd.colorscheme 'catppuccin'
    end
    },

    -- Register Keybinds
    {
    'folke/which-key.nvim',
    event = 'VimEnter', -- Sets the loading event to 'VimEnter'
    config = function() -- This is the function that runs, AFTER loading
        require('which-key').setup()

        -- Document existing key chains
        require('which-key').register {
            ['<leader>f'] = { name = '[F]ind', _ = 'which_key_ignore' },
            ['<leader>l'] = { name = '[L]sp', _ = 'which_key_ignore' },
        }
    end,
    },

    -- Basic Utils
    {
    'echasnovski/mini.nvim', 
    version = false, 
    config = function()
        -- Mini Basics
        require('mini.basics').setup()
        vim.opt.tabstop = 4
        vim.opt.shiftwidth = 4
        vim.opt.expandtab = true
        vim.opt.scrolloff = 4
        vim.opt.autoindent = true

        require('mini.ai').setup()
        require('mini.bracketed').setup()
        require('mini.bufremove').setup()
        require('mini.comment').setup()
        require('mini.cursorword').setup()
        require('mini.diff').setup()
        require('mini.pairs').setup()
        require('mini.surround').setup()

        -- UI
        local hipatterns = require('mini.hipatterns')
        hipatterns.setup({
            highlighters = {
                -- Highlight hex color strings (`#rrggbb`) using that color
                hex_color = hipatterns.gen_highlighter.hex_color(),
            },
        })
        require('mini.statusline').setup()
        require('mini.indentscope').setup {
            symbol = '|',
        }
    end
    },

    -- UI
    {
    'folke/noice.nvim',
    event = 'VeryLazy',
    opts = {
        -- add any options here
    },
    dependencies = {
        -- if you lazy-load any plugin below, make sure to add proper `module='...'` entries
        'MunifTanjim/nui.nvim',
    },
    config = function()
        require('noice').setup({
            lsp = {
                -- override markdown rendering so that **cmp** and other plugins use **Treesitter**
                override = {
                    ['vim.lsp.util.convert_input_to_markdown_lines'] = true,
                    ['vim.lsp.util.stylize_markdown'] = true,
                    ['cmp.entry.get_documentation'] = true, -- requires hrsh7th/nvim-cmp
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
    end
    },

    -- Fuzzy finding and File explorer
    {
        "ibhagwan/fzf-lua",
        -- optional for icon support
        dependencies = { "nvim-tree/nvim-web-devicons" },
        config = function()
            -- calling `setup` is optional for customization
            require("fzf-lua").setup({})
            nmap_leader('ff', '<Cmd>FzfLua files<CR>', '[F]uzzy')
            nmap_leader('fg', '<Cmd>FzfLua live_grep<CR>', '[G]rep')
        end
    },

    -- LSP Configuration & Plugins
    {
    'neovim/nvim-lspconfig',
    dependencies = {
        -- Automatically install LSPs to stdpath for neovim
        { 'williamboman/mason.nvim', config = true },
        'williamboman/mason-lspconfig.nvim',
    },
    config = function()
        require("mason").setup()
        require("mason-lspconfig").setup()
        require("mason-lspconfig").setup_handlers {
            -- The first entry (without a key) will be the default handler
            -- and will be called for each installed server that doesn't have
            -- a dedicated handler.
            function (server_name) -- default handler (optional)
                require("lspconfig")[server_name].setup {}
            end,
            -- Next, you can provide a dedicated handler for specific servers.
            -- For example, a handler override for the `rust_analyzer`:
        }
    end
    },
})
