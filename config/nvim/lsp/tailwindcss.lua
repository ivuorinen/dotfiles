-- Narrower filetypes than nvim-lspconfig defaults (which include 30+ types
-- such as markdown, svelte, vue). Only activate where Tailwind is practical.
-- Root markers scope it further to actual Tailwind projects.
return {
  filetypes = {
    'html',
    'css',
    'javascript',
    'javascriptreact',
    'typescript',
    'typescriptreact',
  },
  root_markers = {
    'tailwind.config.cjs',
    'tailwind.config.js',
    'tailwind.config.mjs',
    'tailwind.config.ts',
    'postcss.config.cjs',
    'postcss.config.js',
    'postcss.config.mjs',
    'postcss.config.ts',
  },
}
