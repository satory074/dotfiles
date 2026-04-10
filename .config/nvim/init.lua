-- init.lua: Neovim エントリポイント
-- プラグイン仕様は lua/plugins/ に分割済み
-- vim: ts=2 sts=2 sw=2 et

vim.g.mapleader      = ' '
vim.g.maplocalleader = ' '
vim.g.have_nerd_font = false

-- [[ オプション ]]
vim.o.number       = true
vim.o.mouse        = 'a'
vim.o.showmode     = false
vim.o.breakindent  = true
vim.o.undofile     = true
vim.o.ignorecase   = true
vim.o.smartcase    = true
vim.o.signcolumn   = 'yes'
vim.o.updatetime   = 250
vim.o.timeoutlen   = 300
vim.o.splitright   = true
vim.o.splitbelow   = true
vim.o.list         = true
vim.o.inccommand   = 'split'
vim.o.cursorline   = true
vim.o.scrolloff    = 10
vim.o.confirm      = true
vim.o.expandtab    = true
vim.o.tabstop      = 4
vim.o.shiftwidth   = 4
vim.o.virtualedit  = 'onemore'

vim.opt.listchars = { tab = '» ', trail = '·', nbsp = '␣' }

-- クリップボード共有（起動時間を増やさないよう UiEnter 後に設定）
vim.schedule(function() vim.o.clipboard = 'unnamedplus' end)

-- [[ 診断設定 ]]
vim.diagnostic.config {
  update_in_insert = false,
  severity_sort    = true,
  float            = { border = 'rounded', source = 'if_many' },
  underline        = { severity = { min = vim.diagnostic.severity.WARN } },
  virtual_text     = true,
  virtual_lines    = false,
  jump             = { float = true },
}

-- [[ 基本キーマップ ]]
vim.keymap.set('n', '<Esc>',        '<cmd>nohlsearch<CR>')
vim.keymap.set('i', 'jj',           '<Esc>',          { desc = 'Exit insert mode' })
vim.keymap.set('t', '<Esc><Esc>',   '<C-\\><C-n>',    { desc = 'Exit terminal mode' })
vim.keymap.set('n', '<C-h>',        '<C-w><C-h>',     { desc = 'Move focus to the left window' })
vim.keymap.set('n', '<C-l>',        '<C-w><C-l>',     { desc = 'Move focus to the right window' })
vim.keymap.set('n', '<C-j>',        '<C-w><C-j>',     { desc = 'Move focus to the lower window' })
vim.keymap.set('n', '<C-k>',        '<C-w><C-k>',     { desc = 'Move focus to the upper window' })
vim.keymap.set('n', '<leader>q',    vim.diagnostic.setloclist, { desc = 'Open diagnostic [Q]uickfix list' })

-- [[ オートコマンド ]]

-- ヤンク時にハイライト
vim.api.nvim_create_autocmd('TextYankPost', {
  desc     = 'Highlight when yanking (copying) text',
  group    = vim.api.nvim_create_augroup('kickstart-highlight-yank', { clear = true }),
  callback = function() vim.hl.on_yank() end,
})

-- 保存時に行末空白を削除
vim.api.nvim_create_autocmd('BufWritePre', {
  desc     = 'Remove trailing whitespace on save',
  group    = vim.api.nvim_create_augroup('kickstart-trim-whitespace', { clear = true }),
  callback = function()
    local view = vim.fn.winsaveview()
    vim.cmd([[%s/\s\+$//e]])
    vim.fn.winrestview(view)
  end,
})

-- [[ lazy.nvim プラグインマネージャー ]]
local lazypath = vim.fn.stdpath 'data' .. '/lazy/lazy.nvim'
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  local lazyrepo = 'https://github.com/folke/lazy.nvim.git'
  local out = vim.fn.system { 'git', 'clone', '--filter=blob:none', '--branch=stable', lazyrepo, lazypath }
  if vim.v.shell_error ~= 0 then error('Error cloning lazy.nvim:\n' .. out) end
end
vim.opt.rtp:prepend(lazypath)

require('lazy').setup({
  -- lua/plugins/*.lua を自動インポート
  { import = 'plugins' },
}, { ---@diagnostic disable-line: missing-fields
  ui = {
    icons = vim.g.have_nerd_font and {} or {
      cmd     = '⌘',
      config  = '🛠',
      event   = '📅',
      ft      = '📂',
      init    = '⚙',
      keys    = '🗝',
      plugin  = '🔌',
      runtime = '💻',
      require = '🌙',
      source  = '📄',
      start   = '🚀',
      task    = '📌',
      lazy    = '💤 ',
    },
  },
})
