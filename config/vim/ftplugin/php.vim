" php
" Phpactor plugin
" Include use statement
nmap <Leader>u :call phpactor#UseAdd()<CR>
" Invoke the context menu
nmap <Leader>mm :call phpactor#ContextMenu()<CR>
" Invoke the navigation menu
nmap <Leader>nn :call phpactor#Navigate()<CR>
" Goto definition of class or class member under the cursor
nmap <Leader>oo :call phpactor#GotoDefinition()<CR>
nmap <Leader>oh :call phpactor#GotoDefinition('hsplit')<CR>
nmap <Leader>ov :call phpactor#GotoDefinition('vsplit')<CR>
nmap <Leader>ot :call phpactor#GotoDefinition('tabnew')<CR>
" Show brief information about the symbol under the cursor
nmap <Leader>K :call phpactor#Hover()<CR>
" Transform the classes in the current file
nmap <Leader>tt :call phpactor#Transform()<CR>
" Generate a new class (replacing the current file)
nmap <Leader>cc :call phpactor#ClassNew()<CR>
" Extract expression (normal mode)
nmap <silent><Leader>ee :call phpactor#ExtractExpression(v:false)<CR>
" Extract expression from selection
vmap <silent><Leader>ee :<C-U>call phpactor#ExtractExpression(v:true)<CR>
" Extract method from selection
vmap <silent><Leader>em :<C-U>call phpactor#ExtractMethod()<CR>

au FileType php,blade let b:coc_root_patterns = [
  \ '.git', '.env', 'composer.json', 'artisan'
  \]
au FileType php,blade nmap <silent> ga <Plug>(coc-codeaction-line)
au FileType php,blade nmap <silent> <leader>ac <Plug>(coc-codeaction-cursor)
au FileType php,blade nmap <silent> gd <Plug>(coc-definition)
au FileType php,blade nmap <silent> gy <Plug>(coc-type-definition)
au FileType php,blade nmap <silent> gi <Plug>(coc-implementation)
au FileType php,blade nmap <silent> gr <Plug>(coc-references)
au FileType php,blade nmap <silent> K <Plug>(coc-hover)
au FileType php,blade nmap <silent> <leader>rn <Plug>(coc-rename)
au FileType php,blade nmap <silent> <leader>f <Plug>(coc-format)
au FileType php,blade nmap <silent> <leader>qf <Plug>(coc-fix-current)
au FileType php,blade nmap <silent> <leader>qo <Plug>(coc-fix-all)
au FileType php,blade nmap <silent> <leader>do <Plug>(coc-diagnostic-prev)
au FileType php,blade nmap <silent> <leader>dn <Plug>(coc-diagnostic-next)
au FileType php,blade nmap <silent> <leader>ca <Plug>(coc-cursoraction)
au FileType php,blade nmap <silent> <leader>so <Plug>(coc-symbols)
au FileType php,blade nmap <silent> <leader>cs <Plug>(coc-list-symbols)
