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

command! -nargs=* Econtroller call Econtroller(<f-args>)
function! Econtroller(...)
  if (a:0 == 2) " Then we're given an app and a controller
    let b:current_app_name    = a:1
    let b:current_module_name = a:2
  elseif (a:0 == 1) " Then we're given just a controller
    let b:current_module_name = a:1
  endif

  let function_name = 'execute'.lib#Capitalize(symfony#CurrentActionName())

  exe
        \ 'edit apps/'.
        \ symfony#CurrentAppName().
        \ '/modules/'.
        \ symfony#CurrentModuleName().
        \ '/actions/actions.class.php'
  call search(function_name, 'cw')
endfunction
