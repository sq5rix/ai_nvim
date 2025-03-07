require("josean.core")
require("josean.lazy")

-- Create the three-window layout
local function create_window_layout(left_margin_size, middle_size, right_margin_size)
  -- Default values if not provided
  left_margin_size = left_margin_size or 20
  middle_size = middle_size or 60
  right_margin_size = right_margin_size or 20

  -- Create splits
  vim.cmd("vsplit")
  vim.cmd("vsplit")

  -- Set up left margin
  vim.cmd("wincmd h")
  vim.cmd("wincmd h")
  vim.cmd("vertical resize " .. left_margin_size)
  vim.cmd("enew")

  -- Set up right margin
  vim.cmd("wincmd l")
  vim.cmd("wincmd l")
  vim.cmd("vertical resize " .. right_margin_size)
  vim.cmd("enew")

  -- Set up middle window
  vim.cmd("wincmd h")
  vim.cmd("vertical resize " .. middle_size)
end

-- Create the five-window layout
local function create_window_layout2(
  left_margin_size,
  middle_left_size,
  middle_gap_size,
  middle_right_size,
  right_gap_size
)
  -- Default values if not provided
  left_margin_size = left_margin_size or 5
  middle_left_size = middle_left_size or 40
  middle_gap_size = middle_gap_size or 10
  middle_right_size = middle_right_size or 40
  right_gap_size = right_gap_size or 10

  -- Ensure sizes add up to 100%

  -- Create splits (need 4 splits for 5 panes)
  vim.cmd("vsplit")
  vim.cmd("vsplit")
  vim.cmd("vsplit")
  vim.cmd("vsplit")

  -- Go to leftmost window
  vim.cmd("wincmd t")

  -- Set up left margin
  vim.cmd("vertical resize " .. left_margin_size)
  vim.cmd("enew")

  -- Move to next window and set up middle-left
  vim.cmd("wincmd l")
  vim.cmd("vertical resize " .. middle_left_size)

  -- Move to next window and set up middle gap
  vim.cmd("wincmd l")
  vim.cmd("vertical resize " .. middle_gap_size)
  vim.cmd("enew")

  -- Move to next window and set up middle-right
  vim.cmd("wincmd l")
  vim.cmd("vertical resize " .. middle_right_size)

  -- Move to rightmost window and set up right panel
  vim.cmd("wincmd l")
  vim.cmd("vertical resize " .. right_gap_size)
  vim.cmd("enew")

  -- Go back to middle-left window to be consistent with original function
  vim.cmd("wincmd t")
  vim.cmd("wincmd l")
end

-- Configure window appearance
local function configure_window_appearance()
  -- Hide split lines
  vim.opt.fillchars = { vert = " " }

  -- Configure all windows
  for _, win in pairs(vim.api.nvim_list_wins()) do
    vim.api.nvim_win_set_option(win, "number", false)
    vim.api.nvim_win_set_option(win, "relativenumber", false)
    vim.api.nvim_win_set_option(win, "wrap", true)
    vim.api.nvim_win_set_option(win, "linebreak", true)
  end
end

-- Configure margin windows
local function configure_margin_window()
  local margin_settings = {
    winhl = "Normal:NonText,CursorLine:NonText,CursorColumn:NonText",
    cursorline = false,
    cursorcolumn = false,
  }

  -- Apply settings to current window
  vim.api.nvim_win_set_option(0, "winhl", margin_settings.winhl)
  vim.wo.cursorline = margin_settings.cursorline
  vim.wo.cursorcolumn = margin_settings.cursorcolumn
end

-- Configure middle window
local function configure_middle_window()
  -- Disable cursor highlighting
  vim.wo.cursorline = false
  vim.wo.cursorcolumn = false

  -- Enable spell checking
  vim.opt.spell = true
  vim.opt.spelllang = "en_us"

  -- Disable search highlighting
  vim.opt.hlsearch = false
  vim.cmd("nohlsearch")

  -- Hide status line
  vim.opt.laststatus = 0
end

-- Main function to create writing mode
local function create_margins(left_margin_size, middle_size, right_margin_size)
  -- Store current buffer number
  local current_buf = vim.api.nvim_get_current_buf()

  -- Default values if not provided
  left_margin_size = left_margin_size or 20
  middle_size = middle_size or 70
  right_margin_size = right_margin_size or 20

  -- Create and configure windows
  create_window_layout(left_margin_size, middle_size, right_margin_size)
  configure_window_appearance()

  -- Configure left margin
  vim.cmd("wincmd h")
  configure_margin_window()

  -- Configure right margin
  vim.cmd("wincmd l")
  vim.cmd("wincmd l")
  configure_margin_window()

  -- Configure middle window
  vim.cmd("wincmd h")
  configure_middle_window()

  -- Set cursor appearance
  vim.opt.guicursor = "n:block-NonText"
