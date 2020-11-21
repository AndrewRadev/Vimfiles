RunCommand RustRun
compiler cargo

setlocal tags+=Cargo.tags

nnoremap <buffer> gm :call <SID>Doc()<cr>

let b:extract_var_template = 'let %s = %s;'
let b:inline_var_pattern   = 'let \%(\s*mut\s\+\)\=\(\k\+\)\%(: [^=]\+\)\=\s\+=\s\+\(.*\);'

let b:outline_pattern = '\s*\%(pub\s*\)\=\(impl\|fn\|struct\|macro_rules!\)\(\s\|$\)'

cmap <buffer><script><expr> <Plug><ctag> substitute(<SID>RustCursorTag(),'^$',"\<c-c>",'')

nmap <buffer> <c-]>       :<c-u>exe v:count1."tag <Plug><ctag>"<cr>
nmap <buffer> g<c-]>      :<c-u>exe          "tjump <Plug><ctag>"<cr>
nmap <buffer> g]          :<c-u>exe          "tselect <Plug><ctag>"<cr>
nmap <buffer> <c-w>]      :<c-u>exe v:count1."stag <Plug><ctag>"<cr>
nmap <buffer> <c-w><c-]>  :<c-u>exe v:count1."stag <Plug><ctag>"<cr>
nmap <buffer> <c-w>g<c-]> :<c-u>exe          "stjump <Plug><ctag>"<cr>
nmap <buffer> <c-w>g]     :<c-u>exe          "stselect <Plug><ctag>"<cr>
nmap <buffer> <c-w>}      :<c-u>exe v:count1."ptag <Plug><ctag>"<cr>
nmap <buffer> <c-w>g}     :<c-u>exe v:count1."ptjump <Plug><ctag>"<cr>

onoremap <buffer> am :<c-u>call <SID>FunctionTextObject('a')<cr>
xnoremap <buffer> am :<c-u>call <SID>FunctionTextObject('a')<cr>
onoremap <buffer> im :<c-u>call <SID>FunctionTextObject('i')<cr>
xnoremap <buffer> im :<c-u>call <SID>FunctionTextObject('i')<cr>
function! s:FunctionTextObject(mode)
  let saved_position = winsaveview()
  let function_start = search('^\s*\%(pub\s*\)\=fn\>', 'bWc')
  if function_start > 0
    call search('{\s*\%(\/\/.*\)\=$', 'W')
    normal! %
    let function_end = line('.')
  endif
  call winrestview(saved_position)

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

command! -buffer Emain edit src/main.rs

" LanguageClient setup (optional)
if has_key(get(g:, 'LanguageClient_serverCommands'), &filetype)
  nnoremap <buffer> <c-p> :call LanguageClient#textDocument_hover()<cr>
  nnoremap <buffer> gd :call LanguageClient#textDocument_definition()<CR>
  command! -buffer Rename call LanguageClient#textDocument_rename()
  set formatexpr=LanguageClient#textDocument_rangeFormatting_sync()
end

let s:std_prelude = {
      \ 'Copy':                'std::marker::Copy',
      \ 'Send':                'std::marker::Send',
      \ 'Sized':               'std::marker::Sized',
      \ 'Sync':                'std::marker::Sync',
      \ 'Unpin':               'std::marker::Unpin',
      \ 'Drop':                'std::ops::Drop',
      \ 'Fn':                  'std::ops::Fn',
      \ 'FnMut':               'std::ops::FnMut',
      \ 'FnOnce':              'std::ops::FnOnce',
      \ 'drop':                'std::mem::drop',
      \ 'Box':                 'std::boxed::Box',
      \ 'ToOwned':             'std::borrow::ToOwned',
      \ 'Clone':               'std::clone::Cone',
      \ 'PartialEq':           'std::cmp::PartialEq',
      \ 'PartialOrd':          'std::cmp::PartialOrd',
      \ 'Eq':                  'std::cmp::Eq',
      \ 'Ord':                 'std::cmp::Ord',
      \ 'AsRef':               'std::convert::AsRef',
      \ 'AsMut':               'std::convert::AsMut',
      \ 'Into':                'std::convert::Into',
      \ 'From':                'std::convert::From',
      \ 'Default':             'std::default::Default',
      \ 'Iterator':            'std::iter::Iterator',
      \ 'Extend':              'std::iter::Extend',
      \ 'IntoIterator':        'std::iter::IntoIterator',
      \ 'DoubleEndedIterator': 'std::iter::DoubleEndedIterator',
      \ 'ExactSizeIterator':   'std::iter::ExactSizeIterator',
      \ 'Option':              'std::option',
      \ 'Some':                'std::option::Option',
      \ 'None':                'std::option::Option',
      \ 'Result':              'std::result',
      \ 'Ok':                  'std::result::Result',
      \ 'Err':                 'std::result::Result',
      \ 'String':              'std::string::String',
      \ 'ToString':            'std::string::ToString',
      \ 'Vec':                 'std::vec::Vec',
      \ }

function! s:Doc() abort
  try
    let saved_iskeyword = &l:iskeyword
    setlocal iskeyword+=:
    let term = expand('<cword>')
  finally
    let &l:iskeyword = saved_iskeyword
  endtry

  let [imported_symbols, aliases] = s:ParseImports()
  let term_head = split(term, '::')[0]

  if has_key(imported_symbols, term_head)
    let term = imported_symbols[term_head] . '::' . term
  elseif has_key(aliases, term_head)
    let term = aliases[term_head] . '::' . term
  elseif has_key(s:std_prelude, term_head)
    let term = s:std_prelude[term_head] . '::' . term
  endif

  let term_path = split(term, '::')

  if term_path[0] == 'std'
    call Open('https://doc.rust-lang.org/std/?search='.term)
  elseif term_path[0] == 'crate'
    echomsg "Local documentation not supported yet: ".term
    return
  else
    let package = term_path[0]
    let term_name = term_path[-1]
    let path = join(term_path[1:-2], '/')
    call Open('https://docs.rs/'.package.'/latest/'.path.'/?search='.term_name)
    return
  endif
endfunction

function! s:ParseImports()
  let imported_symbols = {}
  let aliases = {}

  for line in filter(getline(1, '$'), {_, l -> l =~ '^\s*use'})
    let namespace = matchstr(line, '^\s*use \zs.\+\ze::')
    let symbols = []

    if line =~ '::\k\+ as \k\+;'
      let real_name      = matchstr(line, 'use\s\+\zs\%(::\|\k\+\)\+\ze as \k\+;')
      let alias          = matchstr(line, '::\k\+ as \zs\k\+\ze;')
      let symbols        = [alias]
      let aliases[alias] = real_name
    endif

    if symbols == []
      let symbols = [matchstr(line, '::\zs\k\+\ze;')]
    endif
    if symbols == [""]
      let symbols = split(matchstr(line, '::{\zs.*\ze};'), ',\s*')
    endif
    if symbols == []
      continue
    endif

    for symbol in symbols
      let imported_symbols[symbol] = namespace
    endfor
  endfor

  return [imported_symbols, aliases]
endfunction

function! s:RustCursorTag() abort
  let [_, aliases] = s:ParseImports()
  let identifier = expand('<cword>')

  if has_key(aliases, identifier)
    return aliases[identifier]
  else
    return identifier
  endif
endfunction
