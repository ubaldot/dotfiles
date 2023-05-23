vim9script

# Remove trailing white spaces at the end of each line and at the end of the file
export def TrimWhitespace()
    var currwin = winsaveview()
    var save_cursor = getpos(".")
    silent! :keeppatterns :%s/\s\+$//e
    silent! :%s/\($\n\s*\)\+\%$//
    winrestview(currwin)
    setpos('.', save_cursor)
enddef

# Commit a dot.
# It is related to the opened buffer not to pwd!
export def CommitDot()
    # curr_dir = pwd
    cd %:p:h
    exe "!git add -u && git commit -m '.'"
    # cd curr_dir
enddef

export def PushDot()
    cd %:p:h
    exe "!git add -u && git commit -m '.' && git push"
enddef


export def Diff(spec: string)
    vertical new
    setlocal bufhidden=wipe buftype=nofile nobuflisted noswapfile
    var cmd = bufname('#')
    if !empty(spec)
        cmd = "!git -C " .. shellescape(fnamemodify(finddir('.git', '.;'), ':p:h:h')) .. " show " .. spec .. ":#"
    endif
    execute "read " .. cmd
    silent :0d _
    &filetype = getbufvar('#', '&filetype')
    augroup Diff
      autocmd!
      autocmd BufWipeout <buffer> diffoff!
    augroup END
    diffthis
    wincmd p
    diffthis
enddef

export def Redir(cmd: string, rng: number, start: number, end: number)
	for win in range(1, winnr('$'))
		if !empty(getwinvar(win, 'scratch'))
			execute win .. 'windo :close'
		endif
	endfor
    var output = []
	if cmd =~ '^!'
		var cmd_filt = cmd =~ ' %'
			\ ? matchstr(substitute(cmd, ' %', ' ' .. shellescape(escape(expand('%:p'), '\')), ''), '^!\zs.*')
			\ : matchstr(cmd, '^!\zs.*')
		if rng == 0
			output = systemlist(cmd_filt)
		else
			var joined_lines = join(getline(start, end), '\n')
			var cleaned_lines = substitute(shellescape(joined_lines), "'\\\\''", "\\\\'", 'g')
			output = systemlist(cmd_filt .. " <<< $" .. cleaned_lines)
		endif
	else
        var tmp: string
		redir => tmp
		execute cmd
		redir END
		output = split(tmp, "\n")
	endif
	vnew
	w:scratch = 1
	setlocal buftype=nofile bufhidden=wipe nobuflisted noswapfile
	setline(1, output)
enddef

var color_is_shown = false
# export def ColorsShow(clear: bool = false): void
export def ColorsToggle(): void
	if exists('b:prop_ids')
		map(b:prop_ids, (_, p) => prop_remove({id: p}))
	endif

	if color_is_shown
        color_is_shown = false
		return
	endif

    # This is only needed for removing.
	b:prop_ids = []

	for row in range(1, line('$'))
		var current = getline(row)
		var cnt = 1
		var [hex, starts, ends] = matchstrpos(current, '#\x\{6\}', 0, cnt)
		while starts != -1
			var col_tag = "inline_color_" .. hex[1 : ]
			var col_type = prop_type_get(col_tag)
			if col_type == {}
				hlset([{name: col_tag, guibg: hex, guifg: "black"}])
				prop_type_add(col_tag, {highlight: col_tag})
			endif
			add(b:prop_ids, prop_add(row, starts + 1, { length: ends - starts,  type: col_tag }))
			cnt += 1
			[hex, starts, ends] = matchstrpos(current, '#\x\{6\}', 0, cnt)
		endwhile
	endfor
    color_is_shown = true
enddef