end

local function ai(additional_prompt)
  -- Get the selected text
  local selected_text = vim.fn.getreg('""', 1, 1)

  if not selected_text or selected_text == "" then
    print("No text selected.")
    return
  end

  -- Get API key, system prompt, temperature, and top_k from environment variables
  local api_key = os.getenv("GEMINI_API_KEY")
  local system_prompt = os.getenv("GEMINI_SYSTEM_PROMPT") or "You are a helpful assistant."
  local temperature = tonumber(os.getenv("GEMINI_TEMPERATURE")) or 0.7
  local top_k = tonumber(os.getenv("GEMINI_TOP_K")) or 40 -- Default top_k

  if not api_key then
    print("GEMINI_API_KEY environment variable not set.")
    return
  end

  -- Construct the complete prompt
  local prompt = system_prompt .. "\n\n" .. selected_text
  if additional_prompt and additional_prompt ~= "" then
    prompt = prompt .. "\n\n" .. additional_prompt
  end

  -- Construct the API request (including top_k)
  local data = {
    model = "gemini", -- Replace with the correct Gemini model name
    prompt = prompt,
    temperature = temperature,
    top_k = top_k,
    max_tokens = 2048, -- Adjust as needed
  }

  local data_json = vim.fn.json_encode(data)

  local headers = {
    ["Content-Type"] = "application/json",
    ["Authorization"] = "Bearer " .. api_key,
  }

  -- Make the API request (using curl)
  local handle = io.popen(
    "curl -s -H '"
      .. table.concat(
        vim.tbl_map(function(k, v)
          return k .. ": " .. v
        end, vim.fn.items(headers)),
        "' -H '"
      )
      .. "' -d '"
      .. data_json
      .. "' https://api.generativeai.google.com/v1beta2/models/gemini:generateText"
  ) -- Replace with the correct Gemini API endpoint

  if not handle then
    print("Error opening curl process.")
    return
  end

  local response_json = handle:read("*a")
  handle:close()

  -- Parse the JSON response (handle potential errors)
  local response = vim.fn.json_decode(response_json)

  if not response or not response.candidates or #response.candidates == 0 then
    print("Error: Invalid or empty response from Gemini API.")
    print(response_json)
    return
  end

  local generated_text = response.candidates[1].output

  -- Paste the generated text after the selection
  vim.api.nvim_feedkeys("a" .. generated_text .. "<Esc>", "n", false)
end

-- Main function to create writing mode with 5 panes
local function create_margins2(left_margin_size, middle_left_size, middle_gap_size, middle_right_size, right_gap_size)
  -- Store current buffer number
  local current_buf = vim.api.nvim_get_current_buf()

  -- Default values if not provided
  left_margin_size = left_margin_size or 15
  middle_left_size = middle_left_size or 30
  middle_gap_size = middle_gap_size or 10 -- Make panel 3 small (about 10%)
  middle_right_size = middle_right_size or 30
  right_size = right_size or 15

  -- Create and configure windows
  create_window_layout2(left_margin_size, middle_left_size, middle_gap_size, middle_right_size, right_size)
  configure_window_appearance()

  -- Start from the leftmost window and configure each window in order
  -- Go to leftmost window
  vim.cmd("wincmd t")

  -- Configure left margin

  configure_margin_window()

  -- Move to middle-left window
  vim.cmd("wincmd l")

  configure_middle_window()

  -- Move to middle gap
  vim.cmd("wincmd l")
  configure_margin_window() -- Apply margin settings to the gap

  -- Move to middle-right window
  vim.cmd("wincmd l")
  configure_middle_window()

  -- Move to right panel - configure as text panel, not margin
  vim.cmd("wincmd l")
  configure_middle_window() -- Using middle window config instead of margin config

  -- Set cursor appearance
  vim.opt.guicursor = "n:block-NonText"

  -- Return to the middle-left window for convenience
  vim.cmd("wincmd t")
  vim.cmd("wincmd l")
end

vim.api.nvim_create_user_command("AI", ai, {})
vim.api.nvim_create_user_command("WritingMode", function()
  create_margins(20, 60, 20) -- Default sizes for 3-pane layout
end, {})

vim.api.nvim_create_user_command("WritingMode2", function()
  create_margins2(5, 40, 15, 40, 5) -- Default sizes for 5-pane layout (100% total)
end, {})

vim.api.nvim_set_keymap("n", "<leader>w", ":echo wordcount().words<CR>", { noremap = true, silent = true })
