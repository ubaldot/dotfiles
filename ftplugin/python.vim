vim9script
# Tell vim where is Python. OBS: this is independent of the plugins!
# You must check in the vim version what dll is required in the field -DDYNAMIC_PYTHON_DLL=\python310.dll\

setlocal foldmethod=indent

augroup BLACK
    autocmd!
    autocmd BufWritePost <buffer> {
        if g:use_black
            b:win_view = winsaveview()
            silent exe "!black --line-length " .. &l:textwidth .. " " .. expand('<afile>')
            edit!
            winrestview(b:win_view)
        endif
    }
augroup END

# Manim stuff

# Render in a terminal buffer
def Manim(scene: string="",  hq: bool=false, transparent: bool=false, dryrun: bool=false)
    var flags = ""
    if dryrun
        flags = " --dry_run"
    elseif hq
        flags = " -pqh --media_dir ./output"
    else
        flags = " -pql"
    endif

    if transparent
        flags = flags .. " --transparent"
    endif

    var closeQT = "osascript ~/QuickTimeClose.scpt"
    var cmd = "manim " .. expand("%:t") .. " " .. scene .. flags .. " --fps 30 --disable_caching -v WARNING"
    var terms_name = []
    for ii in term_list()
        add(terms_name, bufname(ii))
    endfor
    echo terms_name
    if term_list() == [] || index(terms_name, 'MANIM') == -1
        vert term_start(&shell, {'term_name': 'MANIM' })
        set nowrap
    endif
    term_sendkeys(bufnr('MANIM'), "clear \n" .. closeQT .. "&& " .. cmd .. "\n")
enddef



export def ManimComplete(arglead: string, cmdline: string, cursorPos: number): list<string>
    var class_names = []
    var class_name = ""

    # Iterate through each line of the Python file
    for line in getline(1, line('$'))
        # Check if the line defines a class (a simple check for 'class <class_name>:')
        if line =~# '^\s*class\s\+\(\w\+\)'
            # Extract the class name and append it to the list
            class_name = matchstr(line, '\s\+\(\w\+\)')
            add(class_names, class_name)
        endif
    endfor
    return class_names
enddef

# Manim user-defined commands
command -nargs=? -complete=customlist,ManimComplete Manim silent call
            \ Manim(<q-args>)
command -nargs=? -complete=customlist,ManimComplete ManimHQ silent call
            \ Manim(<q-args>, true)
command -nargs=? -complete=customlist,ManimComplete ManimHQAlpha silent call
            \ Manim(<q-args>, true, true)
command -nargs=? -complete=customlist,ManimComplete ManimDry silent call
            \ Manim(<q-args>, false, false, true)

# Black
command! Black120 :exe "!black --line-length 120 " .. expand('%')
