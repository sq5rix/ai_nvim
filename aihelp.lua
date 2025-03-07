local function AI(additional_prompt)
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
  a    .. table.concat(
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
    print(response_json) -- Print the raw response for debugging
    return
  end

  local generated_text = response.candidates[1].output

  -- Paste the generated text after the selection
  vim.api.nvim_feedkeys("a" .. generated_text .. "<Esc>", "n", false)
end

return {
  AI = AI,
}
