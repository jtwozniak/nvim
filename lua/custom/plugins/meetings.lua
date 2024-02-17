return {
  {
    "janusz/meetings",
    -- dir = "~/.config/nvim/mine/meetings",
    dev = true,
    dependencies = {
      'nvim-lua/plenary.nvim',
    },
    config = function()
      require('meetings').setup()
      print 'test'
    end

  }
}
