return {
  -- A better annotation generator. Supports multiple languages and annotation conventions.
  -- https://github.com/danymat/neogen
  {
    "danymat/neogen",
    dependencies = "nvim-treesitter/nvim-treesitter",
    version = "*",
    cmd = "Neogen",
    opts = {
      snippet_engine = "luasnip",
      languages = {
        lua = { template = { annotation_convention = "ldoc" } },
        typescript = { template = { annotation_convention = "tsdoc" } },
        typescriptreact = { template = { annotation_convention = "tsdoc" } },
      },
    },
    keys = {
      {
        "<leader>baa",
        function()
          require("neogen").generate({ type = "current" })
        end,
        desc = "Current",
      },
      {
        "<leader>bac",
        function()
          require("neogen").generate({ type = "class" })
        end,
        desc = "Class",
      },
      {
        "<leader>baf",
        function()
          require("neogen").generate({ type = "func" })
        end,
        desc = "Function",
      },
      {
        "<leader>bat",
        function()
          require("neogen").generate({ type = "type" })
        end,
        desc = "Type",
      },
      {
        "<leader>baF",
        function()
          require("neogen").generate({ type = "file" })
        end,
        desc = "File",
      },
    },
  },
  -- Describe the regexp under the cursor
  -- https://github.com/bennypowers/nvim-regexplainer
  {
    "bennypowers/nvim-regexplainer",
    dependencies = {
      "nvim-treesitter/nvim-treesitter",
      "MunifTanjim/nui.nvim",
    },
    opts = {
      -- automatically show the explainer when the cursor enters a regexp
      auto = true,
    },
  },
  -- Clarify and beautify your comments using boxes and lines.
  -- https://github.com/LudoPinelli/comment-box.nvim
  { "LudoPinelli/comment-box.nvim", opts = {} },
  {
    "williamboman/mason.nvim",
    opts = {
      ensure_installed = {
        "actionlint",
        "ansible-language-server",
        "ansible-lint",
        "bash-language-server",
        "blade-formatter",
        "cfn-lint",
        "codeql",
        "codespell",
        "commitlint",
        "diagnostic-languageserver",
        "docker-compose-language-service",
        "dockerfile-language-server",
        "editorconfig-checker",
        "fixjson",
        "html-lsp",
        "jq",
        "nginx-language-server",
        "php-cs-fixer",
        "semgrep",
        "sonarlint-language-server",
        "stylua",
        "shellcheck",
        "shfmt",
        "flake8",
      },
    },
  },
  -- Tabnine Client for Neovim
  -- https://github.com/codota/tabnine-nvim
  {
    "codota/tabnine-nvim",
    name = "tabnine",
    -- enabled = false,
    build = vim.loop.os_uname().sysname == "Windows_NT" and "pwsh.exe -file .\\dl_binaries.ps1" or "./dl_binaries.sh",
    cmd = { "TabnineStatus", "TabnineDisable", "TabnineEnable", "TabnineToggle" },
    event = "User",
    opts = {
      accept_keymap = "<C-e>",
      dismiss_keymap = "<C-Esc>",
    },
  },
  -- Vim plugin for automatic time tracking and metrics generated from your programming activity.
  -- https://github.com/wakatime/vim-wakatime
  { "wakatime/vim-wakatime", lazy = false, enabled = true },
}
