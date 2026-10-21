; extends

; mise file-task headers: #MISE lines as TOML, #USAGE lines as KDL, in every
; spelling mise accepts (#MISE, # MISE, #[MISE], # [MISE]). The same file
; serves each `#`-comment language under after/queries/; keep the copies equal.
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
  (#lua-match? @injection.content "^#%[MISE%] ")
  (#offset! @injection.content 0 8 0 1)
  (#set! injection.language "toml"))

((comment) @injection.content
  (#lua-match? @injection.content "^# %[MISE%] ")
  (#offset! @injection.content 0 9 0 1)
  (#set! injection.language "toml"))

; The end offset reaches one byte past the comment, taking in its newline, so
; consecutive #USAGE lines combine into one KDL document.
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
  (#lua-match? @injection.content "^#%[USAGE%] ")
  (#offset! @injection.content 0 9 0 1)
  (#set! injection.combined)
  (#set! injection.language "kdl"))

((comment) @injection.content
  (#lua-match? @injection.content "^# %[USAGE%] ")
  (#offset! @injection.content 0 10 0 1)
  (#set! injection.combined)
  (#set! injection.language "kdl"))
