vim9script

var files_cache: list<string> = []
augroup CmdCompleteResetFind
    au!
    au CmdlineEnter : files_cache = []
augroup END

def FindCmd(): string
    var cmd = ''
    if executable('fd')
        cmd = 'fd . --path-separator / --type f --hidden --follow --exclude .git'
    elseif executable('fdfind')
        cmd = 'fdfind . --path-separator / --type f --hidden --follow --exclude .git'
    elseif executable('ugrep')
        cmd = 'ugrep "" -Rl -I --ignore-files'
    elseif executable('rg')
        cmd = 'rg --path-separator / --files --hidden --glob !.git'
    elseif executable('where') && has('win32')
        cmd = 'where.exe /r . * | findstr /I /V /L "\.git\" | findstr /I /V /R "\.swp$"'
    elseif executable('find')
        cmd = 'find \! \( -path "*/.git" -prune -o -name "*.swp" \) -type f -follow'
    endif
    return cmd
enddef

def Find(cmd_arg: string, cmd_complete: bool): list<string>
    if empty(files_cache)
        var cmd = FindCmd()
        if empty(cmd)
            files_cache = globpath('.', '**', 1, 1)
                ->filter((_, v) => !isdirectory(v))
                ->mapnew((_, v) => v->substitute('^\.[\/]', "", ""))
        else
            files_cache = systemlist(cmd)
                ->mapnew((_, v) => trim(v))
                ->mapnew((_, v) => fnamemodify(v, ':.'))
                ->mapnew((_, v) => v->substitute('\\', "/", "g"))
        endif
    endif
    if empty(cmd_arg)
        return files_cache
    else
        # return files_cache->matchstr(cmd_arg)
        return files_cache->filter($"v:val =~ '{cmd_arg}'")
    endif
enddef

set findfunc=Find
