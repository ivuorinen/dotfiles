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
        enable = true, -- hints are off by default; enable globally
        paramType = true, -- show type hint on assignment rhs (default false)
      },
    },
  },
}
