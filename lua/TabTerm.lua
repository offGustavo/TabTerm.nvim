local M = {}

M.terminals = {}
M.current_index = 1
M.terminal_win = nil

function M.update_winbar()
	local bufnr = vim.api.nvim_get_current_buf()

	local index = nil
	for i, term in ipairs(M.terminals) do
		if term.bufnr == bufnr then
			index = i
			break
		end
	end

	if index then
		local winbar = ""
		for i, term in ipairs(M.terminals) do
			if i == index then
				-- FIXME: add style here
				winbar = winbar .. string.format("%%#TablineSel# [%d:%s] %%*", i, term.name)
			else
				winbar = winbar .. string.format(" [%d:%s] ", i, term.name)
			end
		end
		vim.wo.winbar = winbar
	else
		vim.wo.winbar = ""
	end
end

function M.find_terminal_window()
	if M.terminal_win and vim.api.nvim_win_is_valid(M.terminal_win) then
		return M.terminal_win
	end
	for _, win in ipairs(vim.api.nvim_list_wins()) do
		local bufnr = vim.api.nvim_win_get_buf(win)
		for _, term in ipairs(M.terminals) do
			if term.bufnr == bufnr then
				M.terminal_win = win
				return win
			end
		end
	end
	return nil
end

function M.new_terminal(name)
	name = name or ("term" .. (#M.terminals + 1))

	local win = M.find_terminal_window()
	if win then
		vim.api.nvim_set_current_win(win)
	else
		vim.cmd("split")
		M.terminal_win = vim.api.nvim_get_current_win()
	end

	vim.cmd("term")
	local bufnr = vim.api.nvim_get_current_buf()

	table.insert(M.terminals, { bufnr = bufnr, name = name })
	M.current_index = #M.terminals

	M.update_winbar()

	vim.schedule(function()
		M.update_winbar()
	end)
end

function M.close_terminal(index)
	if not index then
		local bufnr = vim.api.nvim_get_current_buf()
		for i, term in ipairs(M.terminals) do
			if term.bufnr == bufnr then
				index = i
				break
			end
		end
		if not index then
			print("O buffer atual não é um terminal do plugin.")
			return
		end
	end

	local term = M.terminals[index]
	if not term then
		print("Terminal " .. index .. " não existe.")
		return
	end

	vim.api.nvim_buf_delete(term.bufnr, { force = true })
	table.remove(M.terminals, index)

	if #M.terminals == 0 then
		M.current_index = 1
		if M.terminal_win and vim.api.nvim_win_is_valid(M.terminal_win) then
			vim.api.nvim_set_current_win(M.terminal_win)
			vim.cmd("enew")
			vim.wo.winbar = ""
		else
			M.terminal_win = nil
		end
	else
		if M.current_index > #M.terminals then
			M.current_index = #M.terminals
		end

		if not (M.terminal_win and vim.api.nvim_win_is_valid(M.terminal_win)) then
			vim.cmd("split")
			M.terminal_win = vim.api.nvim_get_current_win()
		else
			vim.api.nvim_set_current_win(M.terminal_win)
		end

		vim.api.nvim_set_current_buf(M.terminals[M.current_index].bufnr)
		M.update_winbar()
	end
end

function M.toggle_terminal_window()
	local win = M.find_terminal_window()
	if win then
		vim.api.nvim_win_close(win, true)
		M.terminal_win = nil
	elseif #M.terminals > 0 then
		vim.cmd("split")
		M.terminal_win = vim.api.nvim_get_current_win()
		vim.api.nvim_set_current_buf(M.terminals[M.current_index].bufnr)
		M.update_winbar()
	else
		M.new_terminal()
	end
end

function M.rename_terminal(index, new_name)
	if not index then
		local bufnr = vim.api.nvim_get_current_buf()
		for i, term in ipairs(M.terminals) do
			if term.bufnr == bufnr then
				index = i
				break
			end
		end
		if not index then
			print("O buffer atual não é um terminal do plugin.")
			return
		end
	end

	local term = M.terminals[index]
	if term then
		term.name = new_name or term.name
		M.update_winbar()
		return true
	else
		print("Terminal " .. index .. " não existe.")
		return false
	end
end

function M.goto_terminal(index)
	local term = M.terminals[index]
	if not term then
		print("Terminal " .. index .. " não existe.")
		return
	end

	M.current_index = index
	local win = M.find_terminal_window()
	if win then
		vim.api.nvim_set_current_win(win)
	else
		vim.cmd("split")
		M.terminal_win = vim.api.nvim_get_current_win()
	end
	vim.api.nvim_set_current_buf(term.bufnr)
	M.update_winbar()
end

function M.setup()
	vim.api.nvim_create_user_command("TabTerminalToggle", M.toggle_terminal_window, {})
	vim.api.nvim_create_user_command("TabTerminalNew", M.new_terminal, {})
	vim.api.nvim_create_user_command("TabTerminalClose", function(opts)
		if opts.args ~= "" then
			local idx = tonumber(opts.args)
			if idx then
				M.close_terminal(idx)
			end
		else
			M.close_terminal(nil)
		end
	end, { nargs = "?" })

	vim.api.nvim_create_user_command("TabTerminalRename", function(opts)
		if opts.args ~= "" then
			if opts.args:find(":") then
				local index, new_name = opts.args:match("(%d+):(.+)")
				if index and new_name then
					M.rename_terminal(tonumber(index), new_name)
				end
			else
				M.rename_terminal(nil, opts.args)
			end
		else
			vim.ui.input({ prompt = "Novo nome para o terminal: " }, function(input)
				if input then
					M.rename_terminal(nil, input)
				end
			end)
		end
	end, { nargs = "?" })

	vim.api.nvim_create_autocmd({ "BufEnter", "TermEnter" }, {
		callback = function()
			M.update_winbar()
		end,
	})
end

_G.TabTerminal = M

return M
