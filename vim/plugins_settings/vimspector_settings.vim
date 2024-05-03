vim9script

# vimspector TODO
# "$schema": "https://puremourning.github.io/vimspector/schema/vimspector.schema.json",
g:vimspector_enable_mappings = 'HUMAN'
g:vimspector_base_dir = g:dotvim .. "/plugins/vimspector"
g:vimspector_adapters = {
    "run_with_debugpy": {
      "extends": "debugpy",
      "variables": {
        "Host": "localhost",
        "Port": "5678"
      },
      "command": [
        "python -m debugpy --wait-for-client --listen ${Host}:${Port} ${file}"
      ],
      "port": "${Port}"
    },

    "python-remote": {
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
            "-m",
            "debugpy",
            "--listen",
            "${Host}:${Port}",
            "--wait-for-client",
            "%CMD%"
          ]
        }
      }
    }
  }

g:vimspector_configurations = {
    "Remote: attach (experimental)": {
      "adapter": "run_with_debugpy",
      "filetypes": ["python"],
      "configuration": {
        "request": "attach",
        "program": "${file}",
        "stopOnEntry": true,
        "console": "integratedTerminal",
        "args": [""]
      }
    },

    "Remote: launch (experimental)": {
      "adapter": "python-remote",
      "filetypes": ["python"],
      "remote-request": "launch",
      "remote-cmdLine": [
        "${file}"
      ],
      "configuration": {
        "request": "launch",
        "program": "${file}",
        "stopOnEntry": true,
        "console": "integratedTerminal",
        "args": ["*${args}"]
      }
    },

    "run current script (use this!)": {
      "adapter": "debugpy",
      "configuration": {
        "request": "launch",
        "type": "python",
        "cwd": "${fileDirname}",
        "program": "${file}",
        "stopOnEntry": true,
        "console": "integratedTerminal"
      }
    },
    "platformio_configuration": {
      "adapter": "vscode-cpptools",
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
      "configuration": {
        "request": "launch",
        "program": "${workspaceRoot}/build/zephyr/zephyr.elf",
        "MImode": "gdb",
        "MIDebuggerPath": "~/zephyr-sdk-0.16.0/arm-zephyr-eabi/bin/arm-zephyr-eabi-gdb",
        "miDebuggerServerAddress": "127.0.0.1:3333"
      }
    }
  }
