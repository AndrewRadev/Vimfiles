call symfony#LoadData()

command! Ejavascript exe
      \ 'edit web/js/'.
      \ symfony#CurrentAppName().
      \ '/'.
      \ symfony#CurrentModuleName().'.js'

command! Estylesheet exe
      \ 'edit web/css/'.
      \ symfony#CurrentAppName().
      \ '/'.
      \ symfony#CurrentModuleName().'.css'

command! Eview exe
      \ 'edit apps/'.
      \ symfony#CurrentAppName().
      \ '/modules/'.
      \ symfony#CurrentModuleName().
      \ '/templates/'.
      \ symfony#CurrentActionName().'Success.php'

command! -nargs=* -complete=customlist,symfony#CompleteModule Econtroller call Econtroller(<f-args>)
function! Econtroller(...)
  if (a:0 == 1) " Then we're given a controller
    let b:current_module_name = a:1
    let g:module_dict[b:current_module_name] = 1
  endif

  let function_name = 'execute'.lib#Capitalize(symfony#CurrentActionName())

  exe
        \ 'edit apps/'.
        \ symfony#CurrentAppName().
        \ '/modules/'.
        \ symfony#CurrentModuleName().
        \ '/actions/actions.class.php'
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

command! -nargs=* Eschema call Eschema(<f-args>)
function! Eschema(...)
  if a:0 == 1 " Then we're given a prefix for the schema file
    let prefix = a:1.'_'
  else
    let prefix = ''
  endif

  exe "edit config/doctrine/".prefix."schema.yml"
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
