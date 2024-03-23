vim9script
# Tell vim where is Python. OBS: this is independent of the plugins!
# You must check in the vim version what dll is required in the field -DDYNAMIC_PYTHON_DLL=\python310.dll\

setlocal foldmethod=indent

var null_device = "/dev/null"
if has("win32")
    null_device = "nul"
endif

# set formatprg=black\ -q\ 2>/dev/null\ --stdin-filename\ %\ -
# augroup BLACK
#     autocmd! * <buffer>
#     autocmd BufWritePre <buffer> exe "norm gggqG"
# augroup END

# Autocmd to format with black.
augroup BLACK
    autocmd! * <buffer>
    autocmd BufWritePre <buffer> call Black(&l:textwidth)
augroup END

def Black(textwidth: number)
        var win_view = winsaveview()
        exe $":%!cat {shellescape(expand("%"))} | black - -q 2>{null_device} --line-length {textwidth}"
        winrestview(win_view)
enddef

# Call black to format 120 line length
command! Black120 call Black(120)

# Render in a terminal buffer
def Manim(scene: string="", pre_cmd: string="", flags: string="")
    var manim_cmd = "manim " .. expand("%:t") .. " " .. scene .. " " .. flags

    # Setup terminal
    var terms_name = []
    for ii in term_list()
        add(terms_name, bufname(ii))
    endfor
    # echo terms_name
    # TODO
    # You may want to replace this part with something like (once you created
    # a manim.vim compiler in compiler (obs! check if you have python filetype)
    # var temp = &compiler
    # &compiler = manim
    # manim_pre_cmd .. " && " make! manim cmd
    # &compiler = temp
    if term_list() == [] || index(terms_name, 'MANIM') == -1
        vert term_start(&shell, {'term_name': 'MANIM' })
        set nowrap
    endif

    # Send command
    term_sendkeys(bufnr('MANIM'), pre_cmd .. " && " .. manim_cmd .. "\r\n")
enddef


# Render in a terminal popup (cute but not practical).
def ManimPopup(scene: string="",  manim_pre_cmd: string="", flags: string="")
    var manim_cmd = "manim " .. expand("%:t") .. " " .. scene .. " " .. flags

    # Setup terminal
    var terms_name = []
    for ii in term_list()
        add(terms_name, bufname(ii))
    endfor
    # echo terms_name
    if term_list() == [] || index(terms_name, 'MANIM') == -1
        term_start(&shell, {'term_name': 'MANIM', 'hidden': 1, 'term_finish': 'close'})
        set nowrap
    endif
    # Add popup
    b:manim_pup_id = popup_create(bufnr('MANIM'), {
        title: " Manim ",
        line: &lines,
        col: &columns,
        pos: "botright",
        posinvert: false,
        borderchars: ['─', '│', '─', '│', '╭', '╮', '╯', '╰'],
        border: [1, 1, 1, 1],
        maxheight: &lines - 1,
        minwidth: 80,
        minheight: 30,
        close: 'button',
        resize: true
        })

    # Send command
    term_sendkeys(bufnr('MANIM'), manim_pre_cmd .. " && " .. manim_cmd .. "\n")
    # popup_close(b:manim_pup_id)
enddef

def ManimComplete(arglead: string, cmdline: string, cursorPos: number): list<string>
    var class_names = []
    var class_name = ""

    # Iterate through each line of the Python file
    for line in getline(1, line('$'))
        # Check if the line defines a class (a simple check for 'class <class_name>:')
        if line =~# '^\s*class\s\+\(\w\+\)'
            # Extract the class name and append it to the list
            # class_name = matchstr(line, '\s\+\(\w\+\)')
            # \zs start of the match, \ze end of the match
            class_name = matchstr(line, '^\s*class\s\+\zs\w\+\ze')
            add(class_names, class_name)
        endif
    endfor
    return class_names
enddef

# Flags
var manim_standard = " --fps 30 --disable_caching -v WARNING --save_sections"
var manim_pre_cmd = "clear && osascript ~/QuickTimeClose.scpt"
if has("gui_win32") || has("win32")
    manim_pre_cmd = "cls"
endif
var manim_lq = "-pql" .. manim_standard
var manim_dry_run = "--dry_run" .. manim_standard
var manim_hq = "-pqh -c ~/Documents/YouTube/ControlTheoryInPractice/github_ctip/ctip_manim.cfg" .. manim_standard

# Manim user-defined commands. Use Manim or ManimPopup (which I find not
# practical), e.g. ManimPopup(<q-args>, manim_lq)
command! -nargs=? -complete=customlist,ManimComplete Manim silent Manim(<q-args>, manim_pre_cmd, manim_lq)
command! -nargs=? -complete=customlist,ManimComplete ManimHQ silent Manim(<q-args>, manim_pre_cmd, manim_hq)
command! -nargs=? -complete=customlist,ManimComplete ManimHQAlpha silent Manim(<q-args>, manim_pre_cmd, manim_hq .. " --transparent")
command! -nargs=? -complete=customlist,ManimComplete ManimDry silent Manim(<q-args>, manim_pre_cmd, manim_dry_run)

# Jump to next-prev section
nnoremap <buffer> <c-m> /\<self.next_section\><cr>
nnoremap <buffer> <c-n> ?\<self.next_section\><cr>
