autocmd BufRead *.php call s:DetectBufferProperties()
function! s:DetectBufferProperties()
  call s:Set('b:current_app_name',    DetectAppName())
  call s:Set('b:current_module_name', DetectModuleName())
  call s:Set('b:current_model_name',  DetectModelName())
endfunction

let s:PS            = has('win32') ? '\\' : '/'
let s:capture_group = '\(.\{-}\)'
let s:anything      = '.*'

function! s:Set(var, value)
  if !exists(a:var)
    let {a:var} = a:value
  endif
endfunction

function! DetectAppName()
  let path = expand('%:p')

  if path =~# 'test'.s:PS.'functional' " we're in a functional test
    let rx = lib#RxPath('test', 'functional', s:capture_group)
    let rx .= s:PS
  else " we're somewhere in a specific application
    let rx = lib#RxPath('apps', s:capture_group).s:PS
  endif

  if match(expand('%:p'), rx) != -1
    return lib#ExtractRx(expand('%:p'), rx, '\1')
  endif

  return 0
endfunction

function! DetectModuleName()
  let path = expand('%:p')

  if path =~# 'test'.s:PS.'functional' " we're in a functional test
    let rx = lib#RxPath('test', 'functional', s:anything, s:capture_group)
    let rx .= 'ActionsTest\.php$'
  else " we're somewhere in a specific application
    let rx = lib#RxPath('modules', s:capture_group)
    let rx .= s:PS
  endif

  if match(path, rx) != -1
    return lib#ExtractRx(path, rx, '\1')
  endif

  return 0
endfunction

function! DetectModelName()
  let path = expand('%:p')

  if match(path, 'test'.s:PS.'unit') != -1 " Then we're in a unit test
    return lib#Capitalize(lib#ExtractRx(path, s:PS.s:capture_group.'Test.php$', '\1'))
  endif

  let rx = lib#RxPath('lib', s:anything, 'doctrine', s:capture_group)
  let rx .= '\(Table\|FormFilter\|Form\)\{,1}'
  let rx .= '\.class\.php'
  let rx .= '$'

  if match(path, rx) != -1
    return lib#ExtractRx(path, rx, '\1')
  endif

  return 0
endfunction
