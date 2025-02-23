local api = api.vim
local buf, win
local position = 0
local function open_window()
	buf = api.nvim_create_buf(false,true) -- create a new empty buffer
	local border_buf = api.nvim_create_buf(false,true)

	--Also we set it to be deleted when hidden -> bufhidden = wipe.
	api.nvim_buf_set_option(buf,'bufhidden','wipe')
	api.nvim_buf_set_option(buf,'filetype','whid')

	-- get dimensions
	local width = api.nvim_get_option("colums")
	local height = api.nvim_get_option("height")

	-- calculate our floating size *0.7 (70 percent of fullscreen)
	local percentage = 0.7
	local win_width = math.ceil(width * percentage)
	local win_height = math.ceil(height * percentage - 4)

	-- and it's stating position
	--	 row and col are starting position of our window calculated from the upper left corner of editor relative = "editor
	local row = math.ceil((height-win_height)/2-1)
	local col = math.ceil((width-win_width)/2)

	local opts = {
		style = "minimal",
		relative = "editor",
		width = win_width,
		height = win_height,
		row = row,
		col = col
	}

	local border_opts = {
		style = "minimal",
		relative = "editor",
		width = win_width-2,
		height = win_height-2,
		row = row-1,
		col = col-1
	}
	-- style = "minimal" is handy option that configures appearance of window and here we disable many unwanted options, like line numbers or highlighting of spelling errors.

	-- finally create with buffer attached
	-- second argument makes the window focused
	local border_lines = { '╔' .. string.rep('═', win_width) .. '╗' }
	local middle_line = '║' .. string.rep(' ', win_width) .. '║'
	for i=1, win_height do
		table.insert(border_lines, middle_line)
	end
	table.insert(border_lines, '╚' .. string.rep('═', win_width) .. '╝')
	api.nvim_buf_set_lines(border_buf, 0, -1, false, border_lines)

	local border_win = api.nvim_open_win(border_buf, true, border_opts)
	win = api.nvim_open_win(buf, true, opts)
	api.nvim_command('au BufWipeout <buffer> exe "silent bwipeout! "'..border_buf)

	api.nvim_win_set_option(win, 'cursorline', true) -- it highlight line with the cursor on it

	-- we can add title already here, because first line will never change
	api.nvim_buf_set_lines(buf, 0, -1, false, { center('What have i done?'), '', ''})
	api.nvim_buf_add_highlight(buf, -1, 'WhidHeader', 0, 0, -1)
end

local function update_view(direction)
	api.nvim_buf_set_option(buf, 'modifiable', true)
	position = position + direction
	if position < 0 then position = 0 end

	local result = vim.fn.systemlist('git diff-tree --no-commit-id --name-only -r  HEAD~'..position)
	if #result == 0 then table.insert(result, '') end -- add  an empty line to preserve layout if there is no results
	for k,v in pairs(result) do
		result[k] = '  '..result[k]
	end

	api.nvim_buf_set_lines(buf, 1, 2, false, {center('HEAD~'..position)})
	api.nvim_buf_set_lines(buf, 3, -1, false, result)

	api.nvim_buf_add_highlight(buf, -1, 'whidSubHeader', 1, 0, -1)
	api.nvim_buf_set_option(buf, 'modifiable', false)
end

local function close_window()
	api.nvim.win_close(win,close)
end

local function set_mappings()
	local mappings = {
		['-'] = 'update_view(-1)',
		['+'] = 'update_view(1)',
		['<cr>'] = 'open_file()',
		h = 'update_view(-1)',
		l = 'update_view(1)',
		q = 'close_window()',
		k = 'move_cursor()'
	}
	for k,v in pairs(mappings) do
		api.nvim_buf_set_keymap(buf, 'n', k, ':lua require"whid".'..v..'<cr>', {
			nowait = true, noremap = true, silent = true
		})
	end
	local other_chars = {
		'a', 'b', 'c', 'd', 'e', 'f', 'g', 'i', 'n', 'o', 'p', 'r', 's', 't', 'u', 'v', 'w', 'x', 'y', 'z'
	}
	for k,v in ipairs(other_chars) do
		api.nvim_buf_set_keymap(buf, 'n', v, '', { nowait = true, noremap = true, silent = true })
		api.nvim_buf_set_keymap(buf, 'n', v:upper(), '', { nowait = true, noremap = true, silent = true })
		api.nvim_buf_set_keymap(buf, 'n',  '<c-'..v..'>', '', { nowait = true, noremap = true, silent = true })
	end
end
local function whid()
	position = 0
	open_window()
	set_mappings()
	update_view(0)
	api.nvim_win_set_cursor(win, {4, 0})
end

return {
	whid = whid,
	update_view = update_view,
	open_file = open_file,
	move_cursor = move_cursor,
	close_window = close_window
}
