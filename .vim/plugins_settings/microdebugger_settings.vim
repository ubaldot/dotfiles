vim9script

g:termdebug_config = {}

if g:is_avap
  g:termdebug_config['timeout'] = 800 # 800 * 10ms = 8 seconds.
  g:termdebug_config['command'] = ['gdb', '-ex', 'shell sleep 5', '-ex', 'target extended-remote localhost:1234',
    '-ex', 'set substitute-path /app /home/yt75534/avap_vcm_hardware_info']

  g:microdebugger_server_command = ['./avap-util/scripts/run_gdbserver_docker.sh']

  g:microdebugger_aux_windows = ['server',  'variables']
  g:microdebugger_gdb_win_height = 8
  g:microdebugger_mappings = { C: '<Cmd>Continue<CR><cmd>call TermDebugSendCommand("display")<cr>',
    B: '<Cmd>Break<CR><cmd>call TermDebugSendCommand("display")<cr>',
    D: '<Cmd>Clear<CR><cmd>call TermDebugSendCommand("display")<cr>',
    I: '<Cmd>Step<CR><cmd>call TermDebugSendCommand("display")<cr>',
    O: '<Cmd>Over<CR><cmd>call TermDebugSendCommand("display")<cr>',
    F: '<Cmd>Finish<CR><cmd>call TermDebugSendCommand("display")<cr>',
    S: '<Cmd>Stop<CR><cmd>call TermDebugSendCommand("display")<cr>',
    U: '<Cmd>Until<CR><cmd>call TermDebugSendCommand("display")<cr>',
    T: '<Cmd>Tbreak<CR><cmd>call TermDebugSendCommand("display")<cr>'}
else
  # g:termdebug_config['command'] = ['arm-none-eabi-gdb', '-ex', 'target extended-remote localhost:3333', '-ex', 'monitor reset']
  var debugger = "arm-none-eabi-gdb"
  var elf_file = $"build/{fnamemodify(getcwd(), ':t')}.elf"
  var debugger_args = ["-x", "../gdb_stuff/gdb_init_commands.txt", "-ex", $"file {elf_file}"]
  g:termdebug_config['command'] = insert(debugger_args, debugger, 0)

  if g:os == 'Windows'
    g:microdebugger_openocd_command = ['cmd.exe', '/c', '..\\gdb_stuff\\openocd_stm32f4x_stlink.bat']
    g:microdebugger_windows_CtrlC_program = 'SendSignalCtrlC'
  else
    g:microdebugger_openocd_command = ['../gdb_stuff/openocd_stm32f4x_stlink.sh']
  endif

  g:microdebugger_aux_windows = ['openocd', 'variables', 'monitor']
  g:microdebugger_monitor_command = ['make', 'monitor']
  g:microdebugger_gdb_win_height = 8
  g:microdebugger_mappings = { C: '<Cmd>Continue<CR><cmd>call TermDebugSendCommand("display")<cr>',
    B: '<Cmd>Break<CR><cmd>call TermDebugSendCommand("display")<cr>',
    D: '<Cmd>Clear<CR><cmd>call TermDebugSendCommand("display")<cr>',
    I: '<Cmd>Step<CR><cmd>call TermDebugSendCommand("display")<cr>',
    O: '<Cmd>Over<CR><cmd>call TermDebugSendCommand("display")<cr>',
    F: '<Cmd>Finish<CR><cmd>call TermDebugSendCommand("display")<cr>',
    S: '<Cmd>Stop<CR><cmd>call TermDebugSendCommand("display")<cr>',
    U: '<Cmd>Until<CR><cmd>call TermDebugSendCommand("display")<cr>',
    T: '<Cmd>Tbreak<CR><cmd>call TermDebugSendCommand("display")<cr>'}
endif
