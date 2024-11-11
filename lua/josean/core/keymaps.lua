vim.g.mapleader = " "

local keymap = vim.keymap -- for conciseness

keymap.set("i", "jk", "<ESC>", { desc = "Exit insert mode with jk" })

keymap.set("n", "<leader>nh", ":nohl<CR>", { desc = "Clear search highlights" })

-- window management
keymap.set("n", "<leader>sv", "<C-w>v", { desc = "Split window vertically" }) -- split window vertically
keymap.set("n", "<leader>sh", "<C-w>s", { desc = "Split window horizontally" }) -- split window horizontally
keymap.set("n", "<leader>se", "<C-w>=", { desc = "Make splits equal size" }) -- make split windows equal width & height
keymap.set("n", "<leader>sx", "<cmd>close<CR>", { desc = "Close current split" }) -- close current split window

keymap.set("n", "<leader>to", "<cmd>tabnew<CR>", { desc = "Open new tab" }) -- open new tab
keymap.set("n", "<leader>tx", "<cmd>tabclose<CR>", { desc = "Close current tab" }) -- close current tab
keymap.set("n", "<leader>tn", "<cmd>tabn<CR>", { desc = "Go to next tab" }) --  go to next tab
keymap.set("n", "<leader>tp", "<cmd>tabp<CR>", { desc = "Go to previous tab" }) --  go to previous tab
keymap.set("n", "<leader>tf", "<cmd>tabnew %<CR>", { desc = "Open current buffer in new tab" }) --  move current buffer to new tab

keymap.set("n", "<leader>tf", "<cmd>tabnew %<CR>", { desc = "Open current buffer in new tab" }) --  move current buffer to new tab

-- Window resizing with arrows
keymap.set("n", "<Up>", ":resize +2<CR>", { desc = "Increase window height" })
keymap.set("n", "<Down>", ":resize -2<CR>", { desc = "Decrease window height" })
keymap.set("n", "<Left>", ":vertical resize -2<CR>", { desc = "Decrease window width" })
keymap.set("n", "<Right>", ":vertical resize +2<CR>", { desc = "Increase window width" })

-- Python file execution in split terminal
keymap.set("n", "<F6>", function()
    -- Get current file path
    local file = vim.fn.expand('%')
    -- Check if it's a Python file
    if vim.fn.fnamemodify(file, ':e') == 'py' then
        -- Create horizontal split with 1/3 height
        vim.cmd('split')
        vim.cmd('resize ' .. math.floor(vim.api.nvim_win_get_height(0) * 0.33))
        -- Open terminal and execute Python file
        vim.cmd('terminal python3 ' .. file)
        -- Optional: scroll to bottom of terminal
        vim.cmd('normal! G')
    else
        vim.notify("Not a Python file!", vim.log.levels.WARN)
    end
end, { desc = "Run Python file in split terminal" })

