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
    'tailwind.config.js',
    'tailwind.config.ts',
    'tailwind.config.mjs',
    'postcss.config.js',
    'postcss.config.ts',
  },
}
