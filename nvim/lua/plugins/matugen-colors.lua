-- ~/.config/nvim/lua/plugins/matugen-colors.lua
-- Loads the matugen colorscheme via lazy.nvim.
-- No external plugin is needed — the colorscheme is self-contained.

return {
  -- A no-op lazy.nvim spec that lets us hook into the colorscheme lifecycle.
  -- The actual plugin is our local matugen module in lua/matugen/.
  {
    name = "matugen-colors",
    -- Point lazy at a dummy dir just to have a spec entry; no external repo needed.
    dir = vim.fn.stdpath("config"),
    lazy = false,   -- Load immediately on startup
    priority = 1000, -- Load before anything else that might set highlights

    config = function()
      -- Apply the colorscheme. If palette.lua doesn't exist yet (matugen hasn't
      -- been run), this will show a warning and exit gracefully.
      require("matugen").setup()
    end,
  },
}
