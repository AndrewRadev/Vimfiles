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

" Dasherize CamelCased word:
" FooBarBaz -> foo-bar-baz
function! lib#Dasherize(word)
  let result = lib#Lowercase(a:word)
  return substitute(result, '\([A-Z]\)', '-\l\1', 'g')
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
  return substitute(a:s, '^\_s\+', '', '')
endfunction
function! lib#Rtrim(s)
  return substitute(a:s, '\_s\+$', '', '')
endfunction
function! lib#Trim(s)
  return lib#Rtrim(lib#Ltrim(a:s))
endfunction

" Trim a list of items
function! lib#TrimList(ss)
  return map(a:ss, 'lib#Trim(v:val)')
endfunction

" Trim each line in the given string
function! lib#TrimLines(s)
  return join(lib#TrimList(split(a:s, "\n")), "\n")
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

" Execute a command, leaving the cursor on the current line and avoiding
" clobbering the search register.
function! lib#WithSavedState(command)
  let current_histnr = histnr('/')

  call lib#InPlace(a:command)

  if current_histnr != histnr('/')
    call histdel('/', -1)
    let @/ = histget('/', -1)
  endif
endfunction

" The vim includeexpr
function! lib#VimIncludeExpression(fname)
  if getline('.') =~ '^\s*runtime'
    for dir in split(&rtp, ',')
      let fname = dir.'/'.a:fname

      if(filereadable(fname))
        return fname
      endif
    endfor
  endif

  return a:fname
endfunction

" Execute the normal mode motion "motion" and return the text it marks. Note
" that the motion needs to include a visual mode key, like "V", "v" or "gv".
"
" Note that it respects user remappings via "normal" (rather than "normal!").
"
function! lib#GetMotion(motion)
  let saved_view          = winsaveview()
  let saved_register_text = getreg('z', 1)
  let saved_register_type = getregtype('z')

  let @z = ''
  exec 'silent normal '.a:motion.'"zy'
  let text = @z

  if text == ''
    " nothing got selected, so we might still be in visual mode
    exe "normal! \<esc>"
  endif

  call setreg('z', saved_register_text, saved_register_type)
  call winrestview(saved_view)

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

" Finds the configuration's default paste register based on the 'clipboard'
" option.
function! lib#DefaultRegister()
  if &clipboard =~ 'unnamedplus'
    return '+'
  elseif &clipboard =~ 'unnamed'
    return '*'
  else
    return '"'
  endif
endfunction
