return {
  {
    "nvim-dap",
    dir = plugin_path("nvim-dap"),
    name = "nvim-dap",
    dependencies = {
      {
        "nvim-dap-ui",
        dir = plugin_path("nvim-dap-ui"),
        name = "nvim-dap-ui",
      },
      {
        "nvim-nio",
        dir = plugin_path("nvim-nio"),
        name = "nvim-nio",
      },
    },
    keys = {
      { "<leader>dc", function() require("dap").continue() end, desc = "DAP Continue" },
      { "<leader>do", function() require("dap").step_over() end, desc = "DAP Step Over" },
      { "<leader>di", function() require("dap").step_into() end, desc = "DAP Step Into" },
      { "<leader>dO", function() require("dap").step_out() end, desc = "DAP Step Out" },
      { "<leader>db", function() require("dap").toggle_breakpoint() end, desc = "Toggle Breakpoint" },
      { "<leader>dB", function()
          require("dap").set_breakpoint(vim.fn.input("Breakpoint condition: "))
        end, desc = "Conditional Breakpoint" },
      { "<leader>dr", function() require("dap").repl.open() end, desc = "DAP REPL" },
      { "<leader>du", function() require("dapui").toggle() end, desc = "Toggle DAP UI" },
    },
    config = function()
      local dap = require("dap")
      local dapui = require("dapui")

      dapui.setup({})

      -- Знаки для точек останова
      vim.fn.sign_define("DapBreakpoint", { text = "●", texthl = "DiagnosticError" })
      vim.fn.sign_define("DapStopped", { text = "▶", texthl = "DiagnosticWarn" })

      -- === Python: debugpy ===
      dap.adapters.python = {
        type = "executable",
        command = "python3",
        args = { "-m", "debugpy.adapter" },
      }

      dap.configurations.python = {
        {
          type = "python",
          request = "launch",
          name = "Launch file",
          program = "${file}",
          pythonPath = function()
            return "python3"
          end,
          console = "integratedTerminal",
        },
      }

      -- === C / C++: CodeLLDB ===
      dap.adapters.codelldb = {
        type = "server",
        port = 13000,
        executable = {
          command = "codelldb",
          args = { "--port", "13000" },
        },
      }

      dap.configurations.c = {
        {
          name = "Launch executable (CodeLLDB)",
          type = "codelldb",
          request = "launch",
          program = function()
            local path = vim.fn.input({
              prompt = "Path to executable: ",
              default = vim.fn.getcwd() .. "/",
              completion = "file",
            })
            return (path and path ~= "") and path or dap.ABORT
          end,
          cwd = "${workspaceFolder}",
          stopOnEntry = false,
        },
        {
          name = "Attach to process (CodeLLDB)",
          type = "codelldb",
          request = "attach",
          pid = require("dap.utils").pick_process,
        },
      }

      dap.configurations.cpp = dap.configurations.c
    end,
  },
}
