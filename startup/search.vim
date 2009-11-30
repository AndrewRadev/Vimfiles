let g:search_engines = {
      \ 'google': 'http://google.com/search?q=%s',
      \ 'php': 'http://php.net/manual-lookup.php?pattern=%s',
      \ 'symfony': 'http://www.symfony-project.org/api/search/1_2?search=%s',
      \ }

command! -nargs=* -complete=customlist,SearchComplete Search call Search(<f-args>)
function! Search(engine, word)
  let query = printf(g:search_engines[a:engine], a:word)
  exe "Utl ol ".query
endfunction
function! SearchComplete(A, L, P)
  return filter(keys(g:search_engines), 'v:val =~ "^'.a:A.'"')
endfunction
