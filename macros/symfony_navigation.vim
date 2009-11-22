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

" TODO:
command! Econtroller exe
      \ 'edit apps/'.
      \ symfony#CurrentAppName().
      \ '/modules/'.
      \ symfony#CurrentModuleName().
      \ '/actions/actions.class.php' |
      \ call search('execute'.lib#Capitalize(symfony#CurrentActionName()), 'cw')
