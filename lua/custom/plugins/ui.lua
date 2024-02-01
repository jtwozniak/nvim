return {
    {
        "folke/noice.nvim",
        dependencies = {
            -- if you lazy-load any plugin below, make sure to add proper `module="..."` entries
            "MunifTanjim/nui.nvim",
            -- OPTIONAL:
            --   `nvim-notify` is only needed, if you want to use the notification view.
            --   If not available, we use `mini` as the fallback
            "rcarriga/nvim-notify",
        },
        opts = {
            presets = {
                lsp_doc_border = true,
            },
            notify = {
                view = "mini",
            },
            lsp = {
                message = {
                    view = "mini",
                },
            },
            routes = {
                {
                    filter = {
                        event = "notify",
                        find = "No information available",
                    },
                    opts = { skip = true },
                },
                {
                    filter = {
                        event = "msg_show",
                        any = {
                            { find = "%d+L, %d+B" },
                            { find = "; after #%d+" },
                            { find = "; before #%d+" },
                        },
                    },
                    view = "mini",
                },
            },
        },
    },
    {
        "rcarriga/nvim-notify",
        opts = {
            timeout = 500,
            render = "compact",
            max_height = function()
                return math.floor(vim.o.lines * 0.75)
            end,
            max_width = function()
                return math.floor(vim.o.columns * 0.25)
            end,
            on_open = function(win)
                vim.api.nvim_win_set_config(win, { zindex = 100 })
            end,
        },
    },
    -- filename
    -- {
    --     "b0o/incline.nvim",
    --     dependencies = { "catppuccin/nvim" },
    --     event = "BufReadPre",
    --     priority = 1200,
    --     config = function()
    --         local colors = require("catppuccin.palettes").get_palette("mocha")
    --         require("incline").setup({
    --             highlight = {
    --                 groups = {
    --                     InclineNormal = { guibg = colors.green, guifg = colors.crust },
    --                     InclineNormalNC = { guibg = colors.overlay2, guifg = colors.surface1 },
    --                 },
    --             },
    --             window = { margin = { vertical = 0, horizontal = 1 } },
    --             hide = { cursorline = true },
    --             render = function(props)
    --                 local filename = vim.fn.fnamemodify(vim.api.nvim_buf_get_name(props.buf), ":t")
    --                 if vim.bo[props.buf].modified then
    --                     filename = "[*]" .. filename
    --                 end
    --
    --                 local icon, color = require("nvim-web-devicons").get_icon_color(filename)
    --
    --                 return { { icon, guifg = color }, { " " }, { filename } }
    --             end,
    --         })
    --     end,
    -- },

    -- bufferline
    -- {
    --     "akinsho/bufferline.nvim",
    --     opts = {
    --         options = {
    --             mode = "tabs",
    --             show_buffer_close_icons = false,
    --             show_close_icon = false,
    --         },
    --     },
    -- },
}
