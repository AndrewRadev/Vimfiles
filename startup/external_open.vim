command! -bar -nargs=1 -complete=file OpenURL call OpenURL(<f-args>)
command! -bar -nargs=1 -complete=file Open    call OpenURL(<f-args>)

" TODO Visual mode
nmap gu :Open <cfile><cr>

function! OpenURL(url)
  let url = shellescape(a:url)

  if has('mac')
    silent call system('open '.url)
    echo "Opening " . url
  else
    echoerr "Don't know how to open an url on this system"
  end
endfunction
