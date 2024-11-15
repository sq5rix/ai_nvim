vim.g.mapleader = " "

local keymap = vim.keymap -- for conciseness

-- Search yanked text in codebase
keymap.set("n", "\\", function()
  local yanked_text = vim.fn.getreg('"')
  require("telescope.builtin").live_grep({
    default_text = yanked_text,
  })
end, { desc = "Search yanked text in codebase" })

-- File explorer in vertical split
keymap.set("n", "<leader>f", function()
  -- Calculate the width (approximately 1/4 of total width)
  local width = math.floor(vim.api.nvim_get_option("columns") * 0.15)

  -- Check if nvim-tree is open
  local tree_view = require("nvim-tree.view")
  if tree_view.is_visible() then
    -- If tree is visible, close it
    vim.cmd("NvimTreeClose")
  else
    -- If tree is not visible, open it
    vim.g.nvim_tree_width = width
    vim.cmd("NvimTreeOpen")
    vim.cmd("NvimTreeFocus")
    vim.cmd("vertical resize " .. width)
  end
end, { desc = "Toggle file explorer on the left" })

-- Save all files with Ctrl-s
keymap.set("n", "<C-s>", ":wa<CR>", { desc = "Save all files" })
keymap.set("i", "jk", "<ESC>", { desc = "Exit insert mode with jk" })

-- Window resizing with arrows
keymap.set("n", "<Up>", ":resize +2<CR>", { desc = "Increase window height" })
keymap.set("n", "<Down>", ":resize -2<CR>", { desc = "Decrease window height" })
keymap.set("n", "<Left>", ":vertical resize -2<CR>", { desc = "Decrease window width" })
keymap.set("n", "<Right>", ":vertical resize +2<CR>", { desc = "Increase window width" })

keymap.set("n", "<F6>", function()
  -- Get current file path
  local file = vim.fn.expand("%")
  -- Check if it's a Python file
  if vim.fn.fnamemodify(file, ":e") == "py" then
    -- Create horizontal split with 1/3 height if it doesn't exist
    local term_bufnr = nil
    for _, win in ipairs(vim.api.nvim_list_wins()) do
      local buf = vim.api.nvim_win_get_buf(win)
      if vim.bo[buf].buftype == "terminal" then
        term_bufnr = buf
        vim.api.nvim_set_current_win(win)
        break
      end
    end

    if not term_bufnr then
      vim.cmd("split")
      vim.cmd("resize " .. math.floor(vim.api.nvim_win_get_height(0) * 0.33))
      vim.cmd("terminal")
      term_bufnr = vim.api.nvim_get_current_buf()
      -- Remove line numbers in terminal
      vim.cmd("setlocal nonumber norelativenumber")
    end

    -- Send Python execution command to terminal
    local chan_id = vim.b[term_bufnr].terminal_job_id
    vim.api.nvim_chan_send(chan_id, "python3 " .. file .. "\n")
    -- Optional: scroll to bottom of terminal
    vim.cmd("normal! G")
  else
    vim.notify("Not a Python file!", vim.log.levels.WARN)
  end
end, { desc = "Run Python file in split terminal" })
