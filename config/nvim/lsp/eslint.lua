-- Extended root_markers: nvim-lspconfig defaults omit several eslint
-- config variants (.eslintrc, config.mjs, config.ts).
return {
  root_markers = {
    '.eslintrc',
    '.eslintrc.js',
    '.eslintrc.json',
    '.eslintrc.yml',
    'eslint.config.js',
    'eslint.config.mjs',
    'eslint.config.ts',
    'package.json',
  },
}
