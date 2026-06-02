return {
  "yetone/avante.nvim",
  event = "VeryLazy",
  lazy = false,
  enabled = false,
  version = false, -- set this if you want to always pull the latest change
  -- comment options to get claude
  opts = {
    -- add opts here
    provider = "claude",
    mode = "legacy",
    enable_fastapply = true,
    auto_suggestions_provider = "gemini", -- Using Gemini for auto-suggestions as it's free
    -- openai = {
    --   endpoint = "https://api.deepseek.com/v1",
    --   model = "deepseek-chat",
    --   timeout = 3000, -- Timeout in milliseconds
    --   temperature = 0,
    --   max_tokens = 4096,
    --   -- optional
    --   disable_tools = true, -- disable tools!
    --   api_key_name = "DEEP_SEEK_API_KEY", -- default OPENAI_API_KEY if not set
    -- },
    -- claude = {
    --   endpoint = "https://api.anthropic.com",
    --   model = "claude/claude-3-7-sonnet-20250219",
    --   timeout = 3000, -- Timeout in milliseconds
    --   temperature = 0,
    --   max_tokens = 4096,
    --   disable_tools = true, -- disable tools!
    --   api_key_name = "ANTHROPIC_API_KEY", -- default OPENAI_API_KEY if not set
    -- },
    providers = {
      claude = {
        endpoint = "https://api.anthropic.com",
        model = "claude-3-7-sonnet-20250219",
        -- model = "claude-sonnet-4-20250514",
        timeout = 30000, -- Timeout in milliseconds
        disable_tools = true, -- disable tools!
        extra_request_body = {
          temperature = 0,
          max_tokens = 4096,
        },
      },
      gemini = {
        -- endpoint = "https://generativelanguage.googleapis.com",
        model = "gemini-2.0-flash",
        timeout = 10000, -- Timeout in milliseconds
        disable_tools = true, -- disable tools!
        api_key_name = "GEMINI_API_KEY",
        extra_request_body = {
          temperature = 0.2,
          maxOutputTokens = 1024,
        },
      },
    },
  },
  -- if you want to build from source then do `make BUILD_FROM_SOURCE=true`
  build = "make",
  -- build = "powershell -ExecutionPolicy Bypass -File Build.ps1 -BuildFromSource false" -- for windows
  dependencies = {
    "nvim-treesitter/nvim-treesitter",
    "stevearc/dressing.nvim",
    "nvim-lua/plenary.nvim",
    "MunifTanjim/nui.nvim",
    --- The below dependencies are optional,
    "nvim-mini/mini.pick", -- for file_selector provider mini.pick
    "ibhagwan/fzf-lua", -- for file_selector provider fzf
    "nvim-tree/nvim-web-devicons", -- or echasnovski/mini.icons
    {
      -- support for image pasting
      "HakonHarnes/img-clip.nvim",
      event = "VeryLazy",
      opts = {
        -- recommended settings
        default = {
          embed_image_as_base64 = false,
          prompt_for_file_name = false,
          drag_and_drop = {
            insert_mode = true,
          },
          -- required for Windows users
          use_absolute_path = true,
        },
      },
    },
    {
      -- Make sure to set this up properly if you have lazy=true
      "MeanderingProgrammer/render-markdown.nvim",
      opts = {
        file_types = { "markdown", "Avante" },
      },
      ft = { "markdown", "Avante" },
    },
  },
}
