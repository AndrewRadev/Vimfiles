RunCommand RustRun
compiler cargo
set makeprg=cargo\ test

setlocal tags+=Cargo.tags

nnoremap <buffer> gm :call rustbucket#Doc()<cr>
nnoremap <buffer> gi :call rustbucket#Info()<cr>

let b:extract_var_template = 'let %s = %s;'
let b:inline_var_pattern   = 'let \%(\s*mut\s\+\)\=\(\k\+\)\%(: [^=]\+\)\=\s\+=\s\+\(.*\);'

let b:outline_pattern = '\s*\%(pub\s*\)\=\(impl\|fn\|struct\|enum\|macro_rules!\)\(\s\|$\)'

" call lsp#enable()

" Kind of basic, but might do the trick for now
if !exists(':A')
  command! -buffer A call s:A()
  function s:A()
    let filename = expand('%')

    if filename =~ 'src/[^/]\+\.rs$'
      let basename = matchstr(filename, 'src/\zs[^/]\+\ze\.rs$')
      if filereadable('tests/test_'.basename.'.rs')
        exe 'edit tests/test_'.basename.'.rs'
        return
      end

      " otherwise, find first file
      let test_files = glob('tests/*.rs', 0, 1)

      if len(test_files) > 0
        exe 'edit '.test_files[0]
      else
        echomsg "No test files found"
      endif
    elseif filename =~ 'tests/.*\.rs$'
      if filereadable('src/lib.rs')
        edit src/lib.rs
      else
        echomsg "No src/lib.rs found"
      endif
    else
      echomsg "No alternate file found"
    endif
  endfunction
endif

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
" if has_key(get(g:, 'LanguageClient_serverCommands'), &filetype)
"   nnoremap <buffer> <c-p> :call LanguageClient#textDocument_hover()<cr>
"   nnoremap <buffer> gd :call LanguageClient#textDocument_definition()<CR>
"   command! -buffer Rename call LanguageClient#textDocument_rename()
"   set formatexpr=LanguageClient#textDocument_rangeFormatting_sync()
" end

function! s:RustCursorTag() abort
  let identifier = rustbucket#identifier#AtCursor()
  if empty(identifier)
    return ''
  endif

  return identifier.symbol
endfunction
