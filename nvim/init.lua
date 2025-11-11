-- Bootstrap lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  local lazyrepo = "https://github.com/folke/lazy.nvim.git"
  local out = vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath })
  if vim.v.shell_error ~= 0 then
    vim.api.nvim_echo({
      { "Failed to clone lazy.nvim:\n", "ErrorMsg" },
      { out, "WarningMsg" },
      { "\nPress any key to exit..." },
    }, true, {})
    vim.fn.getchar()
    os.exit(1)
  end
end
vim.opt.rtp:prepend(lazypath)

-- Make sure to setup `mapleader` and `maplocalleader` before
-- loading lazy.nvim so that mappings are correct.
-- This is also a good place to setup other settings (vim.opt)
vim.g.mapleader = " "
vim.g.maplocalleader = "\\"
vim.opt.number = true
-- Setup lazy.nvim
require("lazy").setup({
  spec = {
	   { { import = "plugins" } }
    -- add your plugins here
  },
  -- Configure any other settings here. See the documentation for more details.
  -- colorscheme that will be used when installing plugins.
  install = { colorscheme = { "habamax" } },
  -- automatically check for plugin updates
  checker = { enabled = true },
})

-- ファイル切り替え
vim.keymap.set("n", "<C-h>", "<cmd>bprev<CR>")
vim.keymap.set("n", "<C-l>", "<cmd>bnext<CR>")

vim.keymap.set("i", "jj", "<esc>")
vim.keymap.set("i", "kk", "<esc>")

-- 診断の行ハイライト設定
vim.api.nvim_set_hl(0, "DiagnosticErrorLine", { bg = "#4d1a1a", fg = "#ff6b6b", underline = true })
vim.api.nvim_set_hl(0, "DiagnosticWarnLine", { bg = "#3d3d1f", underline = true })
vim.api.nvim_set_hl(0, "DiagnosticHintLine", { bg = "#1f1f3d", underline = true })
vim.api.nvim_set_hl(0, "DiagnosticInfoLine", { bg = "#1f3d3d", underline = true })

vim.diagnostic.config({
  signs = {
    text = {
      -- ...
    },
    linehl = {
      [vim.diagnostic.severity.ERROR] = "DiagnosticErrorLine",
      [vim.diagnostic.severity.WARN] = "DiagnosticWarnLine",
      [vim.diagnostic.severity.HINT] = "DiagnosticHintLine",
      [vim.diagnostic.severity.INFO] = "DiagnosticInfoLine",
    },
  },
})

