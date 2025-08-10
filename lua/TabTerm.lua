local M = {}

local terminals = {}
local current_index = 1
M.terminal_win = nil

local config = {
  separator_right = "",
  separator_left = "",
  separator_first = "█",
  tab_highlight = "%#TablineSel#",
  default_highlight = "%#Tabline#",
  vertical_size = 20,
}

local function updateWinbar()
  local bufnr = vim.api.nvim_get_current_buf()

  local index = nil
  for i, term in ipairs(terminals) do
    if term.bufnr == bufnr then
      index = i
      break
    end
  end

  if index then
    local get_normal_bg = vim.api.nvim_get_hl(0, { name = "Normal" }).bg
    local normal_bg = get_normal_bg and string.format("#%06x", get_normal_bg) or "NONE"

    local get_tab_sel_bg = vim.api.nvim_get_hl(0, { name = "TablineSel" }).bg
    local tab_sel_bg = get_tab_sel_bg and string.format("#%06x", get_tab_sel_bg) or "NONE"

    vim.api.nvim_set_hl(0, "TabTermSeparator", {
      fg = tab_sel_bg,
      bg = normal_bg,
      bold = false,
    })

    -- TODO: Fazer isso mais personalizavél parecido com o que é a statusline/
    -- local winbar = "%="
    local winbar = ""
    for i, term in ipairs(terminals) do
      if i == 1 and i == index then
          winbar = winbar
          .. string.format(
            "%%#TabTermSeparator#%s%s %d:%s %%#TabTermSeparator#%s%%*",
            config.separator_first,
            config.tab_highlight,
            i,
            term.name,
            config.separator_right
          )
      else
        if i == index then
          winbar = winbar
          .. string.format(
            "%%#TabTermSeparator#%s%s %d:%s %%#TabTermSeparator#%s%%*",
            config.separator_left,
            config.tab_highlight,
            i,
            term.name,
            config.separator_right
          )
        else
          winbar = winbar .. string.format("  %d:%s  ", i, term.name)
        end
      end
    end

    -- winbar = winbar ..  "%="
    vim.wo.winbar = winbar
  else
    vim.wo.winbar = ""
  end
end

local function find_terminal_window()
  if M.terminal_win and vim.api.nvim_win_is_valid(M.terminal_win) then
    return M.terminal_win
  end
  for _, win in ipairs(vim.api.nvim_list_wins()) do
    local bufnr = vim.api.nvim_win_get_buf(win)
    for _, term in ipairs(terminals) do
      if term.bufnr == bufnr then
        M.terminal_win = win
        return win
      end
    end
  end
  return nil
end

