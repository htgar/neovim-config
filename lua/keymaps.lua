vim.g.mapleader = ' '

local nmap_leader = function(suffix, rhs, desc)
  vim.keymap.set('n', '<Leader>' .. suffix, rhs, { desc = desc })
end
local xmap_leader = function(suffix, rhs, desc)
  vim.keymap.set('x', '<Leader>' .. suffix, rhs, { desc = desc })
end

nmap_leader('bb', '<Cmd>Pick buffers<CR>', 'Buffers')
nmap_leader('bd', '<Cmd>lua MiniBufremove.delete()<CR>', 'Delete')
nmap_leader('bw', '<Cmd>lua MiniBufremove.wipeout()<CR>', 'Wipeout')

nmap_leader('fe', '<Cmd>lua MiniFiles.open()<CR>', 'Explore')
nmap_leader('ff', '<Cmd>Pick files<CR>', 'Fuzzy')
nmap_leader('fg', '<Cmd>Pick grep_live<CR>', 'Grep')

nmap_leader('lf', '<Cmd>lua vim.lsp.buf.format()<CR>', 'Format')
xmap_leader('lf', '<Cmd>lua vim.lsp.buf.format()<CR>', 'Format')
nmap_leader('lc', '<Cmd>lua vim.lsp.buf.code_action()<CR>', 'Code Action')
xmap_leader('lc', '<Cmd>lua vim.lsp.buf.code_action()<CR>', 'Code Action')
nmap_leader('lr', '<Cmd>lua vim.lsp.buf.rename()<CR>', 'Rename')
nmap_leader('lR', '<Cmd>lua vim.lsp.buf.references()<CR>', 'References')

vim.keymap.set('n', 'z=', '<Cmd>Pick spellsuggest<CR>', { desc = 'Spelling'})
vim.keymap.set('x', 'z=', '<Cmd>Pick spellsuggest<CR>', { desc = 'Spelling'})

