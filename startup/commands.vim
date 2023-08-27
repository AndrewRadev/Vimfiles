" Simpler tag searches:
runtime plugin/tagfinder.vim

DefineTagFinder Tag
DefineTagFinder Function f,function,F,singleton\ method
DefineTagFinder Class    c,class
DefineTagFinder Module   m,module
DefineTagFinder Command  c,command
DefineTagFinder Mapping  m

" Toggle settings:
" https://vim.fandom.com/wiki/Quick_generic_option_toggling
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
  call system('libreoffice '.filename.' &')
  quit!
endfunction

command! Messages BufferizeTimer 500 messages

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

" Copy a snippet of code without its initial whitespace
command! -range Snip call s:Snip(<line1>, <line2>)
function! s:Snip(from, to)
  let lines = getbufline('%', a:from, a:to)
  let non_empty_lines = filter(copy(lines), {_, l -> l !~ '^\s*$'})
  let min_whitespace_count = min(map(non_empty_lines, {_, l -> len(matchstr(l, '^\s*'))}))

  if min_whitespace_count > 0
    let whitespace_pattern = '^'.repeat('\s', min_whitespace_count)
    call map(lines, {_, l -> substitute(l, whitespace_pattern, '', '')})
  endif

  let snippet = join(lines, "\n")

  call setreg('"', snippet, 'V')
  call setreg('*', snippet, 'V')
  call setreg('+', snippet, 'V')
endfunction

command! Timestamp call s:Timestamp()
function! s:Timestamp()
  let string_ts = expand('<cword>')
  if string_ts !~ '^\d\+$'
    return
  endif

  if len(string_ts) == 13
    " it's milliseconds
    let ts = str2nr(strpart(string_ts, 0, 10))
  else
    " consider it seconds
    let ts = str2nr(string_ts)
  endif

  echomsg strftime("%c", ts)
endfunction

" Invoke a specific split/join callback based on convention
command! -nargs=1 -complete=custom,s:SplitComplete Split call s:Split(<f-args>)
function! s:Split(callback_shorthand) abort
  let mapping = s:SplitjoinShorthandMapping('split')
  let callback = mapping[a:callback_shorthand]
  call call(callback, [])
endfunction
function! s:SplitComplete(argument_lead, command_line, cursor_position)
  let mapping = s:SplitjoinShorthandMapping('split')
  return join(sort(keys(mapping)), "\n")
endfunction

command! -nargs=1 -complete=custom,s:JoinComplete Join call s:Join(<f-args>)
function! s:Join(callback_shorthand) abort
  let mapping = s:SplitjoinShorthandMapping('join')
  let callback = mapping[a:callback_shorthand]
  call call(callback, [])
endfunction
function! s:JoinComplete(argument_lead, command_line, cursor_position)
  let mapping = s:SplitjoinShorthandMapping('join')
  return join(sort(keys(mapping)), "\n")
endfunction

function s:SplitjoinShorthandMapping(splitjoin)
  if a:splitjoin == 'split'
    let callbacks = b:splitjoin_split_callbacks
    let prefix = 'split-'
  elseif a:splitjoin == 'join'
    let callbacks = b:splitjoin_join_callbacks
    let prefix = 'join-'
  else
    throw "Neither 'split' nor 'join'" . a:splitjoin
  endif

  let mapping = {}
  for callback in callbacks
    let key = lib#Dasherize(split(callback, '#')[-1])
    let key = substitute(key, '^'.prefix, '', '')
    let mapping[key] = callback
  endfor

  return mapping
endfunction

" Reimplement Fugitive's :Gbrowse for my convenience
command!
      \ -bar -bang -range=-1 -nargs=*
      \ -complete=customlist,fugitive#CompleteObject
      \ Gbrowse exe fugitive#BrowseCommand(<line1>, <count>, +"<range>", <bang>0, "<mods>", <q-args>)

command! -nargs=1 Egithub call s:Egithub(<q-args>)

function! s:Egithub(url) abort
  let github_pattern = 'github\.com/\%(.\{-}\)/blob/\%([^/]\+\)/\(.\{-}\)\%(#L\(\d\+\)\%(-L\d\+\)\=\)\=$'
  let [result, path, line; _rest] = matchlist(a:url, github_pattern)

  if result == ''
    echoerr "Couldn't parse github URL from: "..a:url
    return
  endif

  if !filereadable(path)
    echoerr "Couldn't find path in current root: "..path
    return
  endif

  exe 'edit' path
  exe line
endfunction

command! Restart call s:Restart()

function s:Restart()
  let transient_buffers = []

  for tab_index in range(tabpagenr('$'))
    for bufnr in tabpagebuflist(tab_index + 1)
      if getbufvar(bufnr, '&filetype') == 'nerdtree'
        call add(transient_buffers, bufnr)
      endif
    endfor
  endfor

  for buffer in transient_buffers
    for window_id in win_findbuf(buffer)
      call win_execute(window_id, 'noautocmd quit', 'silent')
    endfor
  endfor

  mksession! /tmp/restart_session.vim

  call system('(sleep 0.3 && xdotool type ''vim +"source /tmp/restart_session.vim"'' && xdotool key Return) &')
  qall!
endfunction
