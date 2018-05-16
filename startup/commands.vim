" Simpler tag searches:
runtime plugin/tagfinder.vim

DefineTagFinder Tag
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
command! Q quit
command! E edit

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
    let pattern = join(a:000, '\|')
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
" Note: just uses the external "gender" script
command! Gender call s:Gender()
function! s:Gender()
  let word = expand('<cword>')
  echo system('gender '.word)
endfunction

command! -nargs=* DiffPaste call s:DiffPaste(<q-args>)
function! s:DiffPaste(flags)
  let diff           = getreg(lib#DefaultRegister())
  let filename       = expand('%')
  let current_lineno = line('.')
  let current_line   = getline('.')

  " Strip out some metadata, split by positional information
  let blocks        = []
  let current_block = []

  for line in split(diff, "\n")
    if line =~ '^\%(index\|diff --git\|---\|+++\)'
      continue
    elseif line =~ '^@@.*@@.*$'
      call add(blocks, current_block)
      let current_block = []
      call add(current_block, line)
    else
      call add(current_block, line)
    endif
  endfor

  call add(blocks, current_block)

  for block in blocks
    if empty(block)
      continue
    endif

    let old_count = len(filter(copy(block), "v:val !~ '+'"))
    let new_count = len(filter(copy(block), "v:val !~ '-'"))

    " Add custom metadata
    let header = [
          \ 'diff --git a/'.filename.' b/'.filename,
          \ '--- a/'.filename,
          \ '+++ b/'.filename,
          \ ]

    " We may not have positional info, use cursor location
    if block[0] !~ '^@@.*@@.*$'
      call add(header, '@@ -'.current_lineno.','.old_count.' +'.current_lineno.','.new_count.' @@ '.current_line)
    endif

    let block = extend(header, block)
    let diff  = join(block, "\n")

    " Perform this diff
    let command_result = system('git apply '.a:flags.' -', diff."\n")
    if v:shell_error
      echoerr command_result
      return
    endif
  endfor

  edit!
endfunction

" Make the given command repeatable using repeat.vim
command! -nargs=* Repeatable call s:Repeatable(<q-args>)
function! s:Repeatable(command)
  exe a:command
  call repeat#set(':Repeatable '.a:command."\<cr>")
endfunction

" Open the given range in libreoffice for pasting highlighted code in
" presentations
command! -range=% Tortf call s:Tortf(<line1>, <line2>)
function! s:Tortf(start, end)
  let filename = tempname().'.html'
  exe a:start.','.a:end.'TOhtml'
  exe 'write '.filename
  call system('libreoffice '.filename)
  quit!
endfunction

command! Messages BufferizeTimer 500 messages

" Invoke the `lebab` tool on the current buffer. Usage:
"
"   Lebab <transform1> <transform2> [...]
"
" This will run all the transforms specified and replace the buffer with the
" results. The available transforms tab-complete.
"
command! -nargs=+ -complete=custom,s:LebabComplete
      \ Lebab call s:Lebab(<f-args>)
function! s:Lebab(...)
  let transforms = a:000
  let filename = expand('%:p')

  let command_line = 'lebab '.shellescape(filename).
        \ ' --transform '.join(transforms, ',')

  let new_lines = systemlist(command_line)
  if v:shell_error
    echoerr "There was an error running lebab: ".join(new_lines, "\n")
    return
  endif

  %delete _
  call setline(1, new_lines)
endfunction

let s:lebab_transforms = []

function! s:LebabComplete(argument_lead, command_line, cursor_position)
  if len(s:lebab_transforms) == 0
    for line in systemlist("lebab --help | egrep '^\\s+\\+'")
      call add(s:lebab_transforms, matchstr(line, '^\s\++ \zs[a-zA-Z-]\+'))
    endfor
  endif

  return join(sort(s:lebab_transforms), "\n")
endfunction

" Trace Vim exceptions
command! Trace call exception#trace()

command! -complete=file -nargs=1 Swap call s:Swap(<f-args>)
function! s:Swap(filename)
  let first_filename = expand('%')
  let second_filename = a:filename
  let temp_filename = tempname()

  if rename(first_filename, temp_filename) < 0
    echoerr "Couldn't rename ".first_filename." to ".temp_filename
    return
  endif
  if rename(second_filename, first_filename) < 0
    echoerr "Couldn't rename ".second_filename." to ".first_filename
    return
  endif
  if rename(temp_filename, second_filename) < 0
    echoerr "Couldn't rename ".temp_filename." to ".second_filename
    return
  endif

  exe 'edit! '.fnameescape(second_filename)
  exe 'edit! '.fnameescape(first_filename)
endfunction

" Debug
command! -nargs=* Debug call s:Debug(string(<args>))
function! s:Debug(args)
  Decho a:args
endfunction
