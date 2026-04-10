-- lua/plugins/editor.lua: 基本エディタ拡張プラグイン
return {
  -- インデント幅の自動検出
  { 'NMAC427/guess-indent.nvim', opts = {} },

  -- Git 変更表示（gutter サイン）
  {
    'lewis6991/gitsigns.nvim',
    ---@module 'gitsigns'
    ---@type Gitsigns.Config
    ---@diagnostic disable-next-line: missing-fields
    opts = {
      signs = {
        add          = { text = '+' }, ---@diagnostic disable-line: missing-fields
        change       = { text = '~' }, ---@diagnostic disable-line: missing-fields
        delete       = { text = '_' }, ---@diagnostic disable-line: missing-fields
        topdelete    = { text = '‾' }, ---@diagnostic disable-line: missing-fields
        changedelete = { text = '~' }, ---@diagnostic disable-line: missing-fields
      },
    },
  },

  -- TODO/FIXME/HACK などをハイライト
  {
    'folke/todo-comments.nvim',
    event = 'VimEnter',
    dependencies = { 'nvim-lua/plenary.nvim' },
    ---@module 'todo-comments'
    ---@type TodoOptions
    ---@diagnostic disable-next-line: missing-fields
    opts = { signs = false },
  },
}
