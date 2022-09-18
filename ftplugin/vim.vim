setlocal foldmethod=indent

let b:surround_{char2nr('i')} = "if \1if: \1 \r endif"
let b:surround_{char2nr('w')} = "while \1while: \1 \r endwhile"
let b:surround_{char2nr('f')} = "for \1for: \1 {\r endfor"
let b:surround_{char2nr('e')} = "foreach \1foreach: \1 \r enforeach"
let b:surround_{char2nr('F')} = "function! \1function: \1() \r endfunction"
let b:surround_{char2nr('T')} = "try \r endtry"

let b:surround_{char2nr('\')} = "\\(\r\\)"
let b:surround_indent = 1

let b:outline_pattern = '^\s*\(fun\%[ction]\|com\%[mand]\)\>'
let b:deleft_closing_pattern = '^\s*end\(\k\{-}\)\>'

let b:extract_var_template = 'let %s = %s'

let b:whatif_command = 'Debug %s'

RunCommand so %

nmap <buffer> gm :exe "help ".expand("<cword>")<cr>

" Copied/Adapted from vim-rails
exe 'cmap <buffer><script><expr> <Plug><cfile> <SID>Includeexpr()'

nmap <buffer><silent> gf         :find    <Plug><cfile><CR>
nmap <buffer><silent> <C-W>f     :sfind   <Plug><cfile><CR>
nmap <buffer><silent> <C-W><C-F> :sfind   <Plug><cfile><CR>
nmap <buffer><silent> <C-W>gf    :tabfind <Plug><cfile><CR>
cmap <buffer>         <C-R><C-F> <Plug><cfile>

function! s:Includeexpr() abort
  let filename = ''

  try
    let saved_iskeyword = &iskeyword
    set iskeyword+=#

    let filename = expand('<cword>')
  finally
    let &iskeyword = saved_iskeyword
  endtry

  if stridx(filename, '#') >= 0
    let parts = split(filename, '#')
    let path = 'autoload/' .. join(parts[0:-2], '/') .. '.vim'
    let resolved_path = globpath(&runtimepath, path)

    if resolved_path != ''
      call rustbucket#util#SetFileOpenCallback(resolved_path, '^\s*fun.*\<\zs' .. filename .. '(')
      return resolved_path
    endif
  endif

  return expand('<cfile>')
endfunction

command! -buffer Lookup call lookup#lookup()
nnoremap <buffer> gd :call lookup#lookup()<cr>

setlocal includeexpr=lib#VimIncludeExpression(v:fname)

cmap <buffer><script><expr> <Plug><ctag> substitute(<SID>VimCursorTag(),'^$',"\<c-c>",'')

nmap <buffer> <c-]>       :<c-u>exe v:count1."tag <Plug><ctag>"<cr>
nmap <buffer> g<c-]>      :<c-u>exe          "tjump <Plug><ctag>"<cr>
nmap <buffer> g]          :<c-u>exe          "tselect <Plug><ctag>"<cr>
nmap <buffer> <c-w>]      :<c-u>exe v:count1."stag <Plug><ctag>"<cr>
nmap <buffer> <c-w><c-]>  :<c-u>exe v:count1."stag <Plug><ctag>"<cr>
nmap <buffer> <c-w>g<c-]> :<c-u>exe          "stjump <Plug><ctag>"<cr>
nmap <buffer> <c-w>g]     :<c-u>exe          "stselect <Plug><ctag>"<cr>
nmap <buffer> <c-w>}      :<c-u>exe v:count1."ptag <Plug><ctag>"<cr>
nmap <buffer> <c-w>g}     :<c-u>exe v:count1."ptjump <Plug><ctag>"<cr>

function! s:VimCursorTag() abort
  let pattern = '\%(\k\+#\)*\%([bgstw]:\|<SID>\)\=\k\+'

  if !search(pattern, 'Wbc', line('.'))
    return ''
  endif
  let start_col = col('.')

  if !search(pattern, 'We', line('.'))
    return ''
  endif
  let end_col = col('.')

  let identifier = sj#GetCols(start_col, end_col)
  let identifier = substitute(identifier, '^<SID>', 's:', '')
  return identifier
endfunction

onoremap <buffer> am :<c-u>call <SID>FunctionTextObject('a')<cr>
xnoremap <buffer> am :<c-u>call <SID>FunctionTextObject('a')<cr>
onoremap <buffer> im :<c-u>call <SID>FunctionTextObject('i')<cr>
xnoremap <buffer> im :<c-u>call <SID>FunctionTextObject('i')<cr>
function! s:FunctionTextObject(mode)
  let function_start = search('^\s*func\%[tion]\>', 'bWnc')
  let function_end   = search('^\s*endfunc\%[tion]\>', 'Wnc')

  if function_start <= 0 || function_end <= 0
    return
  elseif a:mode == 'a'
    if function_start == 1
      " then select whitespace below
      let start = function_start
      let end   = nextnonblank(function_end + 1) - 1
    else
      " select whitespace above
      let start = prevnonblank(function_start - 1) + 1
      let end   = function_end
    endif

    call lib#MarkVisual('V', start, end)
  elseif a:mode == 'i' && (function_end - function_start) > 1
    call lib#MarkVisual('V', function_start + 1, function_end - 1)
  endif
endfunction

if !exists(':Implement')
  command! -buffer Implement call s:Implement()
  function! s:Implement()
    if !isdirectory('autoload')
      echomsg 'No "autoload" directory found here.'
    endif

    let saved_iskeyword = &iskeyword
    set iskeyword+=#,:
    let function_name = expand('<cword>')
    let &iskeyword = saved_iskeyword

    if function_name =~ '^s:'
      call s:ImplementScriptLocal(function_name)
    elseif function_name =~ '^\k\+#'
      call s:ImplementAutoloaded(function_name)
    else
      echoerr printf('Don''t know how to implement "%s"', function_name)
    endif
  endfunction

  function! s:ImplementAutoloaded(function_name)
    let function_name = a:function_name
    let parts         = split(function_name, '#')

    call remove(parts, -1)
    if empty(parts)
      echoerr printf('"%s" doesn''t look like an autoloaded function', function_name)
    endif

    let path = printf('autoload/%s.vim', join(parts, '/'))
    let dir  = fnamemodify(path, ':p:h')
    if !isdirectory(dir)
      mkdir(dir, 'p')
    endif

    if fnamemodify(path, ':p') != expand('%:p')
      exe 'split '.path
    endif

    call append(line('$'), [
          \ '',
          \ 'function! '.function_name.'()',
          \ 'endfunction',
          \ ])
    normal! G
  endfunction

  function! s:ImplementScriptLocal(function_name)
    let function_name = a:function_name

    call append(line('$'), [
          \ '',
          \ 'function! '.function_name.'()',
          \ 'endfunction',
          \ ])
    normal! G
  endfunction
endif

command! -buffer Localvars call s:Localvars()
function! s:Localvars()
  let args = reverse(split(sj#GetMotion('vi('), ',\s*'))

  for arg in args
    call append(line('.'), 'let '.arg.' = a:'.arg)
  endfor

  exe 'normal! '.string(len(args) + 1).'=='
endfunction
