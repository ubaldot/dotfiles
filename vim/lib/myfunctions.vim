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

export def GetTextObject(textobject: string): string
    # backup the content of register t (arbitrary choice, YMMV)
    var oldreg = getreg("t")
    # silently yank the text covered by whatever text object
    # was given as argument into register t
    execute 'silent normal "ty' .. textobject
    # save the content of register t into a variable
    var text = getreg("t")
    # restore register t
    setreg("t", oldreg)
    # return the content of given text object
    return text
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
    # For comparing:
    #   1. Your open buffer VS its last saved version (no args)
    #   2. Your open buffer with a given commit
    #
    # Usage: :Diff 12jhu23
    # To exit, just wipe the scratch buffer.
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
    # Used to redirect the output from the terminal in a scratch buffer
    #
    # Example: :Redir !ls
    #
    # You can use it also to redirect the output of some Vim commands
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

# Highlight toggle
# TODO:
# 1) Three different highlights
# 2) Normal mode highlight current line
# 3) Set operation on selection.
export def Highlight()
    if !exists('b:prop_id')
        b:prop_id = 0
    endif
    if prop_type_get('my_hl') == {}
        prop_type_add('my_hl', {'highlight': 'DiffDelete'})
    endif

    var start_line = line("'<")
    var end_line = line("'>")
    var start_col = col("'<")
    var end_col = col("'>")
    # echom prop_list(line('.'), {'types':$ ['my_hl']})
    # echom prop_list(start_line, {'types': ['my_hl']})


    # If there are no prop under the cursor position, then add, otherwise if a
    # prop is detected remove it.
    var no_prop = empty(prop_list(start_line, {'types': ['my_hl']}))
    if no_prop
        prop_add(start_line, start_col, {'end_lnum': end_line, 'end_col': end_col, 'type': 'my_hl', 'id': b:prop_id})
        b:prop_id = b:prop_id + 1
    else
        var id = prop_list(start_line, {'types': ['my_hl']})[0]['id']
        prop_remove({'id': id})
    endif
enddef

# --------- General formatting function -----------------
export def FormatWithoutMoving()
    var view = winsaveview()
    silent normal! gggqG
    winrestview(view)
enddef

command! -nargs=* Prettify execute(":%!prettier " .. expand("%"))


export def QuitWindow()
    # Close window and wipe buffer but it prevent to quit Vim if one window is
    # left.
    if winnr('$') != 1
        quit
    endif
enddef

# ------------ Terminal functions ------------------
# Change all the terminal directories when you change vim directory
export def ChangeTerminalDir()
    for ii in term_list()
        if bufname(ii) == "JULIA"
            term_sendkeys(ii, 'cd("' .. getcwd() .. '")' .. "\n")
        else
            term_sendkeys(ii, "cd " .. getcwd() .. "\n")
        endif
    endfor
enddef

# Close all terminals with :qa!
export def WipeoutTerminals()
    for buf_nr in term_list()
        exe "bw! " .. buf_nr
    endfor
enddef

# TERMINAL IN POPUP
# This function can be called only from a terminal windows/popup, so there is
# no risk of closing unwanted popups (such as HelpMe popups).

export def Quit_term_popup(quit: bool)
    if empty(popup_list())
        if quit
            exe "quit"
        else
            exe "close"
        endif
    else
        if quit
            var bufno = bufnr()
            popup_close(win_getid())
            exe "bw! " .. bufno
        else
            popup_close(win_getid())
        endif
    endif
enddef

var my_term_name = &shell
export def OpenMyTerminal()
    var terms_name = []
    for ii in term_list()
        add(terms_name, bufname(ii))
    endfor

    if term_list() == [] || index(terms_name, my_term_name) == -1
        # enable the following and remove the popup_create part if you want
        # the terminal in a "classic" window.
        # vert term_start(&shell, {'term_name': 'MANIM' })
        var os_shell = ""
        if g:os == "Windows"
            os_shell = "powershell"
        else
            os_shell = &shell
        endif
        var buf_no = term_start(os_shell, {'term_name': my_term_name, 'hidden': 1, 'term_finish': 'close'})
        # echom bufname(buf_no)
        setbufvar(bufname(buf_no), '&buflisted', 0)
        # win_execute(bufwinid(buf_no), 'setlocal nobuflisted')
        # setbufvar(buf_no, 'wrap', 0)
    endif

    popup_create(bufnr(my_term_name), {
        title: my_term_name,
        line: &lines,
        col: &columns,
        pos: "botright",
        posinvert: false,
        borderchars: ['─', '│', '─', '│', '╭', '╮', '╯', '╰'],
        border: [1, 1, 1, 1],
        maxheight: &lines - 1,
        minwidth: 80,
        minheight: 20,
        close: 'button',
        resize: true
        })
enddef

export def HideMyTerminal()
    var terms_name = []
    for ii in term_list()
        add(terms_name, bufname(ii))
    endfor
    # This works because once a terminal popup is in place, it takes all the
    # focus and you cannot go anywhere if you don't close it first.
    if index(terms_name, my_term_name) != -1 && !empty(popup_list())
        popup_close(popup_list()[0])
    endif
enddef


# Make vim to speak on macos
if has('mac')
    # <esc> is used in xnoremap because '<,'> are updated once you leave visual mode
    xnoremap <leader>s <esc><ScriptCmd>TextToSpeech(line("'<"), line("'>"))<cr>
    command -range Say vim9cmd TextToSpeech(<line1>, <line2>)

    def TextToSpeech(firstline: number, lastline: number)
        exe $":{firstline},{lastline}w !say"
    enddef
endif

# Some mappings to learn
noremap <unique> <script> <Plug>Highlight <esc><ScriptCmd>Highlight()

# HOW TO WRITE FUNCTION THAT ALLOW COMMAND TO HAVE DOUBLE COMPLETION.
# noremap <unique> <script> <Plug>Highlight2 <esc><ScriptCmd>Highlight('WildMenu')
#

# Example of user-command with multiple args from different lists
# command! -nargs=* -complete=customlist,FooCompleteNope Manim call Foo(<f-args>)

# def FooComplete(current_arg: string, command_line: string, cursor_position: number): list<string>
#   # split by whitespace to get the separate components:
#   var parts = split(command_line, '\s\+')

#   if len(parts) > 2
#     # then we're definitely finished with the first argument:
#     return SecondCompletion(current_arg)
#   elseif len(parts) > 1 && current_arg =~ '^\s*$'
#     # then we've entered the first argument, but the current one is still blank:
#     return SecondCompletion(current_arg)
#   else
#     # we're still on the first argument:
#     return FirstCompletion(current_arg)
#   endif
# enddef

# def FirstCompletion(arg: string): list<string>
#     return ['pippo', 'pluto', 'stocazzo']->filter($'v:val =~ "^{arg}"')
# enddef

# def SecondCompletion(arg: string): list<string>
#     return ['cazzo', 'figa']->filter($'v:val =~ "^{arg}"')
# enddef
