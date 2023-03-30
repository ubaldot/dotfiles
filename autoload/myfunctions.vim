vim9script

# Remove trailing white spaces at the end of each line and at the end of the file
export def g:TrimWhitespace()
    var currwin = winsaveview()
    var save_cursor = getpos(".")
    silent! :keeppatterns :%s/\s\+$//e
    silent! :%s/\($\n\s*\)\+\%$//
    winrestview(currwin)
    setpos('.', save_cursor)
enddef

# Commit a dot.
# It is related to the opened buffer not to pwd!
export def g:CommitDot()
    # curr_dir = pwd
    cd %:p:h
    exe "!git add -u && git commit -m '.'"
    # cd curr_dir
enddef

# Manim stuff
# Render with bang.
export def g:Manim(scene: string, dryrun: bool)
    var flags = ""
    if dryrun
        flags = " --dry_run"
    else
        flags = " -pql"
    endif
    var closeQT = "osascript ~/QuickTimeClose.scpt"
    var cmd = "manim " .. shellescape(expand("%:t")) .. " " .. scene .. flags .. " --disable_caching -v WARNING"
    exe "!" .. closeQT .. " && " .. cmd
enddef

# Render in a terminal buffer
export def g:ManimTerminal(scene: string, dryrun: bool)
    var flags = ""
    if dryrun
        flags = " --dry_run"
    else
        flags = " -pql"
    endif
    var closeQT = "osascript ~/QuickTimeClose.scpt"
    var cmd = "manim " .. expand("%:t") .. " " .. scene .. flags .. " --disable_caching -v WARNING"
    var terms_name = []
    for ii in term_list()
        add(terms_name, bufname(ii))
    endfor
    echo terms_name
    if term_list() == [] || index(terms_name, 'MANIM') == -1
        vert term_start(g:current_terminal, {'term_name': 'MANIM' })
        set nowrap
    endif
    term_sendkeys('MANIM', "clear \n" .. closeQT .. "&& " .. cmd .. "\n")
enddef
