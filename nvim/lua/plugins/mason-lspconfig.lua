return {
  "williamboman/mason-lspconfig.nvim",
  version = "*",
  lazy = false,
  dependencies = {
    "williamboman/mason.nvim",
  },
  after = { "mason.nvim" },
  config = function()
    local lsp_servers = { "lua_ls", "pyright", "ruff", "ts_ls", "html", "yamlls", "jsonls" }
    local diagnostics = { "typos_lsp" }
    
    local mason_lspconfig = require("mason-lspconfig")
    local nvim_lsp = require("lspconfig")
    
    -- LSP capabilitiesの設定（nvim-cmpとの統合）
    local capabilities = vim.lsp.protocol.make_client_capabilities()
    capabilities = require('cmp_nvim_lsp').default_capabilities(capabilities)
    
    mason_lspconfig.setup {
      ensure_installed = vim.tbl_flatten({ lsp_servers, diagnostics }),
    }
    
    -- ruby_lspの設定（システムのruby-lspを使用）
    nvim_lsp.ruby_lsp.setup {
      cmd = { "ruby-lsp" }, -- システムのruby-lspを使用（rbenvのshims経由）
      capabilities = capabilities,
      root_dir = nvim_lsp.util.root_pattern("Gemfile", ".git"),
      init_options = {
        formatter = 'auto',
      },
      settings = {
        rubyLsp = {
          -- ホバー情報を有効化
          hover = true,
          -- 診断機能を有効化
          diagnostics = true,
        },
      },
      handlers = {
        -- 診断のハンドラーをカスタマイズ（エラーのseverityを確認）
        ["textDocument/publishDiagnostics"] = function(err, result, ctx, config)
          if err then
            vim.notify("Diagnostic error: " .. vim.inspect(err), vim.log.levels.ERROR)
            return
          end
          -- 診断のseverityを確認してログ出力（デバッグ用）
          if result and result.diagnostics then
            for _, diagnostic in ipairs(result.diagnostics) do
              local severity_name = {
                [1] = "ERROR",
                [2] = "WARN",
                [3] = "INFO",
                [4] = "HINT",
              }
              -- エラーレベルの診断を確認
              if diagnostic.severity == 1 then
                vim.notify("Error diagnostic found: " .. diagnostic.message, vim.log.levels.INFO)
              end
            end
          end
          -- デフォルトのハンドラーを呼び出し
          vim.lsp.handlers["textDocument/publishDiagnostics"](err, result, ctx, config)
        end,
      },
      -- 診断を確実に表示するための設定
      on_attach = function(client, bufnr)
        -- 診断を有効化（バッファ固有の設定）
        vim.diagnostic.config({
          virtual_text = {
            severity = { min = vim.diagnostic.severity.HINT },
            source = "always",
            format = function(diagnostic)
              local severity_map = {
                [vim.diagnostic.severity.ERROR] = "E",
                [vim.diagnostic.severity.WARN] = "W",
                [vim.diagnostic.severity.INFO] = "I",
                [vim.diagnostic.severity.HINT] = "H",
              }
              return string.format("%s: %s", severity_map[diagnostic.severity] or "?", diagnostic.message)
            end,
          },
          signs = {
            text = {
              [vim.diagnostic.severity.ERROR] = "E",
              [vim.diagnostic.severity.WARN] = "W",
              [vim.diagnostic.severity.INFO] = "I",
              [vim.diagnostic.severity.HINT] = "H",
            },
          },
          underline = true,
          update_in_insert = false,
          severity_sort = true,
        }, bufnr)
        
        -- 診断の表示を確実にする
        vim.api.nvim_create_autocmd("BufEnter", {
          buffer = bufnr,
          callback = function()
            vim.diagnostic.show(nil, bufnr)
          end,
        })
      end,
    }
    
    -- rubocopの設定（Rubyのリンター/フォーマッター）
    nvim_lsp.rubocop.setup {
      cmd = { "rubocop", "--lsp" }, -- rubocopのLSPモードを使用
      capabilities = capabilities,
      root_dir = nvim_lsp.util.root_pattern("Gemfile", ".git", ".rubocop.yml"),
    }
    
    -- setup_handlersが利用可能か確認してから使用
    if mason_lspconfig.setup_handlers then
      mason_lspconfig.setup_handlers {
        -- デフォルトハンドラー（すべてのサーバーに適用）
        function(server_name)
          -- typos_lspとpyrightとruby_lspとrubocopは個別に設定済みなのでスキップ
          if server_name == "typos_lsp" or server_name == "pyright" or server_name == "ruby_lsp" or server_name == "rubocop" then
            return
          end
          require("lspconfig")[server_name].setup {
            capabilities = capabilities,
          }
        end,
      }
    end
    
    -- typos_lspの設定
    nvim_lsp.typos_lsp.setup {}
    
    -- pyrightの設定
    nvim_lsp.pyright.setup {
      root_dir = nvim_lsp.util.root_pattern(".venv"),
      -- cmd = { "bash", "-c", "source ./.venv/bin/activate"},
      settings = {
        python = {
          -- 仮想環境のルートパス
          venvPath = ".",
          -- 仮想環境のフォルダ名
          -- venv = ".venv",
          pythonPath = "./.venv/bin/python",
          -- analysis = {
          --   extraPaths = {"."},
          --   autoSearchPaths = true,
          --   useLibraryCodeForTypes = true
          -- }
        }
      }
    }
    -- VS Code風のキーバインド設定
    -- ホバー情報 (Kはそのまま)
    vim.keymap.set('n', 'K', function()
      local clients = vim.lsp.get_clients({ bufnr = 0 })
      if #clients == 0 then
        vim.notify("No LSP client attached", vim.log.levels.WARN)
        return
      end
      vim.lsp.buf.hover()
    end, { desc = "Show hover information" })
    
    -- F12: 定義へ移動 (VS Codeと同じ)
    vim.keymap.set('n', '<F12>', function()
      local clients = vim.lsp.get_clients({ bufnr = 0 })
      if #clients == 0 then
        vim.notify("No LSP client attached", vim.log.levels.WARN)
        return
      end
      vim.lsp.buf.definition()
    end, { desc = "Go to definition" })
    
    -- Ctrl+[: 定義へ移動
    vim.keymap.set('n', '<C-[>', function()
      local clients = vim.lsp.get_clients({ bufnr = 0 })
      if #clients == 0 then
        vim.notify("No LSP client attached", vim.log.levels.WARN)
        return
      end
      vim.lsp.buf.definition()
    end, { desc = "Go to definition" })
    
    -- Shift+F12: 参照を表示 (VS Codeと同じ)
    vim.keymap.set('n', '<S-F12>', function()
      local clients = vim.lsp.get_clients({ bufnr = 0 })
      if #clients == 0 then
        vim.notify("No LSP client attached", vim.log.levels.WARN)
        return
      end
      vim.lsp.buf.references()
    end, { desc = "Show references" })
    
    -- Alt+F12: 定義をピーク (VS Codeと同じ)
    vim.keymap.set('n', '<A-F12>', function()
      local clients = vim.lsp.get_clients({ bufnr = 0 })
      if #clients == 0 then
        vim.notify("No LSP client attached", vim.log.levels.WARN)
        return
      end
      vim.lsp.buf.declaration()
    end, { desc = "Go to declaration" })
    
    -- F2: シンボルの名前変更 (VS Codeと同じ)
    vim.keymap.set('n', '<F2>', '<cmd>lua vim.lsp.buf.rename()<CR>')
    
    -- Ctrl+. : クイックフィックス (VS Codeと同じ)
    vim.keymap.set('n', '<C-.>', '<cmd>lua vim.lsp.buf.code_action()<CR>')
    vim.keymap.set('v', '<C-.>', '<cmd>lua vim.lsp.buf.code_action()<CR>')
    
    -- Ctrl+K Ctrl+F: ドキュメントのフォーマット (VS Codeと同じ)
    vim.keymap.set('n', '<C-k><C-f>', '<cmd>lua vim.lsp.buf.formatting()<CR>')
    vim.keymap.set('v', '<C-k><C-f>', '<cmd>lua vim.lsp.buf.formatting()<CR>')
    
    -- Ctrl+Shift+. : 次の問題へ (VS Codeと同じ)
    vim.keymap.set('n', '<C-S-.>', '<cmd>lua vim.diagnostic.goto_next()<CR>')
    
    -- Ctrl+Shift+, : 前の問題へ (VS Codeと同じ)
    vim.keymap.set('n', '<C-S-,>', '<cmd>lua vim.diagnostic.goto_prev()<CR>')
    
    -- 定義ジャンプ後に下のファイルに戻る (gtはそのまま)
    vim.keymap.set('n', 'gt', '<C-t>')
    
    -- Cmd+クリックで定義ジャンプ（macOS）
    vim.opt.mouse = "a"
    
    -- LSPアタッチ時にキーマッピングを設定
    vim.api.nvim_create_autocmd("LspAttach", {
      callback = function(args)
        local bufnr = args.buf
        local client = vim.lsp.get_client_by_id(args.data.client_id)
        
        -- gd: 定義へジャンプ（一般的なキーマッピング）
        vim.keymap.set('n', 'gd', function()
          vim.lsp.buf.definition()
        end, { buffer = bufnr, desc = "Go to definition" })
        
        -- <D-LeftMouse>を試す（GUI版では動作する可能性がある）
        vim.keymap.set('n', '<D-LeftMouse>', function()
          local pos = vim.fn.getmousepos()
          if pos.winid ~= 0 then
            vim.fn.win_gotoid(pos.winid)
            vim.api.nvim_win_set_cursor(pos.winid, { pos.line, pos.column })
            vim.lsp.buf.definition()
          end
        end, { buffer = bufnr, desc = "Cmd+Click to go to definition" })
      end,
    })

  end,
}
