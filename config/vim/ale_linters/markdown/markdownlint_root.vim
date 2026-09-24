" markdownlint-cli, run from the project root.
"
" markdownlint matches .markdownlintignore patterns against paths relative
" to its working directory. ALE's bundled markdownlint_cli linter sets no
" cwd, so it runs wherever vim's current directory happens to be: after
" NERDTree re-roots (g:NERDTreeChDirMode = 2), after <leader>. (:lcd), or
" when vim starts in a subdirectory, ignored files get linted anyway, and
" --ignore-path cannot help because the patterns still resolve against the
" cwd. This linter runs from the directory that holds the nearest
" .markdownlintignore, the same place `yarn lint:markdownlint` runs from,
" which also makes markdownlint pick up that project's .markdownlint.json.
" Without an ignore file it falls back to ALE's default cwd.
"
" The vimrc lists markdownlint_cli in g:ale_linters_ignore so the bundled
" linter does not run alongside this one, and markdownlint_cli2 because
" markdownlint-cli2 takes its ignores from its own config, not this file.

function! ale_linters#markdown#markdownlint_root#GetCwd(buffer) abort
  let l:ignore = ale#path#FindNearestFile(a:buffer, '.markdownlintignore')

  return empty(l:ignore) ? v:null : fnamemodify(l:ignore, ':h')
endfunction

call ale#linter#Define('markdown', {
\   'name': 'markdownlint_root',
\   'executable': {buffer -> ale#handlers#markdownlint#GetExecutable(buffer, 'markdownlint')},
\   'cwd': function('ale_linters#markdown#markdownlint_root#GetCwd'),
\   'lint_file': 1,
\   'output_stream': 'both',
\   'command': {buffer -> ale#handlers#markdownlint#GetCommand(buffer, 'markdownlint')},
\   'callback': 'ale#handlers#markdownlint#Handle',
\})
