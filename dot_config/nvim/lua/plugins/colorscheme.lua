return {
  {
    "folke/tokyonight.nvim",
    opts = {
      style = "night", -- "storm", "moon", "night", or "day"
      transparent = true, -- set true if you want Ghostty's background to show through
    },
  },

  -- Tell LazyVim to use it
  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = "tokyonight",
    },
  },
}
