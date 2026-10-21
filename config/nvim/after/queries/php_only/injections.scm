; extends

; mise file-task headers: MISE lines as TOML, USAGE lines as KDL, after `#` or
; `//`. php inherits php_only, so this covers .php files. `#[` opens a PHP 8
; attribute rather than a comment, so the #[MISE] and #[USAGE] spellings that
; after/queries/bash/ handles cannot appear here.
; https://mise.jdx.dev/mise-cookbook/neovim.html

((comment) @injection.content
  (#lua-match? @injection.content "^#MISE ")
  (#offset! @injection.content 0 6 0 1)
  (#set! injection.language "toml"))

((comment) @injection.content
  (#lua-match? @injection.content "^# MISE ")
  (#offset! @injection.content 0 7 0 1)
  (#set! injection.language "toml"))

((comment) @injection.content
  (#lua-match? @injection.content "^# %[MISE%] ")
  (#offset! @injection.content 0 9 0 1)
  (#set! injection.language "toml"))

((comment) @injection.content
  (#lua-match? @injection.content "^//MISE ")
  (#offset! @injection.content 0 7 0 1)
  (#set! injection.language "toml"))

((comment) @injection.content
  (#lua-match? @injection.content "^// MISE ")
  (#offset! @injection.content 0 8 0 1)
  (#set! injection.language "toml"))

((comment) @injection.content
  (#lua-match? @injection.content "^//%[MISE%] ")
  (#offset! @injection.content 0 9 0 1)
  (#set! injection.language "toml"))

((comment) @injection.content
  (#lua-match? @injection.content "^// %[MISE%] ")
  (#offset! @injection.content 0 10 0 1)
  (#set! injection.language "toml"))

; The end offset reaches one byte past the comment, taking in its newline, so
; consecutive USAGE lines combine into one KDL document.
((comment) @injection.content
  (#lua-match? @injection.content "^#USAGE ")
  (#offset! @injection.content 0 7 0 1)
  (#set! injection.combined)
  (#set! injection.language "kdl"))

((comment) @injection.content
  (#lua-match? @injection.content "^# USAGE ")
  (#offset! @injection.content 0 8 0 1)
  (#set! injection.combined)
  (#set! injection.language "kdl"))

((comment) @injection.content
  (#lua-match? @injection.content "^# %[USAGE%] ")
  (#offset! @injection.content 0 10 0 1)
  (#set! injection.combined)
  (#set! injection.language "kdl"))

((comment) @injection.content
  (#lua-match? @injection.content "^//USAGE ")
  (#offset! @injection.content 0 8 0 1)
  (#set! injection.combined)
  (#set! injection.language "kdl"))

((comment) @injection.content
  (#lua-match? @injection.content "^// USAGE ")
  (#offset! @injection.content 0 9 0 1)
  (#set! injection.combined)
  (#set! injection.language "kdl"))

((comment) @injection.content
  (#lua-match? @injection.content "^//%[USAGE%] ")
  (#offset! @injection.content 0 10 0 1)
  (#set! injection.combined)
  (#set! injection.language "kdl"))

((comment) @injection.content
  (#lua-match? @injection.content "^// %[USAGE%] ")
  (#offset! @injection.content 0 11 0 1)
  (#set! injection.combined)
  (#set! injection.language "kdl"))
