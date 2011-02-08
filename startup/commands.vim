" Simpler tag searches:
command! -nargs=1 -complete=customlist,s:CompleteFunction Function call s:Tag('f', <f-args>)
command! -nargs=1 -complete=customlist,s:CompleteClass    Class    call s:Tag('c', <f-args>)
function! s:Tag(type, tag)
  exec "TTags ".a:type." ".a:tag
  if len(getqflist()) == 1
    cfirst
    cclose
  endif
endfunction
function! s:CompleteFunction(A, L, P)
  return sort(map(filter(taglist('^'.a:A), 'v:val["kind"] == "f"'), 'v:val["name"]'))
endfunction
function! s:CompleteClass(A, L, P)
  return sort(map(filter(taglist('^'.a:A), 'v:val["kind"] == "c"'), 'v:val["name"]'))
endfunction

" Toggle settings:
command! -nargs=+ MapToggle call lib#MapToggle(<f-args>)

MapToggle sl list
MapToggle sh hlsearch
MapToggle sw wrap
MapToggle ss spell
MapToggle sc cursorcolumn

" Rebuild tags database:
command! RebuildTags !ctags -R .

" Refresh snippets
command! RefreshSnips runtime after/plugin/snippets.vim

" Change fonts on the GUI:
if has("win32")
  command! FontDejaVu   set guifont=DejaVu_Sans_Mono:h12
  command! FontTerminus set guifont=Terminus:h15
else
  command! FontAndale   set guifont=Andale\ Mono\ 13
  command! FontTerminus set guifont=Terminus\ 14
endif

" Clear up garbage:
command! CleanGarbage call lib#InPlace('%s/\s\+$//e')

" Fix dos-style line endings:
command! FixEol call lib#InPlace('%s/$//e')

" Cheat sheet shortcut
command! -nargs=* -complete=custom,s:CheatComplete Cheat new | call s:Cheat(<q-args>)
function! s:Cheat(args)
  silent exe "e! ".tempname()
  silent exe "0r!cheat ".a:args
  set nomodified
  normal gg
endfunction
function! s:CheatComplete(A, L, P)
  return system('cheat sheets | cut -b3-')
endfunction

" Easy check of current syntax group
command! Syn call syntax_attr#SyntaxAttr()

" Use 'helptags' with the bundle directory as well
command! Helptags call pathogen#helptags()

" Quit tab, even if it's just one
command! Q call s:Q()
function! s:Q()
  try
    tabclose
  catch /E784/ " Can't close last tab
    qall
  endtry
endfunction

" Quickly open up note-files
command! Note belowright split notes.txt

" Setup the "Run" and "Console" commands for the current filetype
command! -nargs=* RunCommand
      \ command! -buffer -complete=file -nargs=* Run <args>
command! -nargs=* ConsoleCommand
      \ command! -buffer -complete=file -nargs=* Console <args>

" Should probably be in a project-specific file
command! ReadCucumberSteps r!cucumber | sed -n -e '/these snippets/,$ p' | sed -n -e '2,$ p'

command! Chmodx !chmod +x '%'
