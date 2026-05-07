-- lua/plugins/markdown.lua: Markdown 装飾 + ブラウザプレビュー（mermaid 対応）
return {
  -- バッファ内 Markdown 装飾（見出し・コードブロック枠・チェックボックス等）
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

  -- ブラウザでのライブプレビュー（```mermaid を SVG レンダリング）
  {
    'iamcco/markdown-preview.nvim',
    -- Apple Silicon 向けのプリビルトバイナリが無いため、ソースからビルドする
    build = 'cd app && npx --yes yarn install',
    ft = { 'markdown' },
    init = function()
      vim.g.mkdp_filetypes = { 'markdown' }
      vim.g.mkdp_auto_close = 1
      vim.g.mkdp_theme = 'dark'
    end,
    keys = {
      { '<leader>mp', '<cmd>MarkdownPreview<CR>',       ft = 'markdown', desc = 'Markdown preview start' },
      { '<leader>ms', '<cmd>MarkdownPreviewStop<CR>',   ft = 'markdown', desc = 'Markdown preview stop' },
      { '<leader>mt', '<cmd>MarkdownPreviewToggle<CR>', ft = 'markdown', desc = 'Markdown preview toggle' },
    },
  },
}
