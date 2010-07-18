let g:search_engines = {
      \ 'google':   'http://google.com/search?q=%s',
      \ 'hoogle':   'http://www.haskell.org/hoogle/?hoogle=%s',
      \ 'php':      'http://php.net/manual-lookup.php?pattern=%s',
      \ 'symfony':  'http://www.symfony-project.org/api/search/1_2?search=%s',
      \ 'wiki':     'http://en.wikipedia.org/w/index.php?search=%s',
      \ }

command! -nargs=* -complete=customlist,s:WebSearchComplete Search call s:WebSearch(<f-args>)
function! s:WebSearch(engine, ...)
  let a:query = lib#UrlEncode(join(a:000, " "))
  let query = printf(g:search_engines[a:engine], a:query)
  exe "Utl ol ".query
endfunction
function! s:WebSearchComplete(ArgLead, CmdLine, CursorPos)
  return filter(keys(g:search_engines), 'v:val =~ "^'.a:ArgLead.'"')
endfunction
