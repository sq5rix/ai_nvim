return {
  "folke/tokyonight.nvim",
  priority = 1000,
  config = function()
    local transparent = false -- set to true if you would like to enable transparency

    local bg = "#011F35"      -- Slightly darker background
    local bg_dark = "#011B2E" -- Slightly darker background
    local bg_highlight = "#2A5C94" -- Further lightened
    local bg_search = "#2196F3" -- Further lightened
    local bg_visual = "#4B8AC2" -- Further lightened
    local fg = "#F0F7FC"      -- Further lightened
    local fg_dark = "#E2EEF8" -- Further lightened
    local fg_gutter = "#C0D6E8" -- Even more lightened for better comment visibility
    local border = "#9EBFD4"  -- Further lightened

    require("tokyonight").setup({
      style = "night",
      transparent = transparent,
      styles = {
        sidebars = transparent and "transparent" or "dark",
        floats = transparent and "transparent" or "dark",
      },
      on_colors = function(colors)
        colors.bg = bg
        colors.bg_dark = transparent and colors.none or bg_dark
        colors.bg_float = transparent and colors.none or bg_dark
        colors.bg_highlight = bg_highlight
        colors.bg_popup = bg_dark
        colors.bg_search = bg_search
        colors.bg_sidebar = transparent and colors.none or bg_dark
        colors.bg_statusline = transparent and colors.none or bg_dark
        colors.bg_visual = bg_visual
        colors.border = border
        colors.fg = fg
        colors.fg_dark = fg_dark
        colors.fg_float = fg
        colors.fg_gutter = fg_gutter
        colors.fg_sidebar = fg_dark
      end,
    })

    vim.cmd("colorscheme tokyonight")
  end,
}
