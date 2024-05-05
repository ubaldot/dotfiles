vim9script

#
# args key inside configuration is args to pass to program ${file}
#
# Remote-cmdline in the configuration is the value of %CMD% in the adapter
#
g:vimspector_enable_mappings = 'HUMAN'
g:vimspector_base_dir = g:dotvim .. "/plugins/vimspector"

var python_path = system("where python")
g:vimspector_adapters = {
    "dymoval_adapter": {
      "extends": "debugpy",
      "variables": {
        "Host": "localhost",
        "Port": "5678"
      },

      "command": [ "${workspaceRoot}/pippo.sh" ],
      # "command": [
      #       "python",
      #       "-Xfrozen_modules=off",
      #       "-m",
      #       "debugpy",
      #       "--listen",
      #       "${Host}:${Port}",
      #       "--wait-for-client",
      # ],
      "port": "${Port}",
    },

    # OK!
    "python-remote-launch": {
      "variables": {
        "Host": "localhost",
        "Port": "5678"
      },
      "port": "${Port}",
      "host": "${Host}",
      "launch": {
        "remote": {
          "runCommand": [
            "python",
            "-Xfrozen_modules=off",
            "-m",
            "debugpy",
            "--listen",
            "${Host}:${Port}",
            "--wait-for-client",
            "%CMD%"
          ]
        }
      },
      # "delay": "1000m",
    }
  }

g:vimspector_configurations = {
    "Dymoval (NOK)": {
      "adapter": "dymoval_adapter",
      "filetypes": ["python"],
      "configuration": {
       # If "request" is "launch" then the file to be debugged is specified in
       # "program"
        "request": "attach",
        "program": "${file}",
        "python": [python_path],
        "stopOnEntry": true,
        "console": "integratedTerminal",
        # args is what to pass to "program" along with ${file}.
        # "args": ["-Xfrozen_modules=off"]
        "autoReload": {
        "enable": true
        },
      },
      # "delay": "1000m",
    },

    "Remote: launch and attach (OK)": {
      "adapter": "python-remote-launch",
      "filetypes": ["python"],
      # Instead of manually run a process and fetch the PID, you directly
      # lunch the process in the remote and connect to it.
      "remote-request": "launch",
      # This replaces %CMD% in the adapter.
      "remote-cmdLine": [
        "${file}"
      ],
      "configuration": {
        # You attach to the process launched in the remote.
        "request": "attach",
        "program": "${file}",
        "python": [python_path],
        "stopOnEntry": true,
        "console": "integratedTerminal",
        "justMyCode": false,
        "autoReload": {
        "enable": true
        },
      }
    },

    "Python run generic script (venv problems)": {
    # Launch current file with debugpy
    # Does not work with dymoval
      "adapter": "debugpy",
      "filetypes": ["python"],
      "configuration": {
      # If you use "attach" you must specify a processID if you run everything
      # locally OR you should use remote-request: launch
        "request": "launch",
        "program": "${file}",
        # "python": [python_path],
        # "type": "python",
        "cwd": "${fileDirname}",
        "stopOnEntry": true,
        "console": "integratedTerminal",
        "autoReload": {
        "enable": true
        },
      }
    },

    "platformio_configuration": {
      "adapter": "vscode-cpptools",
      "filetypes": ["c", "cpp"],
      "configuration": {
        "request": "launch",
        "cwd": "${workspaceRoot}",
        "program": "${workspaceRoot}/.pio/build/nucleo_h743zi/firmware.elf",
        "MIMode": "gdb",
        "miDebuggerPath": "piodebuggdb",
        "miDebuggerArgs": "--project-dir ${workspaceRoot} -x .pioinit"
      }
    },
    "OpenOCD": {
      "adapter": "vscode-cpptools",
      "filetypes": ["c", "cpp"],
      "configuration": {
        "request": "launch",
        "program": "${workspaceRoot}/build/zephyr/zephyr.elf",
        "MImode": "gdb",
        "MIDebuggerPath": "~/zephyr-sdk-0.16.0/arm-zephyr-eabi/bin/arm-zephyr-eabi-gdb",
        "miDebuggerServerAddress": "127.0.0.1:3333"
      }
    }
  }
