function! ChangeColorScheme(channel, msg)
  let time = trim(a:msg)
  if time ==# "Dark"
    set background="dark"
  else
    set background="light"
  endif
endfunction

function! CheckStatus(timer)
  if executable("defaults")
    let job = job_start(
          \ ["defaults", "read", "-g", "AppleInterfaceStyle"],
          \ {"out_cb": "ChangeColorScheme"}
          \ )
  else
    set background="dark"
  endif
endfunction

function! AutoDarkModeSetup()
  let timer = timer_start(3000, 'CheckStatus', {'repeat': -1})
  call CheckStatus(timer) " Initial call to setup the theme
endfunction

call AutoDarkModeSetup()
