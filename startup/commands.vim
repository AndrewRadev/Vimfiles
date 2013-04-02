" Simpler tag searches:
runtime plugin/tagfinder.vim

DefineTagFinder Function f,function,F,singleton\ method
DefineTagFinder Class    c,class
DefineTagFinder Module   m,module
DefineTagFinder Command  c,command
DefineTagFinder Mapping  m

" Toggle settings:
command! -nargs=+ MapToggle call s:MapToggle(<f-args>)
function! s:MapToggle(key, opt)
  let cmd = ':set '.a:opt.'! \| set '.a:opt."?\<CR>"
  exec 'nnoremap '.a:key.' '.cmd
endfunction

MapToggle sl list
MapToggle sh hlsearch
MapToggle sw wrap
MapToggle ss spell
MapToggle sc cursorcolumn

" https://github.com/bjeanes/dot-files/blob/master/vim/vimrc
" For when you forget to sudo.. Really write the file.
command! SudoWrite call s:SudoWrite()
function! s:SudoWrite()
  write !sudo tee % >/dev/null
  e!
endfunction

" Avoid typing errors
command! W write

" Rebuild tags database:
command! RebuildTags call s:RebuildTags()
function! s:RebuildTags()
  if exists('g:ctags_exclude_patterns')
    let excludes = join(map(copy(g:ctags_exclude_patterns), '''--exclude="''.v:val.''"'''), ' ')
    exe '!ctags -R '.excludes
  else
    !ctags -R .
  endif
endfunction
command! -nargs=+ -bang -complete=dir TagsExclude call s:TagsExclude('<bang>', <f-args>)
function! s:TagsExclude(bang, ...)
  if !exists('g:ctags_exclude_patterns') || (a:bang == '!')
    let g:ctags_exclude_patterns = []
  endif

  call extend(g:ctags_exclude_patterns, a:000)
endfunction

" Refresh snippets
command! RefreshSnips runtime after/plugin/snippets.vim | edit!

" Clear up garbage:
command! CleanWhitespace  call lib#WithSavedState('%s/\s\+$//e')
command! CleanAnsiColors  call lib#WithSavedState('%s/\[.\{-}m//ge')
command! CleanEol         call lib#WithSavedState('%s/$//e')
command! CleanDoubleLines call lib#WithSavedState('%s/^\n\+/\r/e')

" Easy check of current syntax group
command! Syn call syntax_attr#SyntaxAttr()

" Outline the contents of the buffer
command! -nargs=* Outline call s:Outline(<f-args>)
function! s:Outline(...)
  if a:0 > 0
    let pattern = '\<\('.join(a:000, '\|').'\)\>'
  elseif exists('b:outline_pattern')
    let pattern = b:outline_pattern
  elseif !exists('b:outlined')
    echoerr "No b:outline_pattern for this buffer"
  endif

  if exists('b:outlined') " Un-outline it
    FoldEndFolding
    unlet b:outlined
  else
    exe "FoldMatching ".pattern." -1"
    let b:outlined = 1
    setlocal foldenable
  endif
endfunction

" Setup the "Run" and "Console" commands for the current filetype
command! -nargs=* RunCommand
      \ command! -range=% -buffer -complete=file -nargs=* Run <args>
command! -nargs=* ConsoleCommand
      \ command! -range=% -buffer -complete=file -nargs=* Console <args>

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

" Open all files in quickfix window in tabs
command! Ctabs call s:Ctabs()
function! s:Ctabs()
  let files = {}
  for entry in getqflist()
    let filename = bufname(entry.bufnr)
    let files[filename] = 1
  endfor

  for file in keys(files)
    silent exe "tabedit ".file
  endfor
endfunction

command! -nargs=* -complete=command Bufferize call s:Bufferize(<f-args>)
function! s:Bufferize(...)
  let cmd = join(a:000, ' ')
  redir => output
  silent exe cmd
  redir END

  new
  setlocal nonumber
  call append(0, split(output, "\n"))
  set nomodified
endfunction

" Open all git-modified files in tabs
command! Gfiles call s:Gfiles()
function! s:Gfiles()
  let files = split(system('git status -s -uall | cut -b 4-'), '\n')

  for file in files
    silent exe "tabedit ".file
  endfor
endfunction

" Redraw and restore screen state
command! Redraw call s:Redraw()
function! s:Redraw()
  syntax sync fromstart
  nohlsearch
  redraw!
endfunction

" Get the gender of the German word under the cursor
command! Gender call s:Gender()
function! s:Gender()
  let word = expand('<cword>')
  echo system('gender '.word)
endfunction
