return {
  'nvim-treesitter/nvim-treesitter',
  version = "*",
  build = ":TSUpdate",
  config = function()
    require('nvim-treesitter.configs').setup({
      -- パーサーの自動インストール
      ensure_installed = {
        "python",
        "typescript",
        "javascript",
        "ruby",
        "lua",
        "html",
        "css",
        "json",
        "yaml",
        "markdown",
        "bash",
        "vim",
        "gitignore",
      },
      -- シンタックスハイライトを有効化
      highlight = {
        enable = true,
        -- 大きなファイルでもパフォーマンスを維持
        disable = function(lang, buf)
          local max_filesize = 100 * 1024 -- 100 KB
          local ok, stats = pcall(vim.loop.fs_stat, vim.api.nvim_buf_get_name(buf))
          if ok and stats and stats.size > max_filesize then
            return true
          end
        end,
        -- 追加のvim regexハイライトを無効化（パフォーマンス向上）
        additional_vim_regex_highlighting = false,
      },
      -- インクリメンタル選択を有効化
      incremental_selection = {
        enable = true,
        keymaps = {
          init_selection = "gnn",
          node_incremental = "grn",
          scope_incremental = "grc",
          node_decremental = "grm",
        },
      },
      -- インデントを有効化
      indent = {
        enable = true,
      },
      -- 自動タグペアリング
      autotag = {
        enable = true,
      },
    })
  end,
}
