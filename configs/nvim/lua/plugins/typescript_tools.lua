return {
  {
    "pmizio/typescript-tools.nvim",
    dependencies = { "nvim-lua/plenary.nvim", "neovim/nvim-lspconfig" },
    config = function()
      require("typescript-tools").setup {
        -- General setup options
        -- on_attach = function() ... end,  -- Optionally define your on_attach function here
        -- handlers = { ... },              -- Optionally define custom handlers here
        --
        settings = {
          -- Additional TypeScript server settings
          separate_diagnostic_server = true, -- Spawn additional tsserver instance for diagnostics
          publish_diagnostic_on = "insert_leave", -- When to ask the server about diagnostics

          -- Code actions exposed by the plugin
          expose_as_code_action = { "fix_all", "add_missing_imports", "remove_unused", "remove_unused_imports", "organize_imports" },

          -- Path to `tsserver.js` (default is usually fine)
          tsserver_path = nil,

          -- Plugins to load by tsserver
          tsserver_plugins = {},

          -- Memory limit for tsserver
          tsserver_max_memory = "auto",

          -- Formatting and file preferences
          tsserver_format_options = {},
          tsserver_file_preferences = {},

          -- Locale of tsserver messages
          tsserver_locale = "en",

          -- Completion settings
          complete_function_calls = false,
          include_completions_with_insert_text = true,

          -- CodeLens settings
          code_lens = "off",
          disable_member_code_lens = true,

          -- JSX close tag settings
          jsx_close_tag = {
            enable = false,
            filetypes = { "javascriptreact", "typescriptreact" },
          }
        },
      }

      -- Optional: Override LSP methods
      local api = require("typescript-tools.api")
      require("typescript-tools").setup {
        handlers = {
          ["textDocument/publishDiagnostics"] = api.filter_diagnostics(
            -- Ignore specific diagnostics codes
            { 80006 }
          ),
        },
      }

      -- Optional: Custom tsserver format and file preferences
      require("typescript-tools").setup {
        settings = {
          tsserver_file_preferences = {
            includeInlayParameterNameHints = "all",
            includeCompletionsForModuleExports = true,
            quotePreference = "auto",
          },
          tsserver_format_options = {
            allowIncompleteCompletions = false,
            allowRenameOfImportPath = false,
          }
        },
      }
    end,
  }
}

