vim9script

# Termdebug stuff
#
# 1. It opens openocd in a terminal
# 2. Connect gdb to openocd via telnet (see gdb_init_commands.txt)
# 3. Be sure that the local and the loaded on target .elf files are the same.
#
# OBS! Be sure to be in the project root folder and that a build/ folder exists!
#
# OBS! The windows debugger sucks. It is based on cmd.exe. Use an external debugger (like use MinGW64).

# 1. OpenOCD settings
var openocd_sh = "source ../gdb_stuff/openocd_stm32f4x_stlink.sh\n"
var openocd_bat = "cmd.exe /c ..\\gdb_stuff\\openocd_stm32f4x_stlink.bat\n\r"
var openocd_cmd = g:os == "Windows" ? openocd_bat : openocd_sh
g:debug_openocd_command = openocd_cmd

# 2. Debugger settings
g:termdebug_config = {}
var debugger = "arm-none-eabi-gdb"
var elf_file = $"build/{fnamemodify(getcwd(), ':t')}.elf"
var debugger_args = ["-x", "../gdb_stuff/gdb_init_commands.txt", "-ex", $"file {elf_file}"]
g:termdebug_config['command'] = insert(debugger_args, debugger, 0)

g:termdebug_config['variables_window'] = 1

# Other globals
g:debug_monitor_command = "make monitor"
g:debug_show_monitor = true
g:debug_elf_file = $"build/{fnamemodify(getcwd(), ':t')}.elf"

g:debug_gdb_win_height = 8
g:debug_monitor_win_height = 20

# Run all the machinery
packadd termdebug
def MyTermdebug()
    # The .elf name is supposed to be the same as the project name.
    # Before calling this function you must launch a openocd server.
    # This happens inside this script with

    #   source ../openocd_stm32f4x_stlink.sh
    #
    # Then Termdebug is launched.
    # When Termdebug is closed, then the server is automatically shutoff

    # 1. Start a openocd terminal
    var openocd_bufno = term_start(&shell, {'term_name': 'OPENOCD', 'hidden': 1, 'term_finish': 'close'})
    term_sendkeys(openocd_bufno, g:debug_openocd_command)

    # 2. Start Termdebug and connect the gdb client to openocd (see g:termdebug_config['command'])
    # OBS! Be sure that the local and the remote .elf files are the same!
    echo "Starting debugger for project: " .. fnamemodify(getcwd(), ':t')
    execute $"Termdebug {g:debug_elf_file}"

    # We close "debugged program" because it may not be of interest for
    # embedded.
    if !empty(win_findbuf(bufnr("debugged program")))
        execute ":close " ..  bufwinnr("debugged program")
    endif

    # Create monitor buffer/window below the Termdebug-variables-window
    # wincmd W - may be faster than exe "Var" but less robust
    exe "Var"
    if g:debug_show_monitor == true && !empty(g:debug_monitor_command)
        # TODO check if to run a shell and then a program. NOTE: conda envs
        # may mess up things, this is call a command in term_start rather than
        # a shell
        #
        # var serial_monitor_bufno = term_start(&shell, {"term_name": "serial_monitor"})
        # term_sendkeys(serial_monitor_bufno, "make monitor\n")
        #
        win_execute(win_getid(), 'term_start(g:debug_monitor_command,
                            \ {"term_name": "monitor"})' )

        # wincmd j may be faster...
        win_execute(bufwinid("^monitor$"), $"resize {g:debug_monitor_win_height}")
    endif
    # wincmd j may be faster that exe "Gdb" but less robust
    exe "Gdb"
    win_execute(win_getid(), $"resize {g:debug_gdb_win_height}")
    # wincmd k may be faster than exe "Source" but less robust
    # We start the debugging session from the :Source window.
    exe "Source"

    # Unlist the various buffers opened by termdebug and by this plugin
    setbufvar("debugged program", "&buflisted", 0)
    setbufvar("gdb communication", "&buflisted", 0)
    # Termdebug calls the buffer with the gdb client as the gdb name
    setbufvar(debugger, "&buflisted", 0)
    setbufvar("Termdebug-variables-listing", "&buflisted", 0)

    # Buffers created by this plugin
    setbufvar("OPENOCD", "&buflisted", 0)
    setbufvar("monitor", "&buflisted", 0)
enddef

def ShutoffTermdebug()
    for bufnum in term_list()
        if bufname(bufnum) ==# 'OPENOCD' || bufname(bufnum) ==# 'monitor'
            execute "bw! " .. bufnum
        endif
    endfor
enddef

augroup OpenOCDShutdown
    autocmd!
    autocmd User TermdebugStopPost ShutoffTermdebug()
augroup END


# Mappings
# test
# nnoremap C <cmd>echo "pippo"<cr>

var key_mappings = {}
var keys = ['C', 'B', 'D', 'S', 'O', 'F', 'X', 'I', 'U']

def SetUpTermDebugOverrides()
    # Save possibly existing mappings
    for key in keys
        if !empty(mapcheck(key, "n"))
            key_mappings[key] = maparg(key, 'n')
        endif
    endfor

    nnoremap C <Cmd>Continue<CR><cmd>call TermDebugSendCommand('display')<cr>
    nnoremap B <Cmd>Break<CR><cmd>call TermDebugSendCommand('display')<cr>
    nnoremap D <Cmd>Clear<CR><cmd>call TermDebugSendCommand('display')<cr>
    nnoremap I <Cmd>Step<CR><cmd>call TermDebugSendCommand('display')<cr>
    nnoremap O <Cmd>Over<CR><cmd>call TermDebugSendCommand('display')<cr>
    nnoremap F <Cmd>Finish<CR><cmd>call TermDebugSendCommand('display')<cr>
    nnoremap S <Cmd>Stop<CR><cmd>call TermDebugSendCommand('display')<cr>
    nnoremap U <Cmd>Until<CR><cmd>call TermDebugSendCommand('display')<cr>
    nnoremap T <Cmd>Tbreak<CR><cmd>call TermDebugSendCommand('display')<cr>
    # nnoremap X <cmd>Gdb<cr>exit<cr>
enddef

def TearDownTermDebugOverrides()
    # Restore mappings
    for key in keys
        if has_key(key_mappings, key)
            exe "nnoremap " .. key .. " " .. key_mappings[key]
        else
            exe "nunmap " .. key
        endif
    endfor
enddef

augroup MyTermDebugOverrides
    autocmd!
    autocmd User TermdebugStartPost SetUpTermDebugOverrides()
    autocmd User TermdebugStopPost  TearDownTermDebugOverrides()
augroup END

command! MyDebug vim9cmd MyTermdebug()
