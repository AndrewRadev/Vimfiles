" File: symfony.vim
" Author: Andrew Radev
" Description: Functions to use in symfony projects. Mostly helpful in
" commands to navigate across the project. All the functions assume the
" default directory structure of a symfony project.
" Last Modified: December 12, 2009

let s:PS = has('win32') ? '\\' : '/'
let s:capture_group = '\(.\{-}\)'
let s:anything = '.*'

function! symfony#LoadData()
  let g:app_dict    = {}
  let g:module_dict = {}
  let g:model_dict  = {}

  " Regular expression for apps and modules:
  let rx = '^'
  let rx .= s:anything
  let rx .= s:PS
  let rx .= s:capture_group
  let rx .= '$'

  for path in split(glob('apps/*'))
    let app = substitute(path, rx, '\1', '')
    let g:app_dict[app] = 1
  endfor

  for path in split(glob('apps/*/modules/*'))
    let module = substitute(path, rx, '\1', '')
    let g:module_dict[module] = 1
  endfor

  " Regular expression for models:
  let rx = '^'
  let rx .= s:anything
  let rx .= s:PS
  let rx .= s:capture_group
  let rx .= 'Table\.class\.php'
  let rx .= '$'

  for path in split(glob('lib/model/doctrine/*Table.class.php'))
    let model = substitute(path, rx, '\1', '')
    let g:model_dict[model] = 1
  endfor
endfunction

function! symfony#CurrentModuleName()
  if exists('b:current_module_name')
    return b:current_module_name
  endif
  let path = expand('%:p')

  let rx = '^'

  let rx .= s:anything
  let rx .= 'modules'
  let rx .= s:PS
  let rx .= s:capture_group
  let rx .= s:PS

  let rx .= s:anything
  let rx .= '$'

  if match(path, rx) == -1
    let b:current_module_name = input("Enter module name: ", "", "customlist,symfony#CompleteModule")
  else
    let b:current_module_name = substitute(path, rx, '\1', '')
  endif
  let g:module_dict[b:current_module_name] = 1

  return b:current_module_name
endfunction

function! symfony#CurrentAppName()
  if exists('b:current_app_name')
    return b:current_app_name
  endif

  let rx = '^'

  let rx .= s:anything
  let rx .= 'apps'
  let rx .= s:PS
  let rx .= s:capture_group
  let rx .= s:PS

  let rx .= s:anything
  let rx .= '$'

  if match(expand('%:p'), rx) == -1
    let b:current_app_name = input("Enter app name: ", "", "customlist,symfony#CompleteApp")
  else
    let b:current_app_name = substitute(expand('%:p'), rx, '\1', '')
  endif
  let g:app_dict[b:current_app_name] = 1

  return b:current_app_name
endfunction

function! symfony#CurrentActionName()
  let path = expand('%:p')

  if path =~# 'templates' " we're in a view
    let rx = '^'

    let rx .= s:anything
    let rx .= s:PS
    let rx .= 'templates'
    let rx .= s:PS
    let rx .= s:capture_group
    let rx .= 'Success\.php'

    let rx .= s:anything
    let rx .= '$'

    if match(path, rx) == -1
      return 'index' " A default value
    endif

    return substitute(path, rx, '\1', '')
  else " we're in an action
    let function_line = search('function', 'b')
    if function_line == 0
      return 'index' " A default value
    else
      let rx = '^'

      let rx .= s:anything
      let rx .= 'function'
      let rx .= '\s\+'
      let rx .= 'execute'
      let rx .= s:capture_group
      let rx .= '\s*'
      let rx .= '('

      let rx .= s:anything
      let rx .= '$'

      if match(getline(function_line), rx) == -1
        return 'index' " A default value
      endif

      let result = substitute(getline(function_line), rx, '\l\1', '')

      return result
    endif
  endif
endfunction

function! symfony#CurrentModelName()
  let path = expand('%:p')
  let rx = '^'

  let rx .= s:anything
  let rx .= 'lib'
  let rx .= s:PS
  let rx .= s:anything
  let rx .= s:PS
  let rx .= 'doctrine'
  let rx .= s:PS

  let rx .= s:capture_group
	let rx .= '\(Table\|FormFilter\|Form\)\{,1}'

  let rx .= '\.class\.php'
  let rx .= '$'

  if match(path, rx) == -1
    let b:current_model_name = input("Enter model name: ", "", "customlist,symfony#CompleteModel")
  else
    let b:current_model_name = substitute(path, rx, '\1', '')
  endif
  let g:model_dict[b:current_model_name] = 1

  return b:current_model_name
endfunction

function! symfony#CompleteApp(A, L, P)
  return keys(filter(copy(g:app_dict), "v:key =~'^".a:A."'"))
endfunction

function! symfony#CompleteModule(A, L, P)
  return keys(filter(copy(g:module_dict), "v:key =~'^".a:A."'"))
endfunction

function! symfony#CompleteModel(A, L, P)
  return keys(filter(copy(g:model_dict), "v:key =~'^".a:A."'"))
endfunction
