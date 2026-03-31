return {
  cmd = { 'tailwindcss-language-server', '--stdio' },
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
