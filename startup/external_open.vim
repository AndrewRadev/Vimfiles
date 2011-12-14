command! -bar -nargs=1 -complete=file OpenURL call OpenURL(<f-args>)
command! -bar -nargs=1 -complete=file Open    call OpenURL(<f-args>)

" TODO Visual mode
nmap gu :Open <cfile><cr>

function! OpenURL(url)
  let url = shellescape(a:url)

  if has('mac')
    silent call system('open '.url)
  elseif has('unix')
    if executable('xdg-open')
      silent call system('xdg-open '.url.' 2>&1 > /dev/null &')
    else
      echoerr "You need to install xdg-open to be able to open urls"
      return
    end
  else
    echoerr "Don't know how to open a URL on this system"
    return
  end

  echo "Opening ".url
endfunction
