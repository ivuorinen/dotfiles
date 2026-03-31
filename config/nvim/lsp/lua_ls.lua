return {
  cmd = { 'lua-language-server' },
  filetypes = { 'lua' },
  root_markers = {
    '.luarc.json',
    '.luarc.jsonc',
    '.stylua.toml',
    'stylua.toml',
    '.git',
  },
  settings = {
    Lua = {
      runtime = { version = 'LuaJIT' },
      diagnostics = {
        globals = { 'vim' },
        disable = { 'missing-fields' },
      },
      completion = { callSnippet = 'Replace' },
      workspace = {
        checkThirdParty = false,
        library = { vim.env.VIMRUNTIME },
      },
      hint = {
        enable = true,
        arrayIndex = 'Auto',
        await = true,
        paramName = 'All',
        paramType = true,
        semicolon = 'SameLine',
        setType = false,
      },
    },
  },
}
