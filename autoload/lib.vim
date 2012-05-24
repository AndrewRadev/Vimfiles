" File: lib.vim
" Author: Andrew Radev
" Description: The place for any functions I might decide I need.

" Capitalize first letter of argument:
" foo -> Foo
function! lib#Capitalize(word)
  return substitute(a:word, '^\w', '\U\0', 'g')
endfunction

" CamelCase underscored word:
" foo_bar_baz -> fooBarBaz
function! lib#CamelCase(word)
  return substitute(a:word, '_\(.\)', '\U\1', 'g')
endfunction

" CamelCase and Capitalize
" foo_bar_baz -> FooBarBaz
function! lib#CapitalCamelCase(word)
  return lib#Capitalize(lib#CamelCase(a:word))
endfunction

" Underscore CamelCased word:
" FooBarBaz -> foo_bar_baz
function! lib#Underscore(word)
  let result = lib#Lowercase(a:word)
  return substitute(result, '\([A-Z]\)', '_\l\1', 'g')
endfunction

" Lowercase first letter of argument:
" Foo -> foo
function! lib#Lowercase(word)
  return substitute(a:word, '^\w', '\l\0', 'g')
endfunction

" Ripped directly from haskellmode.vim
function! lib#UrlEncode(string)
  let pat  = '\([^[:alnum:]]\)'
  let code = '\=printf("%%%02X",char2nr(submatch(1)))'
  let url  = substitute(a:string,pat,code,'g')
  return url
endfunction

" Ripped directly from unimpaired.vim
function! lib#UrlDecode(str)
  let str = substitute(substitute(substitute(a:str,'%0[Aa]\n$','%0A',''),'%0[Aa]','\n','g'),'+',' ','g')
  return substitute(str,'%\(\x\x\)','\=nr2char("0x".submatch(1))','g')
endfunction

" Join the list of items given with the current path separator, escaping the
" backslash in Windows for use in regular expressions.
function! lib#RxPath(...)
  let ps = has('win32') ? '\\' : '/'
  return join(a:000, ps)
endfunction

" Checks to see if {needle} is in {haystack}.
function! lib#InString(haystack, needle)
  return (stridx(a:haystack, a:needle) != -1)
endfunction

" Trimming functions. Should be obvious.
function! lib#Ltrim(s)
  return substitute(a:s, '^\s\+', '', '')
endfunction
function! lib#Rtrim(s)
  return substitute(a:s, '\s\+$', '', '')
endfunction
function! lib#Trim(s)
  return lib#Rtrim(lib#Ltrim(a:s))
endfunction

" Wraps a string with another string if a:string is not empty, in which case
" returns the empty string.
"
" Examples:
"   lib#Wrap('/', 'foo') => '/foo/'
"   lib#Wrap('/', '')    =>  ''
function! lib#Wrap(surrounding, string)
  if a:string == ''
    return ''
  else
    return a:surrounding.a:string.a:surrounding
  endif
endfunction

" Extracts a regex match from a string.
function! lib#ExtractRx(expr, pat, sub)
  let rx = a:pat

  if stridx(a:pat, '^') != 0
    let rx = '^.*'.rx
  endif

  if strridx(a:pat, '$') + 1 != strlen(a:pat)
    let rx = rx.'.*$'
  endif

  return substitute(a:expr, rx, a:sub, '')
endfunction

" Execute a command, leaving the cursor on the current line
function! lib#InPlace(command)
  let saved_view = winsaveview()
  exe a:command
  call winrestview(saved_view)
endfunction

" The vim includeexpr
function! lib#VimIncludeExpression(fname)
  if getline('.') =~ '^runtime'
    for dir in split(&rtp, ',')
      let fname = dir.'/'.a:fname

      if(filereadable(fname))
        return fname
      endif
    endfor
  endif

  return a:fname
endfunction

" Open URLs with the system's default application. Works for both local and
" remote paths.
function! lib#OpenUrl(url)
  let url = shellescape(a:url)

  if has('mac')
    silent call system('open '.url)
  elseif has('unix')
    if executable('xdg-open')
      silent call system('xdg-open '.url.' 2>&1 > /dev/null &')
    else
      echoerr 'You need to install xdg-open to be able to open urls'
      return
    end
  else
    echoerr 'Don''t know how to open a URL on this system'
    return
  end

  echo 'Opening '.url
endfunction

" Execute the normal mode motion "motion" and return the text it marks. Note
" that the motion needs to include a visual mode key, like "V", "v" or "gv".
function! lib#GetMotion(motion)
  let saved_cursor   = getpos('.')
  let saved_reg      = getreg('z')
  let saved_reg_type = getregtype('z')

  exec 'normal! '.a:motion.'"zy'
  let text = @z

  call setreg('z', saved_reg, saved_reg_type)
  call setpos('.', saved_cursor)

  return text
endfunction

function! lib#MarkVisual(command, start_line, end_line)
  if a:start_line != line('.')
    exe a:start_line
  endif

  silent! exe a:start_line.','.a:end_line.'foldopen'

  if a:end_line > a:start_line
    exe 'normal! '.a:command.(a:end_line - a:start_line).'jg_'
  else
    exe 'normal! '.a:command.'g_'
  endif
endfunction

" Switch to the window that a:bufname is located in.
function! lib#SwitchWindow(bufname)
  let window = bufwinnr(a:bufname)
  exe window.'wincmd w'
endfunction

" Setup a one-line input buffer for a NERDTree action.
function! lib#NERDTreeInputBufferSetup(node, content, cursor_position, callback_function_name)
  " one-line buffer below everything else
  botright 1new

  " disable autocompletion
  if exists(':AcpLock')
    AcpLock
    autocmd BufLeave <buffer> AcpUnlock
  endif

  " if we leave the buffer, cancel the operation
  autocmd BufLeave <buffer> q!

  " set the content, store the callback and the node in the buffer
  call setline(1, a:content)
  setlocal nomodified
  let b:node     = a:node
  let b:callback = function(a:callback_function_name)

  " disallow opening new lines
  nmap <buffer> o <nop>
  nmap <buffer> O <nop>

  " cancel the action
  nmap <buffer> <esc> :q!<cr>
  nmap <buffer> <c-[> :q!<cr>
  map  <buffer> <c-c> :q!<cr>
  imap <buffer> <c-c> :q!<cr>

  if a:cursor_position == 'basename'
    " cursor is on basename (last path segment)
    normal! $T/
  elseif a:cursor_position == 'append'
    " cursor is in insert mode at the end of the line
    call feedkeys('A')
  endif

  " mappings to invoke the callback
  nmap <buffer> <cr>      :call lib#NERDTreeInputBufferExecute(b:callback, b:node, getline('.'))<cr>
  imap <buffer> <cr> <esc>:call lib#NERDTreeInputBufferExecute(b:callback, b:node, getline('.'))<cr>
endfunction

function! lib#NERDTreeInputBufferExecute(callback, node, result)
  " close the input buffer
  q!

  " invoke the callback
  call call(a:callback, [a:node, a:result])
endfunction
