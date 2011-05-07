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

" Clear up garbage:
command! CleanWhitespace call lib#InPlace('%s/\s\+$//e')
command! CleanAnsiColors call lib#InPlace('%s/\[.\{-}m//ge')
command! CleanEol        call lib#InPlace('%s/$//e')

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

command! -nargs=* ProjInit call s:ProjInit(<f-args>)
function! s:ProjInit(...)
  e _project.vim
  write

  if a:0 > 0
    let project_name = a:1
  else
    let project_name = expand('%:p:h:t')
  end

  let cwd          = getcwd()
  let project_file = expand('%:p')

  ProjFile

  let project_body = [
        \ '',
        \ '['.project_name.']',
        \ 'path = '.cwd,
        \ 'vim = '.project_file,
        \ ]

  call append(line('$'), project_body)
  write
  ProjReload

  exec "Proj ".project_name
endfunction

" Make filename under cursor relative/absolute
command! -range Absolutize call <SID>TransformFilenameUnderCursor('p')
command! -range Relativize call <SID>TransformFilenameUnderCursor('.')
function! s:TransformFilenameUnderCursor(modifier)
  let transformation = 'fnamemodify(submatch(0), ":'.a:modifier.'")'
  let current_mode   = mode()

  if current_mode == 'v' || current_mode == 'V'
    call lib#InPlace('s/\%V.*\%V/\='.transformation)
  else
    call lib#InPlace('s/\f*\%#\f*/\='.transformation)
  endif
endfunction
