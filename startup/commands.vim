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

" Edit important files quickly:
command! Eclipboard ClipBrd
command! Epasswords edit ~/.passwords

" Rebuild tags database:
command! RebuildTags !ctags -R .

" Refresh snippets
command! RefreshSnips runtime after/plugin/snippets.vim

" Generic console, override in different filetypes:
if has('win32')
  command! Console !start cmd
else
  command! Console !urxvt &
endif

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
  silent exe "0r!ch ".a:args
  set nomodified
  normal gg
endfunction
function! s:CheatComplete(A, L, P)
  return system('ch list')
endfunction

" Rake shortcut
command! -complete=file -nargs=* Rake !rake <args>

" Easy check of current syntax group
command! SynId echo synIDattr(synID(line('.'), col('.'), 1), 'name')

" Use 'helptags' with the bundle directory as well
command! Helptags call s:Helptags()
function! s:Helptags()
  helptags doc
  for dir in split(glob('bundle/*/doc'), '\_s')
    exe 'helptags '.dir
  endfor
endfunction

" Create dir and save
command! W silent exe "!mkdir -p %:p:h" | w | redraw!

" Quit tab, even if it's just one
command! Q call s:Q()
function! s:Q()
  try
    tabclose
  catch /E784/
    qall
  endtry
endfunction

command! Note belowright split notes.txt
command! In   belowright split ~/Dropbox/gtd/in
