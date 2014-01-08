let s:search_urls = {
      \ 'ruby':   'http://apidock.com/ruby/search/quick?query=%s',
      \ 'rails':  'http://apidock.com/rails/search/quick?query=%s',
      \ 'rspec':  'http://apidock.com/rspec/search/quick?query=%s',
      \ 'jquery': 'http://api.jquery.com/?s=%s',
      \ 'so':     'http://stackoverflow.com/search?q=%s',
      \ 'css':    'https://developer.mozilla.org/en-US/search?q=%s',
      \ 'js':     'https://developer.mozilla.org/en-US/search?q=%s'
      \ }

command! -count=0 -nargs=+ -complete=custom,s:CompleteDoc  Doc call s:Doc(<count>, <f-args>)
function! s:Doc(count, type, ...)
  if a:0 > 0
    let query = join(a:000, ' ')
  elseif a:count > 0
    let query = lib#GetMotion('gv')
  else
    let query = expand('<cword>')
  endif

  let search_url = s:SearchUrl(a:type)
  let search_url = printf(search_url, lib#UrlDecode(query))

  call Open(search_url)
endfunction

function! s:CompleteDoc(_A, _L, _P)
  return join(sort(keys(s:search_urls)), "\n")
endfunction

function! s:SearchUrl(type)
  if !has_key(s:search_urls, a:type)
    return 'http://google.com/search?q='.a:type.'+%s'
  else
    return s:search_urls[a:type]
  endif
endfunction
