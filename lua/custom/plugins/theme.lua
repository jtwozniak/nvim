-- vim.cmd.colorscheme "catppuccin"

return {
  -- {
  --     -- Theme inspired by Atom
  --     'navarasu/onedark.nvim',
  --     -- 'rose-pine/neovim',
  --     priority = 1000,
  --     config = function()
  --         vim.cmd.colorscheme 'onedark'
  --     end,
  -- },
  -- { "metalelf0/jellybeans-nvim" },
  -- { "bluz71/vim-moonfly-colors", name = "moonfly", lazy = false, priority = 1000 },

  {
    "catppuccin/nvim",
    name = "catppuccin",
    priority = 1000,
    opts = {
      flavour = "mocha", -- latte, frappe, macchiato, mocha
      background = {     -- :h background
        light = "latte",
        dark = "mocha",
      },
      transparent_background = false, -- disables setting the background color.
      show_end_of_buffer = false,     -- shows the '~' characters after the end of buffers
      term_colors = false,            -- sets terminal colors (e.g. `g:terminal_color_0`)
      dim_inactive = {
        enabled = false,              -- dims the background color of inactive window
        shade = "dark",
        percentage = 0.15,            -- percentage of the shade to apply to the inactive window
      },
      no_italic = false,              -- Force no italic
      no_bold = false,                -- Force no bold
      no_underline = false,           -- Force no underline
      styles = {                      -- Handles the styles of general hi groups (see `:h highlight-args`):
        comments = { "italic" },      -- Change the style of comments
        conditionals = { "italic" },
        loops = {},
        functions = {},
        keywords = {},
        strings = {},
        variables = {},
        numbers = {},
        booleans = {},
        properties = {},
        types = {},
        operators = {},
      },
      color_overrides = {
        mocha = {
          base = "#0f0f17",
          mantle = "#0c0c12",
          crust = "#08080d",

          rosewater = "#f5b8b0",
          flamingo = "#f29999",
          pink = "#f58fd3",
          mauve = "#c084f9",
          red = "#f36e85",
          maroon = "#e46d77",
          peach = "#fc9764",
          yellow = "#f9db71",
          green = "#87e383",
          teal = "#6ee4c9",
          sky = "#7fcdef",
          sapphire = "#5db9ef",
          blue = "#6d99f9",
          lavender = "#a0a5fd",
          text = "#bcc8ff",
          subtext1 = "#a9b7ff",
          subtext0 = "#97a5ee",
          overlay2 = "#82889f",
          overlay1 = "#6c7289",
          overlay0 = "#575b73",
          surface2 = "#3e415b",
          surface1 = "#2a2c3d",
          surface0 = "#171827",
        }
      },
      custom_highlights = {},
      integrations = {
        cmp = true,
        gitsigns = true,
        nvimtree = true,
        treesitter = true,
        notify = true,
        mini = {
          enabled = true,
          indentscope_color = "",
        },
        native_lsp = {
          enabled = true,
          virtual_text = {
            errors = { "italic" },
            hints = { "italic" },
            warnings = { "italic" },
            information = { "italic" },
          },
          underlines = {
            errors = { "underline" },
            hints = { "underline" },
            warnings = { "underline" },
            information = { "underline" },
          },
          inlay_hints = {
            background = true,
          },
        },
        -- For more plugins integrations please scroll down (https://github.com/catppuccin/nvim#integrations)
      },
    }
  },
  'folke/lsp-colors.nvim'
}
