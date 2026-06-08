return {
  cmd_env = {
    -- 4006 = duplicateFunctionDefinitionInSameScope; false-positive on
    -- functions redefined in mutually exclusive if/else branches.
    fish_lsp_diagnostic_disable_error_codes = '4006',
  },
}
