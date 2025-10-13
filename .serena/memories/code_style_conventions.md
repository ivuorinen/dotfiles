# Code Style and Conventions

## EditorConfig Rules (.editorconfig)

- **Charset**: UTF-8
- **Line endings**: LF
- **Indent style**: Spaces (except for specific files)
- **Indent size**: 2 spaces (default)
- **Final newline**: Required
- **Trailing whitespace**: Trimmed

### Language-specific Rules

- **Fish scripts**: 4-space indent, 80 char line limit
- **PHP files**: 4-space indent
- **Markdown**: 120 char line limit
- **Lua**: 90 char line limit
- **Git files**: Tab indentation
- **Shell scripts**: 2-space indent with specific shfmt settings

## Prettier Configuration

- Extends `@ivuorinen/prettier-config`
- **Trailing commas**: Always
- **Markdown**: 120 char width, preserve prose wrapping

## ESLint Configuration

- Extends `@ivuorinen` base configuration
- Applied to JavaScript/TypeScript files

## Shell Script Standards (.shellcheckrc)

- External sources following enabled
- Disabled checks: SC2039, SC2166, SC2154, SC1091, SC2174, SC2016
- Must include shebang or `# shellcheck shell=bash`

## Formatting Tools

- **Shell scripts**: shfmt with specific rules
- **Markdown**: markdownlint + prettier
- **JavaScript/TypeScript**: prettier + eslint
- **YAML**: yamllint

## Naming Conventions

- **Shell functions**: Use `x-` prefix for cross-shell compatibility
- **Environment variables**: UPPERCASE with underscores
- **File names**: lowercase with hyphens for scripts
- **Directory structure**: lowercase, organized by tool/purpose
