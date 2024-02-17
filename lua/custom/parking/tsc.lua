return {
    {
        'dmmulroy/tsc.nvim',
        opts = {
            auto_open_qflist = true,
            auto_close_qflist = false,
            auto_focus_qflist = false,
            auto_start_watch_mode = true,
            enable_progress_notifications = true,
            flags = {
                noEmit = true,
                watch = true,
            },
            hide_progress_notifications_from_history = true,
            spinner = { "⣾", "⣽", "⣻", "⢿", "⡿", "⣟", "⣯", "⣷" },
            pretty_errors = true,
        }
    }
}
