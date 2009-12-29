call symfony#LoadData()

command! -nargs=? -complete=customlist,symfony#CompleteJs Ejavascript call Ejavascript(<f-args>)
function! Ejavascript(...)
  if a:0 == 1 " Then we're given a filename
    let fname = fnamemodify(a:1, ':r').'.js'
    exe "edit ".fname
  else
    exe
          \ 'edit web/js/'.
          \ symfony#CurrentAppName().
          \ '/'.
          \ symfony#CurrentModuleName().'.js'
  endif
endfunction

command! Estylesheet exe
      \ 'edit web/css/'.
      \ symfony#CurrentAppName().
      \ '/'.
      \ symfony#CurrentModuleName().'.css'

command! -nargs=? Eview call Eview(<f-args>)
function! Eview(...)
  if expand('%:t') == 'actions.class.php'
    let filename = symfony#CurrentActionName().'Success.php'
  else " it's a component
    let filename = '_'.symfony#CurrentActionName().'.php'
  endif

  if a:0 == 1 " Then we're given a format specifier:
    let format = a:1
    let filename = fnamemodify(filename, ':r').'.'.format.'.php'
  endif

  exe
      \ 'edit apps/'.
      \ symfony#CurrentAppName().
      \ '/modules/'.
      \ symfony#CurrentModuleName().
      \ '/templates/'.
      \ filename
endfunction

command! -nargs=* -complete=customlist,symfony#CompleteModule Econtroller call Econtroller('action', <f-args>)
command! -nargs=* -complete=customlist,symfony#CompleteModule Ecomponent  call Econtroller('component', <f-args>)
function! Econtroller(type, ...)
  if (a:0 == 1) " Then we're given a controller
    let b:current_module_name = a:1
    let g:module_dict[b:current_module_name] = 1 " Add to completion
  elseif (a:0 == 2) " Then we're given a controller and an app
    let b:current_module_name = a:1
    let b:current_app_name = a:2
    let g:module_dict[b:current_module_name] = 1 " Add to completion
    let g:app_dict[b:current_app_name] = 1 " Add to completion
  endif

  let function_name = 'execute'.lib#Capitalize(symfony#CurrentActionName())

  exe
        \ 'edit apps/'.
        \ symfony#CurrentAppName().
        \ '/modules/'.
        \ symfony#CurrentModuleName().
        \ '/actions/'.a:type.'s.class.php'
  call cursor(0, 0)
  call search(function_name, 'cw')
endfunction
function! Ecomponent(...)
  if (a:0 == 1) " Then we're given a component
    let b:current_module_name = a:1
    let g:module_dict[b:current_module_name] = 1 " Add to completion
  endif

  let function_name = 'execute'.lib#Capitalize(symfony#CurrentActionName())

  exe
        \ 'edit apps/'.
        \ symfony#CurrentAppName().
        \ '/modules/'.
        \ symfony#CurrentModuleName().
        \ '/actions/components.class.php'
  call cursor(0, 0)
  call search(function_name, 'cw')
endfunction

command! -nargs=? -complete=customlist,symfony#CompleteModel Emodel  call Elib('model',  '',           <f-args>)
command! -nargs=? -complete=customlist,symfony#CompleteModel Etable  call Elib('model',  'Table',      <f-args>)
command! -nargs=? -complete=customlist,symfony#CompleteModel Eform   call Elib('form',   'Form',       <f-args>)
command! -nargs=? -complete=customlist,symfony#CompleteModel Efilter call Elib('filter', 'FormFilter', <f-args>)
function! Elib(dir, suffix, ...)
  if a:0 == 0
    let b:model_name = symfony#CurrentModelName()
  else
    let b:model_name = a:1
  endif

  exe
        \ "edit lib/".
        \ a:dir.
        \ "/doctrine/".
        \ b:model_name.
        \ a:suffix.
        \ ".class.php"
endfunction

command! -nargs=? -complete=customlist,symfony#CompleteTest Etest call Etest(<f-args>)
function! Etest(...)
  if a:0 == 1 " Then we're given a test name
    exe "edit test/unit/".lib#Lowercase(a:1)."Test.php"
  else " Edit a test according to current model name
    exe "edit test/unit/".lib#Lowercase(symfony#CurrentModelName())."Test.php"
  endif
endfunction

command! -nargs=? -complete=customlist,symfony#CompleteSchema Eschema call Eschema(<f-args>)
function! Eschema(...)
  if a:0 == 1 " Then we're given a prefix for the schema file
    let prefix = a:1.'_'
  else
    let prefix = ''
  endif

  exe "edit config/doctrine/".prefix."schema.yml"
endfunction

command! -nargs=1 -complete=customlist,symfony#CompleteFixture Efixture call Efixture(<f-args>)
function! Efixture(name)
  if exists('g:fixture_dict[a:name]')
    let fixture = g:fixture_dict[a:name]
  else
    let fixture = a:name
  endif

  exe 'edit data/fixtures/'.fixture
endfunction

command! -nargs=? -complete=customlist,symfony#CompleteApp Erouting call Erouting(<f-args>)
function! Erouting(...)
  if a:0 == 1
    let b:current_app_name = a:1
    let g:app_dict[b:current_app_name] = 1
  endif

  exe
      \ 'edit apps/'.
      \ symfony#CurrentAppName().
      \ '/config/routing.yml'
endfunction
