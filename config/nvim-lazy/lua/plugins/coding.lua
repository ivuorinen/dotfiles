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
        "<leader>ba",
        desc = "Annotations / Comments",
      },
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
  {
    "laytan/tailwind-sorter.nvim",
    dependencies = { "nvim-treesitter/nvim-treesitter", "nvim-lua/plenary.nvim" },
    build = "cd formatter && npm i && npm run build",
    config = true,
    opts = {
      on_save_enabled = true,
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
  -- Mason
  -- https://github.com/williamboman/mason.nvim
  {
    "williamboman/mason.nvim",
    opts = function(_, opts)
      vim.list_extend(opts.ensure_installed, {
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
        "flake8",
        "html-lsp",
        "jq",
        "jsonlint",
        "luacheck",
        "nginx-language-server",
        "php-cs-fixer",
        "phpcs",
        "phpmd",
        "semgrep",
        "shellcheck",
        "shfmt",
        "sonarlint-language-server",
        "stylelint",
        "stylua",
        "yamllint",
      })
    end,
  },
  -- Vim plugin for automatic time tracking and metrics generated from your programming activity.
  -- https://github.com/wakatime/vim-wakatime
  { "wakatime/vim-wakatime", lazy = false, enabled = true },
}
