local function AI()
  -- Get the selected text
  local selected_text = vim.fn.getreg('""', 1, 1) -- Get from default register, linewise selection

  if not selected_text or selected_text == "" then
    print("No text selected.")
    return
  end

  -- Get API key, system prompt, and temperature (from environment variables)
  local api_key = os.getenv("GEMINI_API_KEY")
  local system_prompt = os.getenv("GEMINI_SYSTEM_PROMPT") or "You are a helpful assistant." -- Default prompt if env var is not set
  local temperature = tonumber(os.getenv("GEMINI_TEMPERATURE")) or 0.7 -- Default temperature if env var is not set

  if not api_key then
    print("GEMINI_API_KEY environment variable not set.")
    return
  end

  -- Construct the prompt for Gemini
    local prompt = system_prompt .. "\n\n" .. selected_text

  -- Construct the API request
  local data = {
    model = "gemini",  -- Or the specific Gemini model you're targeting
    prompt = prompt,
    temperature = temperature,
    max_tokens = 2048, -- Adjust as needed
  }

  local data_json = vim.fn.json_encode(data)

  local headers = {
    ["Content-Type"] = "application/json",
    ["Authorization"] = "Bearer " .. api_key,
  }

  -- Make the API request (using curl)
  local handle = io.popen("curl -s -H '" .. table.concat(vim.tbl_map(function(k, v) return k .. ": " .. v end, vim.fn.items(headers)), "' -H '") .. "' -d '" .. data_json .. "' https://api.generativeai.google.com/v1beta2/models/gemini:generateText") -- Replace with actual Gemini API endpoint

  if not handle then
    print("Error opening curl process.")
    return
  end

  local response_json = handle:read("*a")
  handle:close()

  -- Parse the JSON response
  local response = vim.fn.json_decode(response_json)

  if not response or not response.candidates or #response.candidates == 0 then
    print("Error: Invalid or empty response from Gemini API.")
    print(response_json) -- Print the raw response for debugging
    return
  end

  local generated_text = response.candidates[1].output

  -- Paste the generated text after the selection
  vim.api.nvim_feedkeys("a" .. generated_text .. "<Esc>", "n", false) -- "a" for append, <Esc> to exit insert mode

end

return AI
