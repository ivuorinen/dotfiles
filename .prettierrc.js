module.exports = {
  ...require('@ivuorinen/prettier-config'),
  trailingComma: 'all',
  // Add custom options below:
  overrides: [
    {
      files: '*.md',
      options: {
        printWidth: 120,
        proseWrap: 'preserve',
        tabWidth: 2,
      },
    },
  ],
}
