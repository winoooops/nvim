-- lua/plugins/ai.lua
-- CodeCompanion.nvim for in-editor chat and inline edits.
-- Adapters: Anthropic (primary), OpenAI (secondary), Ollama (fallback).
-- copilot.lua is intentionally commented out — uncomment if you want
-- ghost-text inline suggestions in addition to chat.

return {
  {
    "olimorris/codecompanion.nvim",
    cmd = { "CodeCompanion", "CodeCompanionChat", "CodeCompanionActions" },
    keys = { "<leader>ac", "<leader>aa", "<leader>an", "<leader>ae" },
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-treesitter/nvim-treesitter",
    },
    opts = {
      strategies = {
        chat = { adapter = "anthropic" },
        inline = { adapter = "anthropic" },
      },
      adapters = {
        anthropic = function()
          return require("codecompanion.adapters").extend("anthropic", {
            env = { api_key = "ANTHROPIC_API_KEY" },
            schema = {
              model = { default = "claude-sonnet-4-6" },
            },
          })
        end,
        openai = function()
          return require("codecompanion.adapters").extend("openai", {
            env = { api_key = "OPENAI_API_KEY" },
          })
        end,
        ollama = function()
          return require("codecompanion.adapters").extend("ollama", {
            schema = { model = { default = "llama3.1:latest" } },
          })
        end,
      },
      display = {
        chat = {
          window = { layout = "vertical", width = 0.45 },
        },
      },
    },
  },

  -- ===================================================================
  -- Copilot ghost text — DISABLED by design. Uncomment if you want
  -- inline grey-text suggestions via GitHub Copilot. Requires a Copilot
  -- subscription and `:Copilot auth` on first launch.
  -- ===================================================================
  --[[
  {
    "zbirenbaum/copilot.lua",
    event = "InsertEnter",
    opts = {
      suggestion = { enabled = true, auto_trigger = true, keymap = { accept = "<Tab>" } },
      panel = { enabled = false },
    },
  },
  --]]
}
