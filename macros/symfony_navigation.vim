command! Ejavascript exe "edit web/js/".CurrentAppName()."/".CurrentModuleName().".js"

function! CurrentModuleName()
  return substitute(expand('%:p'), '^.*[/\\]modules[/\\]\(.\{-}\)/.*$', '\1', '')
endfunction

function! CurrentAppName()
  return substitute(expand('%:p'), '^.*[/\\]apps[/\\]\(.\{-}\)/.*$', '\1', '')
endfunction
