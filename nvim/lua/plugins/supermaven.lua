return {
  "supermaven-inc/supermaven-nvim",
  config = function()
    require("supermaven-nvim").setup({
      log_level = "info", -- ログを有効化して問題を診断
    })
  end,
}
