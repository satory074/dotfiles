-- lua/plugins/markdown.lua: Markdown レンダリング・Mermaid プレビュー
return {
  {
    'MeanderingProgrammer/render-markdown.nvim',
    ft = { 'markdown' },
    opts = {
      heading  = { enabled = true },
      code     = { enabled = true, sign = false },
      bullet   = { enabled = true },
      checkbox = { enabled = true },
    },
  },

  -- Mermaid ダイアグラムのライブプレビュー（Lua 内蔵 HTTP サーバ、外部依存なし）
  {
    'kevalin/mermaid.nvim',
    ft = { 'mermaid', 'mmd' },
    dependencies = { 'nvim-treesitter/nvim-treesitter' },
    config = function()
      require('mermaid').setup()
    end,
  },
}
