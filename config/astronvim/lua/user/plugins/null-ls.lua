return {
  "jose-elias-alvarez/null-ls.nvim",
  opts = function(_, config)
    -- config variable is the default configuration table for the setup function call
    local null_ls = require "null-ls"

    -- Check supported formatters and linters
    -- https://github.com/jose-elias-alvarez/null-ls.nvim/tree/main/lua/null-ls/builtins/formatting
    -- https://github.com/jose-elias-alvarez/null-ls.nvim/tree/main/lua/null-ls/builtins/diagnostics
    config.sources = {
      -- Set a formatter
      null_ls.builtins.code_actions.eslint,
      null_ls.builtins.code_actions.refactoring,
      null_ls.builtins.code_actions.shellcheck,
      null_ls.builtins.code_actions.xo,
      null_ls.builtins.diagnostics.actionlint,
      null_ls.builtins.diagnostics.alex,
      null_ls.builtins.diagnostics.ansiblelint,
      null_ls.builtins.diagnostics.dotenv_linter,
      null_ls.builtins.diagnostics.editorconfig_checker,
      null_ls.builtins.diagnostics.eslint,
      null_ls.builtins.diagnostics.jsonlint,
      null_ls.builtins.diagnostics.luacheck,
      null_ls.builtins.diagnostics.markdownlint,
      null_ls.builtins.diagnostics.mypy,
      null_ls.builtins.diagnostics.php,
      null_ls.builtins.diagnostics.phpcs,
      null_ls.builtins.diagnostics.phpstan,
      null_ls.builtins.diagnostics.psalm,
      null_ls.builtins.diagnostics.pydocstyle,
      null_ls.builtins.diagnostics.semgrep,
      null_ls.builtins.diagnostics.shellcheck,
      null_ls.builtins.diagnostics.standardjs,
      null_ls.builtins.diagnostics.stylelint,
      null_ls.builtins.diagnostics.tfsec,
      null_ls.builtins.diagnostics.trail_space,
      null_ls.builtins.diagnostics.tsc,
      null_ls.builtins.diagnostics.vacuum,
      null_ls.builtins.diagnostics.vint,
      null_ls.builtins.diagnostics.vulture,
      null_ls.builtins.diagnostics.xo,
      null_ls.builtins.diagnostics.yamllint,
      null_ls.builtins.diagnostics.zsh,
      null_ls.builtins.formatting.black,
      null_ls.builtins.formatting.blade_formatter,
      null_ls.builtins.formatting.cbfmt,
      null_ls.builtins.formatting.clang_format,
      null_ls.builtins.formatting.eslint,
      null_ls.builtins.formatting.fixjson,
      null_ls.builtins.formatting.isort,
      null_ls.builtins.formatting.jq,
      null_ls.builtins.formatting.markdownlint,
      null_ls.builtins.formatting.nginx_beautifier,
      null_ls.builtins.formatting.pg_format,
      null_ls.builtins.formatting.phpcsfixer,
      null_ls.builtins.formatting.prettier_eslint,
      null_ls.builtins.formatting.prettier,
      null_ls.builtins.formatting.puppet_lint,
      null_ls.builtins.formatting.rome,
      null_ls.builtins.formatting.rustfmt,
      null_ls.builtins.formatting.shfmt.with {
        args = { "-i", "1", "-bn", "-ci", "-sr", "-kb", "-fn" },
      },
      null_ls.builtins.formatting.stylelint,
    }
    return config -- return final config table
  end,
}
