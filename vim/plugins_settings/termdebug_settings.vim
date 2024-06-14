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
var openocd_script = "openocd_stm32f4x_stlink.sh\n"
var openocd_cmd = 'source ../gdb_stuff/' .. openocd_script

var gdbserver_path = "/Applications/SEGGER/JLink_V672c/"
var gdbserver_cmd = "JLinkGDBServer"
var gdbserver_args = ["-select",  "USB",
                      "-device", "EFR32MG24B020F1536IM48",
                      "-endian", "little",
                      "-if",  "SWD",
                      "-speed", "8000",
                      "-noir", "-LocalhostOnly"]

# 2. Debugger settings
g:termdebug_config = {}
#g:termdebug_config['command'] = ["arm-none-eabi-gdb",
#                                 "-ex", "target remote localhost:2331",
#                                 "-ex", "monitor SWO Start 0 875000",
#                                 "-ex", "monitor SWO EnableTarget 0 0 1 0",
#                                 "-ex", "monitor reset"]
g:termdebug_config['command'] = "arm-none-eabi-gdb"
g:termdebug_config['variables_window'] = 1

g:termdebug_config['monitor'] = "telnet localhost 2332"

# Other globals
g:debug_gdb_win_height = 8
g:debug_monitor_win_height = 20

# Run all the machinery
packadd termdebug
def MyTermdebug(gdb_args: string)
    # The .elf name is supposed to be the same as the project name.
    # Before calling this function you must launch a openocd server.
    # This happens inside this script with

    #   source ../openocd_stm32f4x_stlink.sh
    #
    # Then Termdebug is launched.
    # When Termdebug is closed, then the server is automatically shutoff

    var gdbserver = join([gdbserver_path .. gdbserver_cmd] + gdbserver_args)
    echo "GDB server cmd: " .. gdbserver

    # 1. Start GDB server terminal
    var gdbserver_bufno = term_start(gdbserver, {'term_name': 'GDB Server', 'hidden': 1, 'term_finish': 'close'})

    # 2. Start Termdebug and connect the gdb client to openocd (see g:termdebug_config['command'])
    # OBS! Be sure that the local and the remote .elf files are the same!
    echo "Starting debugger for project: " .. fnamemodify(getcwd(), ':t')
    execute $"Termdebug {gdb_args}"

    # We close "debugged program" because it may not be of interest for
    # embedded.
    if !empty(win_findbuf(bufnr("debugged program")))
        execute ":close " ..  bufwinnr("debugged program")
    endif

    # Create monitor buffer/window below the Termdebug-variables-window
    # wincmd W - may be faster than exe "Var" but less robust
    exe "Var"
    if exists("g:termdebug_config") && get(g:termdebug_config, "monitor", "") != ""
        # TODO check if to run a shell and then a program. NOTE: conda envs
        # may mess up things, this is call a command in term_start rather than
        # a shell
        #
        # var serial_monitor_bufno = term_start(&shell, {"term_name": "serial_monitor"})
        # term_sendkeys(serial_monitor_bufno, "make monitor\n")
        #
        var monitorbuf = 'term_start(g:termdebug_config["monitor"], { "term_name": "monitor" })'

        noautocmd win_execute(win_getid(), monitorbuf)

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
    var debugger: string
    if type(g:termdebug_config["command"]) == v:t_list
      debugger = g:termdebug_config["command"][0]
    else
      debugger = fnamemodify(g:termdebug_config["command"], ":t")
    endif

    setbufvar(debugger, "&buflisted", 0)

    setbufvar("Termdebug-variables-listing", "&buflisted", 0)

    # Buffers created by this plugin
    setbufvar("GDB Server", "&buflisted", 0)
    setbufvar("monitor", "&buflisted", 0)
enddef

def ShutoffTermdebug()
    for bufnum in term_list()
        if bufname(bufnum) ==# 'GDB Server' || bufname(bufnum) ==# 'monitor'
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

def ConnectToGDBServer()
    g:TermDebugSendCommand("target remote localhost:2331")
    g:TermDebugSendCommand("monitor SWO Start 0 875000")
    g:TermDebugSendCommand("monitor SWO EnableTarget 0 0 1 0")
    g:TermDebugSendCommand("monitor reset")
enddef

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
    nnoremap X <cmd>call TermDebugSendCommand('set confirm off')<cr><cmd>call TermDebugSendCommand('exit')<cr>
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
    autocmd User TermdebugStartPost ConnectToGDBServer()
    autocmd User TermdebugStopPost  TearDownTermDebugOverrides()
augroup END

command -nargs=* -complete=file -bang Debug vim9cmd MyTermdebug(<q-args>)
