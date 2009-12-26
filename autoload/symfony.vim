" File: symfony.vim
" Author: Andrew Radev
" Description: Functions to use in symfony projects. Mostly helpful in
" commands to navigate across the project. All the functions assume the
" default directory structure of a symfony project.
" Last Modified: December 25, 2009

let s:PS = has('win32') ? '\\' : '/'
let s:capture_group = '\(.\{-}\)'
let s:anything = '.*'

function! symfony#LoadData()
  let g:app_dict     = {}
  let g:module_dict  = {}
  let g:model_dict   = {}
  let g:schema_dict  = {}
  let g:fixture_dict = {}

  " Regular expression for apps and modules:
  let rx = s:PS
  let rx .= s:capture_group
  let rx .= '$'

  for path in split(glob('apps/*'))
    let app = lib#ExtractRx(path, rx, '\1')
    let g:app_dict[app] = 1
  endfor

  for path in split(glob('apps/*/modules/*'))
    let module = lib#ExtractRx(path, rx, '\1')
    let g:module_dict[module] = 1
  endfor

  " Regular expression for models:
  let rx = s:PS
  let rx .= s:capture_group
  let rx .= 'Table\.class\.php'
  let rx .= '$'

  for path in split(glob('lib/model/doctrine/*Table.class.php'))
    let model = lib#ExtractRx(path, rx, '\1')
    let g:model_dict[model] = 1
  endfor

  " Regular expression for schema files:
  let rx = s:PS.s:capture_group.'_schema.yml$'

  for path in split(glob('config/doctrine/*_schema.yml'))
    let schema = lib#ExtractRx(path, rx, '\1')
    let g:schema_dict[schema] = 1
  endfor

  " Regular expression for fixtures:
  let rx = s:PS.s:capture_group.'$'

  for path in split(glob('data/fixtures/*.yml'))
    let fixture = lib#ExtractRx(path, rx, '\1')
    let fixture_key = lib#ExtractRx(fixture, '^\d\+_'.s:capture_group.'\.yml$', '\1')
    let g:fixture_dict[fixture_key] = fixture
  endfor
endfunction

function! symfony#CurrentModuleName()
  if exists('b:current_module_name')
    return b:current_module_name
  endif
  let path = expand('%:p')

  let rx = 'modules'
  let rx .= s:PS
  let rx .= s:capture_group
  let rx .= s:PS

  if match(path, rx) == -1
    let b:current_module_name = input("Enter module name: ", "", "customlist,symfony#CompleteModule")
  else
    let b:current_module_name = lib#ExtractRx(path, rx, '\1')
  endif
  let g:module_dict[b:current_module_name] = 1

  return b:current_module_name
endfunction

function! symfony#CurrentAppName()
  if exists('b:current_app_name')
    return b:current_app_name
  endif

  let rx = 'apps'
  let rx .= s:PS
  let rx .= s:capture_group
  let rx .= s:PS

  if match(expand('%:p'), rx) == -1
    let b:current_app_name = input("Enter app name: ", "", "customlist,symfony#CompleteApp")
  else
    let b:current_app_name = lib#ExtractRx(expand('%:p'), rx, '\1')
  endif
  let g:app_dict[b:current_app_name] = 1

  return b:current_app_name
endfunction

function! symfony#CurrentActionName()
  let path = expand('%:p')

  if path =~# 'templates' " we're in a view or a component
    let rx = s:PS
    let rx .= 'templates'
    let rx .= s:PS

    if path =~# 'Success\..*php$' " then it's a view
      let rx .= s:capture_group.'Success\..*php$'
    else
      let rx .= '_'.s:capture_group.'\..*php$'
    endif

    if match(path, rx) == -1
      return 'index' " A default value
    endif

    return lib#ExtractRx(path, rx, '\1')
  else " we're in an action
    let function_line = search('function', 'b')
    if function_line == 0
      return 'index' " A default value
    else
      let rx = 'function'
      let rx .= '\s\+'
      let rx .= 'execute'
      let rx .= s:capture_group
      let rx .= '\s*'
      let rx .= '('

      if match(getline(function_line), rx) == -1
        return 'index' " A default value
      endif

      let result = lib#ExtractRx(getline(function_line), rx, '\l\1')

      return result
    endif
  endif
endfunction

function! symfony#CurrentModelName()
  let path = expand('%:p')

  let rx = 'lib'
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
    let b:current_model_name = lib#ExtractRx(path, rx, '\1')
  endif
  let g:model_dict[b:current_model_name] = 1

  return b:current_model_name
endfunction

function! symfony#CompleteApp(A, L, P)
  return sort(keys(filter(copy(g:app_dict), "v:key =~'^".a:A."'")))
endfunction

function! symfony#CompleteModule(A, L, P)
  return sort(keys(filter(copy(g:module_dict), "v:key =~'^".a:A."'")))
endfunction

function! symfony#CompleteModel(A, L, P)
  return sort(keys(filter(copy(g:model_dict), "v:key =~'^".a:A."'")))
endfunction

function! symfony#CompleteSchema(A, L, P)
  return sort(keys(filter(copy(g:schema_dict), "v:key =~'^".a:A."'")))
endfunction

function! symfony#CompleteFixture(A, L, P)
  return sort(keys(filter(copy(g:fixture_dict), "v:key =~'^".a:A."'")))
endfunction
