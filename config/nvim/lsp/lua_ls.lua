-- Expose the Neovim runtime API and enable all inlay hints.
return {
  settings = {
    Lua = {
      runtime = { version = 'LuaJIT' },
      diagnostics = {
        -- globals list is authoritative in .luarc.json
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
