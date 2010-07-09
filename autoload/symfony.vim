" File: symfony.vim
" Author: Andrew Radev
" Description: Functions to use in symfony projects. Mostly helpful in
" commands to navigate across the project. All the functions assume the
" default directory structure of a symfony project with the exception of the
" possibility to configure the web dir via `g:sf_web_dir`
" Last Modified: July 09, 2010

let s:PS            = has('win32') ? '\\' : '/'
let s:capture_group = '\(.\{-}\)'
let s:anything      = '.*'

if !exists('g:sf_web_dir')
  let g:sf_web_dir = 'web'
endif

function! symfony#LoadData()
  let g:sf_fixture_dict = {}
  let g:sf_js_dict      = {}
  let g:sf_css_dict     = {}

  " Fixtures:
  let rx = s:PS.s:capture_group.'$'

  for path in split(glob('data/fixtures/*.yml'))
    let fixture     = lib#ExtractRx(path, rx, '\1')
    let fixture_key = lib#ExtractRx(fixture, '^\d\+_'.s:capture_group.'\.yml$', '\1')
    let g:sf_fixture_dict[fixture_key] = fixture
  endfor

  " Javascript files:
  for path in split(glob(g:sf_web_dir.'/js/**/*.js'))
    let fname = substitute(path, lib#RxPath(g:sf_web_dir, 'js').s:PS.s:capture_group.'.js', '\1', '')
    let g:sf_js_dict[fname] = 1
  endfor

  " CSS files:
  for path in split(glob(g:sf_web_dir.'/css/**/*.css'))
    let fname = substitute(path, lib#RxPath(g:sf_web_dir, 'css').s:PS.s:capture_group.'.css', '\1', '')
    let g:sf_css_dict[fname] = 1
  endfor
endfunction

" Property retrieval functions
function! symfony#CurrentModuleName()
  if exists('b:current_module_name')
    return b:current_module_name
  endif

  let path = expand('%:p')

  if path =~# 'test'.s:PS.'functional' " we're in a functional test
    let rx = lib#RxPath('test', 'functional', s:anything, s:capture_group)
    let rx .= 'ActionsTest\.php$'
  else " we're somewhere in a specific application
    let rx = lib#RxPath('modules', s:capture_group)
    let rx .= s:PS
  endif

  if match(path, rx) == -1
    let b:current_module_name = input("Enter module name: ", "", "customlist,symfony#CompleteModule")
  else
    let b:current_module_name = lib#ExtractRx(path, rx, '\1')
  endif

  return b:current_module_name
endfunction

function! symfony#CurrentAppName()
  if exists('b:current_app_name')
    return b:current_app_name
  endif

  let path = expand('%:p')

  if path =~# 'test'.s:PS.'functional' " we're in a functional test
    let rx = lib#RxPath('test', 'functional', s:capture_group)
    let rx .= s:PS
  else " we're somewhere in a specific application
    let rx = lib#RxPath('apps', s:capture_group).s:PS
  endif

  if match(expand('%:p'), rx) == -1
    let b:current_app_name = input("Enter app name: ", "", "customlist,symfony#CompleteApp")
  else
    let b:current_app_name = lib#ExtractRx(expand('%:p'), rx, '\1')
  endif

  return b:current_app_name
endfunction

function! symfony#CurrentActionName()
  let path = expand('%:p')

  if path =~# 'templates' " we're in a view or a component
    let rx = lib#Wrap(s:PS, 'templates')

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

  if match(path, 'test'.s:PS.'unit') != -1 " Then we're in a unit test
    let b:current_model_name = lib#Capitalize(lib#ExtractRx(path, s:PS.s:capture_group.'Test.php$', '\1'))
    return b:current_model_name
  endif

  let rx = lib#RxPath('lib', s:anything, 'doctrine', s:capture_group)
	let rx .= '\(Table\|FormFilter\|Form\)\{,1}'
  let rx .= '\.class\.php'
  let rx .= '$'

  if match(path, rx) == -1
    let b:current_model_name = lib#Capitalize(input("Enter model name: ", "", "customlist,symfony#CompleteModel"))
  else
    let b:current_model_name = lib#ExtractRx(path, rx, '\1')
  endif

  return b:current_model_name
endfunction

" Path functions
function! symfony#TablePath(table)
  let paths = glob('lib/model/**/'.a:table.'Table.class.php')
  if paths != ''
    return paths
  else
    return 'lib/model/doctrine/'.a:table.'Table.class.php'
  endif
endfunction

function symfony#ParsePartialPath(path)
  let match = split(a:path, '/')
  if len(match) == 2
    let [module, template] = match
  else
    let module   = symfony#CurrentModuleName()
    let template = match[0]
  endif

  return [module, template]
endfunction

function! symfony#TemplatePath(module, template)
  let app = symfony#CurrentAppName()

  if a:template[0] == '_'
    let template = a:template.'.php'
  else
    let template = a:template.'Success.php'
  endif

  if a:module == 'global'
    let path = 'apps/'.app.'/templates/'.template
  else
    let path = 'apps/'.app.'/modules/'.a:module.'/templates/'.template
  endif

  return path
endfunction

" Completion functions
function! symfony#CompleteApp(A, L, P)
  let rx = s:PS.s:capture_group.'$'

  let app_dict = {}
  for path in split(glob('apps/*'))
    let app = lib#ExtractRx(path, rx, '\1')
    let app_dict[app] = 1
  endfor

  return sort(keys(filter(app_dict, "v:key =~'^".a:A."'")))
endfunction

function! symfony#CompleteModule(A, L, P)
  let rx = s:PS.s:capture_group.'$'

	if len(split(substitute(a:L, a:A.'$', '', ''))) == 2
    let app_dict = {}
    for path in split(glob('apps/*'))
      let app = lib#ExtractRx(path, rx, '\1')
      let app_dict[app] = 1
    endfor

		return sort(keys(filter(copy(app_dict), "v:key =~'^".a:A."'")))
	else
    let module_dict = {}
    for path in split(glob('apps/*/modules/*'))
      let module = lib#ExtractRx(path, rx, '\1')
      let module_dict[module] = 1
    endfor

		return sort(keys(filter(module_dict, "v:key =~'^".a:A."'")))
	endif
endfunction

function! symfony#CompleteModel(A, L, P)
  let rx = s:PS
  let rx .= s:capture_group
  let rx .= 'Table\.class\.php'
  let rx .= '$'

  let model_dict = {}
  for path in split(glob('lib/model/doctrine/*Table.class.php'))
    let model = lib#ExtractRx(path, rx, '\1')
    let model_dict[model] = 1
  endfor

  return sort(keys(filter(model_dict, "v:key =~'^".a:A."'")))
endfunction

function! symfony#CompleteUnitTest(A, L, P)
  return symfony#CompleteModel(a:A, a:L, a:P)
endfunction

function! symfony#CompleteSchema(A, L, P)
  let rx = s:PS.s:capture_group.'_schema.yml$'

  let schema_dict = {}
  for path in split(glob('config/doctrine/*_schema.yml'))
    let schema = lib#ExtractRx(path, rx, '\1')
    let schema_dict[schema] = 1
  endfor

  return sort(keys(filter(schema_dict, "v:key =~'^".a:A."'")))
endfunction

function! symfony#CompleteFixture(A, L, P)
  return sort(keys(filter(copy(g:sf_fixture_dict), "v:key =~'^".a:A."'")))
endfunction

function! symfony#CompleteJs(A, L, P)
  return sort(keys(filter(copy(g:sf_js_dict), "v:key =~'^".a:A."'")))
endfunction

function! symfony#CompleteCss(A, L, P)
  return sort(keys(filter(copy(g:sf_css_dict), "v:key =~'^".a:A."'")))
endfunction

function! symfony#CompleteConfig(A, L, P)
  let rx = s:PS.s:capture_group.'\.yml$'

  let config_dict = {}
  for path in split(glob('apps/*/config/*.yml'))
    let config = lib#ExtractRx(path, rx, '\1')
    let config_dict[config] = 1
  endfor

  return sort(keys(filter(config_dict, "v:key =~'^".a:A."'")))
endfunction
