-- Expose the Neovim runtime API and enable all inlay hints.
return {
  settings = {
    Lua = {
      runtime = { version = 'LuaJIT' },
      diagnostics = {
        -- globals list is authoritative in .luarc.json
        disable = { 'missing-fields' },
      },
      completion = { callSnippet = 'Replace' }, -- show full call snippet, not just name
      workspace = {
        checkThirdParty = false, -- suppress "Do you want to configure this?" prompts
        library = { vim.env.VIMRUNTIME },
      },
      hint = {
        enable = true,
        arrayIndex = 'Auto',
        await = true,
        paramName = 'All',
        paramType = true,
        semicolon = 'SameLine', -- show ; hint on same line as single-expr returns
        setType = false, -- type on assignment is visible from the rhs; skip the hint
      },
    },
  },
}
