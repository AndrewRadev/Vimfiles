let g:search_engines = {
      \ 'google':  'http://google.com/search?q=%s',
      \ 'hoogle':  'http://www.haskell.org/hoogle/?hoogle=%s',
      \ 'php':     'http://php.net/manual-lookup.php?pattern=%s',
      \ 'symfony': 'http://www.symfony-project.org/api/search/1_2?search=%s',
      \ }

command! -nargs=* -complete=customlist,WebSearchComplete Search call WebSearch(<f-args>)
function! WebSearch(engine, ...)
	let a:query = lib#UrlEncode(join(a:000, " "))
  let query = printf(g:search_engines[a:engine], a:query)
  exe "Utl ol ".query
endfunction
function! WebSearchComplete(ArgLead, CmdLine, CursorPos)
  return filter(keys(g:search_engines), 'v:val =~ "^'.a:ArgLead.'"')
endfunction
