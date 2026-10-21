; extends

; mise file-task headers: //MISE lines as TOML, //USAGE lines as KDL, in every
; spelling mise accepts (//MISE, // MISE, //[MISE], // [MISE]). Same patterns
; as after/queries/ecma/, on rust's `line_comment` node instead of `comment`.
; https://mise.jdx.dev/mise-cookbook/neovim.html

((line_comment) @injection.content
  (#lua-match? @injection.content "^//MISE ")
  (#offset! @injection.content 0 7 0 1)
  (#set! injection.language "toml"))

((line_comment) @injection.content
  (#lua-match? @injection.content "^// MISE ")
  (#offset! @injection.content 0 8 0 1)
  (#set! injection.language "toml"))

((line_comment) @injection.content
  (#lua-match? @injection.content "^//%[MISE%] ")
  (#offset! @injection.content 0 9 0 1)
  (#set! injection.language "toml"))

((line_comment) @injection.content
  (#lua-match? @injection.content "^// %[MISE%] ")
  (#offset! @injection.content 0 10 0 1)
  (#set! injection.language "toml"))

; The end offset reaches one byte past the comment, taking in its newline, so
; consecutive //USAGE lines combine into one KDL document.
((line_comment) @injection.content
  (#lua-match? @injection.content "^//USAGE ")
  (#offset! @injection.content 0 8 0 1)
  (#set! injection.combined)
  (#set! injection.language "kdl"))

((line_comment) @injection.content
  (#lua-match? @injection.content "^// USAGE ")
  (#offset! @injection.content 0 9 0 1)
  (#set! injection.combined)
  (#set! injection.language "kdl"))

((line_comment) @injection.content
  (#lua-match? @injection.content "^//%[USAGE%] ")
  (#offset! @injection.content 0 10 0 1)
  (#set! injection.combined)
  (#set! injection.language "kdl"))

((line_comment) @injection.content
  (#lua-match? @injection.content "^// %[USAGE%] ")
  (#offset! @injection.content 0 11 0 1)
  (#set! injection.combined)
  (#set! injection.language "kdl"))
