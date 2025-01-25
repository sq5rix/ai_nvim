require("josean.core")
require("josean.lazy")

local function create_margins()
  -- Store current buffer number
  local current_buf = vim.api.nvim_get_current_buf()

  -- Create splits
  vim.cmd("vsplit")
  vim.cmd("vsplit")
  vim.cmd("vertical resize 20")

  -- Set up left margin window
  vim.cmd("wincmd h")
  vim.cmd("wincmd h")
  vim.cmd("vertical resize 20")

  vim.cmd("enew")
  -- Set up middle window with content
  vim.cmd("wincmd l")

  vim.cmd("wincmd l")
  vim.cmd("wincmd l")
  vim.cmd("vertical resize 70")
  vim.cmd("enew")
  vim.cmd("wincmd h")
  vim.cmd("wincmd h")

  -- Hide split lines
  vim.opt.fillchars = { vert = " " }

  -- Remove numbers and make all windows 'invisible'
  for _, win in pairs(vim.api.nvim_list_wins()) do
    vim.api.nvim_win_set_option(win, "number", false)
    vim.api.nvim_win_set_option(win, "relativenumber", false)
    vim.api.nvim_win_set_option(win, "wrap", true)
  end

  -- Go to left window and remove all highlights including cursor
  vim.cmd("wincmd h")
  vim.cmd("wincmd h")
  vim.api.nvim_win_set_option(0, "winhl", "Normal:NonText,CursorLine:NonText,CursorColumn:NonText")
  vim.wo.cursorline = false
  vim.wo.cursorcolumn = false
  vim.opt.guicursor = "n:block-NonText"

  -- Go to right window and remove all highlights including cursor
  vim.cmd("wincmd l")
  vim.cmd("wincmd l")
  vim.api.nvim_win_set_option(0, "winhl", "Normal:NonText,CursorLine:NonText,CursorColumn:NonText")
  vim.wo.cursorline = false
  vim.wo.cursorcolumn = false
  vim.opt.guicursor = "n:block-NonText"

  -- Return to middle window and set its options
  vim.cmd("wincmd h")
  vim.opt.spell = true
  vim.opt.spelllang = "en_us"

  vim.opt.laststatus = 0 -- Always show the status line
end

vim.api.nvim_create_user_command("WritingMode", create_margins, {})