function M.new(name)
  name = name or ("term" .. (#terminals + 1))

  local win = find_terminal_window()
  if win then
    vim.api.nvim_set_current_win(win)
  else
    vim.cmd("botright split")
    vim.api.nvim_win_set_height(0, config.vertical_size)
    M.terminal_win = vim.api.nvim_get_current_win()
  end

  vim.cmd("term")
  local bufnr = vim.api.nvim_get_current_buf()

  vim.api.nvim_set_option_value('buflisted', false , { buf = 0 })

  vim.api.nvim_buf_set_var(bufnr, 'tabterm_created', true)

  table.insert(terminals, { bufnr = bufnr, name = name })
  current_index = #terminals

  updateWinbar()

  vim.schedule(function()
    updateWinbar()
  end)
end

function M.close(index)
  if not index then
    local bufnr = vim.api.nvim_get_current_buf()
    for i, term in ipairs(terminals) do
      if term.bufnr == bufnr then
        index = i
        break
      end
    end
    if not index then
      print("Not a Terminal Buffer")
      return
    end
  end

  local term = terminals[index]
  if not term then
    -- FIXME: wrong speel
    print("Terminal " .. index .. " dosen't exists.")
    return
  end

  vim.api.nvim_buf_delete(term.bufnr, { force = true })
  table.remove(terminals, index)

  if #terminals == 0 then
    current_index = 1
    if M.terminal_win and vim.api.nvim_win_is_valid(M.terminal_win) then
      vim.api.nvim_set_current_win(M.terminal_win)
      vim.cmd("enew")
      vim.wo.winbar = ""
    else
      M.terminal_win = nil
    end
  else
    if current_index > #terminals then
      current_index = #terminals
    end

    if not (M.terminal_win and vim.api.nvim_win_is_valid(M.terminal_win)) then
      vim.cmd("botright split")
      M.terminal_win = vim.api.nvim_get_current_win()
    else
      vim.api.nvim_set_current_win(M.terminal_win)
    end

    vim.api.nvim_set_current_buf(terminals[current_index].bufnr)
    updateWinbar()
  end
end


function M.toggle()
  local win = find_terminal_window()
  local cur_win = vim.api.nvim_get_current_win()

  if win then
    if win == cur_win then
      vim.api.nvim_win_close(win, true)
      M.terminal_win = nil
    else
      vim.api.nvim_set_current_win(win)
    end
  elseif #terminals > 0 then
    vim.cmd("botright split")
    M.terminal_win = vim.api.nvim_get_current_win()
    vim.api.nvim_set_current_buf(terminals[current_index].bufnr)
    updateWinbar()
  else
    M.new()
  end
end


function M.rename(input)
  -- Se nenhum input foi passado, pedir ao usuário
  if not input or input == "" then
    vim.ui.input({ prompt = "New Name: " }, function(user_input)
      if user_input and user_input ~= "" then
        M.rename(user_input)
      end
    end)
    return
  end

  local index, new_name = input:match("^(%d+):(.+)$")
  if index and new_name then
    index = tonumber(index)
    if terminals[index] then
      terminals[index].name = new_name
      updateWinbar()
    else
      print("Terminal " .. index .. " dosen't exists.")
    end
    return
  end

  -- Caso contrário: input é só o nome novo, então usa o buffer atual
  local bufnr = vim.api.nvim_get_current_buf()
  for i, term in ipairs(terminals) do
    if term.bufnr == bufnr then
      terminals[i].name = input
      updateWinbar()
      return
    end
  end
  -- TODO: Melhorar as mensagens de erro
  print("Can't rename, the current buffers is not a tabterm terminal.")
end


function M.goto(index)
  local term = terminals[index]
  if not term then
    print("Terminal " .. index .. " não existe.")
    return
  end

  current_index = index
  local win = find_terminal_window()
  if win then
    vim.api.nvim_set_current_win(win)
  else
    vim.cmd("botright split")
    M.terminal_win = vim.api.nvim_get_current_win()
  end
  vim.api.nvim_set_current_buf(term.bufnr)
  updateWinbar()
end

function M.setup(user_config)
  config = vim.tbl_extend("force", config, user_config or {})

  vim.api.nvim_create_autocmd("TermOpen", {
    callback = function(args)
      local is_tabterm = pcall(vim.api.nvim_buf_get_var, args.buf, 'tabterm_created')
      if is_tabterm then
        vim.api.nvim_buf_set_option(args.buf, 'buflisted', false)
      end
    end,
  })

vim.api.nvim_create_autocmd("BufWipeout", {
  callback = function(args)
    local ok, created = pcall(vim.api.nvim_buf_get_var, args.buf, 'tabterm_created')
    if ok and created then
      for i, term in ipairs(terminals) do
        if term.bufnr == args.buf then
          table.remove(terminals, i)
          if current_index > #terminals then
            current_index = #terminals
          end
          break
        end
      end
      if M.terminal_win and not vim.api.nvim_win_is_valid(M.terminal_win) then
        M.terminal_win = nil
      end
      if #terminals == 0 then
        vim.wo.winbar = ""
      end
    end
  end,
})
  vim.api.nvim_create_user_command("TabTermToggle", M.toggle, {})

  vim.api.nvim_create_user_command("TabTermNew", M.new, {})

  -- FIXME: pass the logic to module function
  vim.api.nvim_create_user_command("TabTermClose", function(opts)
    if opts.args ~= "" then
      local idx = tonumber(opts.args)
      if idx then
        M.close(idx)
      end
    else
      M.close(nil)
    end
  end, { nargs = "?" })

  vim.api.nvim_create_user_command("TabTermRename", function(opts)
    M.rename(opts.args)
  end, { nargs = "?" })

vim.api.nvim_create_user_command("TabTermGoTo", function(opts)
  local index = tonumber(opts.args) or 1 -- padrão para 1 se não for número
  M.goto(index)
end, { nargs = "?" })

function M.goto(index)
  local term = terminals[index]
  if not term then
    print("Termnal " .. (index or "?") .. "don't exisits.")
    return
  end

  current_index = index
  local win = find_terminal_window()
  if win then
    vim.api.nvim_set_current_win(win)
  else
    vim.cmd("botright split")
    M.terminal_win = vim.api.nvim_get_current_win()
  end
  vim.api.nvim_set_current_buf(term.bufnr)
  updateWinbar()
end

  --TODO: fix this
  -- vim.api.nvim_create_autocmd({ "BufEnter", "TermEnter" }, {
  -- 	callback = function()
  -- 		updateWinbar()
  -- 	end,
  -- })

end

_G.TabTerm = M

return M
