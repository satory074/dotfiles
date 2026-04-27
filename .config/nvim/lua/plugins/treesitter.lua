-- lua/plugins/treesitter.lua: シンタックスハイライト・インデント（Treesitter）
-- main ブランチ + Neovim 0.12 バンドル済みパーサを使用
-- バンドル済み: bash, c, lua, markdown, markdown_inline, vim, vimdoc など
return {
  {
    'nvim-treesitter/nvim-treesitter',
    build = ':TSUpdate',
    event = { 'BufReadPost', 'BufNewFile' },
    config = function()
      local function treesitter_try_attach(buf, language)
        if not vim.treesitter.language.add(language) then return end
        vim.treesitter.start(buf, language)
        vim.bo[buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
      end

      vim.api.nvim_create_autocmd('FileType', {
        callback = function(args)
          local language = vim.treesitter.language.get_lang(args.match)
          if language then
            treesitter_try_attach(args.buf, language)
          end
        end,
      })
    end,
  },
}
