" TODO (2016-05-12) remove references to ember_tools#
" TODO (2016-05-12) remove references to lib#
" TODO (2016-05-12) remove references to rimplement#
" TODO (2016-05-09) Limit translation gf to translation under the cursor
" TODO (2016-05-09) Factory root?

let s:http_method_pattern = '\<\%(get\|post\|put\|delete\|patch\)\>'

augroup RailsExtra
  autocmd!
  autocmd User Rails
        \ if !exists('b:ember_root') |
        \   exe 'cmap <buffer><expr> <Plug><cfile> RailsExtraIncludeexpr()' |
        \ endif
augroup END

function! RailsExtraIncludeexpr()
  let callbacks = [
        \ 'RailsExtraGfTranslation',
        \ 'RailsExtraGfAsset',
        \ 'RailsExtraGfRoute',
        \ 'RailsExtraGfFactory',
        \ 'RailsExtraGfRspecMatcher',
        \ ]

  for callback in callbacks
    let filename = call(callback, [])

    if filename != '' && filereadable(filename)
      return filename
    endif
  endfor

  return rails#cfile('delegate')
endfunction

function! RailsExtraGfTranslation()
  let saved_iskeyword = &iskeyword

  set iskeyword+=.
  if !ember_tools#search#UnderCursor('\%(I18n\.\)\=t(\=\s*[''"]\zs\k\+[''"]')
    let &iskeyword = saved_iskeyword
    return ''
  endif

  let translation_key = expand('<cword>')
  let translations_file = fnamemodify('config/locales/en.yml', ':p')

  let callback_args = [translations_file]
  call extend(callback_args, split(translation_key, '\.'))
  call call('ember_tools#SetFileOpenCallback', callback_args)

  let &iskeyword = saved_iskeyword
  return translations_file
endfunction

function! RailsExtraGfAsset()
  let line = getline('.')

  let coffee_require_pattern = '#=\s*require \(\f\+\)\s*$'
  let scss_import_pattern    = '@import "\(.\{-}\)";'
  let stylesheet_pattern     = 'stylesheet ''\(.\{-}\)'''
  let javascript_pattern     = 'javascript ''\(.\{-}\)'''

  if expand('%:e') =~ 'coffee' && line =~ coffee_require_pattern
    let path = lib#ExtractRx(line, coffee_require_pattern, '\1')
    return s:FindRailsFile('app/assets/javascripts/'.path.'.*')
  elseif expand('%:e') =~ 'scss' && line =~ scss_import_pattern
    let path = lib#ExtractRx(line, scss_import_pattern, '\1')
    let file = s:FindRailsFile('app/assets/stylesheets/'.path.'.*')
    if file == ''
      let path = substitute(path, '.*/\zs\([^/]\{-}\)$', '_\1', '')
      let file = s:FindRailsFile('app/assets/stylesheets/'.path.'.*')
    endif
    return file
  elseif line =~ stylesheet_pattern
    let path = lib#ExtractRx(line, stylesheet_pattern, '\1')
    return s:FindRailsFile('app/assets/stylesheets/'.path.'.*')
  elseif line =~ javascript_pattern
    let path = lib#ExtractRx(line, javascript_pattern, '\1')
    return s:FindRailsFile('app/assets/javascripts/'.path.'.*')
  endif

  return ''
endfunction

function! RailsExtraGfRoute()
  if expand('%:p') !~ 'config/routes\.rb$'
    return
  endif

  let description = s:FindRouteDescription()
  if description == ''
    return
  endif

  if description !~ '^\k\+#\k\+$'
    echomsg "Description doesn't look like controller#action: ".description
    return
  endif

  let nesting = s:FindRouteNesting()
  if len(nesting) > 0
    let file_prefix = join(nesting, '/').'/'
    let module_prefix = join(map(nesting, 'rimplement#CapitalCamelCase(v:val)'), '::').'::'
  else
    let file_prefix = ''
    let module_prefix = ''
  endif

  let [controller, action] = split(description, '#')
  let filename = 'app/controllers/'.file_prefix.controller.'_controller.rb'

  if !filereadable(filename)
    return ''
  endif

  call ember_tools#SetFileOpenCallback(filename, 'def '.action)
  return filename
endfunction

function! RailsExtraGfFactory()
  if rimplement#SearchUnderCursor('\<\%(build\|create\|attributes_for\)[ (]:\zs\k\+') > 0
    let factory = expand('<cword>')
    return 'spec/factories/'.rails#pluralize(factory).'.rb'
  endif
  return ''
endfunction

function! RailsExtraGfRspecMatcher()
  let matcher = expand('<cword>')
  let matcher_filename = 'spec/support/matchers/'.matcher.'_matcher.rb'

  if filereadable(matcher_filename)
    return matcher_filename
  endif
  return ''
endfunction

" TODO (2016-05-12) Explicit "controller:" provided
function! s:FindRouteDescription()
  let action = 'index'

  if rimplement#SearchUnderCursor('resources :\zs\k\+') > 0
    let controller = expand('<cword>')
    let action = 'index'
  elseif rimplement#SearchUnderCursor('resource :\zs\k\+') > 0
    let controller = rails#pluralize(expand('<cword>'))
    let action = 'show'
  elseif rimplement#SearchUnderCursor(s:http_method_pattern.'\s\+:\zs\k\+') > 0 ||
        \ rimplement#SearchUnderCursor(s:http_method_pattern.'\s\+[''"]\zs\k\+\ze[''"]') > 0
    let action = expand('<cword>')
    if search('^\s*resources\= :\zs\k\+\ze\%(.*\) do$', 'b') < 0
      echomsg "Found the action '".action."', but can't find a containing resource."
      return ''
    endif
    let controller = expand('<cword>')
  elseif rimplement#SearchUnderCursor(s:http_method_pattern.'\s\+[''"]\zs\k\+/\k\+\ze[''"]') > 0
    let [controller, action] = split(expand('<cfile>'), '/')
  elseif rimplement#SearchUnderCursor('''[^'']\+''') > 0
    let controller = expand('<cfile>')
  elseif rimplement#SearchUnderCursor('"[^"]\+"') > 0
    let controller = expand('<cfile>')
  endif

  if controller =~ '^\k\+#\k\+$'
    " then it's a controller#action descriptor, let's split it for consistency
    let [controller, action] = split(controller, '#')
  endif

  let explicit_controller_pattern = 'controller\(:\| =>\)\s*[''"]\zs\k\+\ze[''"]'
  if getline('.') =~ explicit_controller_pattern
    " explicit controller specified, just use that
    let controller = matchstr(getline('.'), explicit_controller_pattern)
  endif

  return controller.'#'.action
endfunction

function! s:FindRouteNesting()
  " Find any parent routes
  let indent = indent('.')
  let route_path = []
  let namespace_pattern = 'namespace :\zs\k\+'

  while search('^ \{,'.(indent - &sw).'}'.namespace_pattern, 'bW')
    let route = expand('<cword>')
    call insert(route_path, route, 0)
    let indent = indent('.')
  endwhile

  return route_path
endfunction

function! s:FindRailsFile(pattern)
  let matches = glob(getcwd().'/'.a:pattern, 0, 1)
  if !empty(matches)
    return matches[0]
  else
    return ''
  endif
endfunction

command! Eroutes edit config/routes.rb
command! -nargs=* -complete=custom,s:CompleteRailsModels Eschema call s:Eschema(<q-args>)
command! -nargs=1 -complete=custom,s:CompleteRailsModels Emodel call s:Emodel(<q-args>)

function! s:Emodel(model_name)
  let model_name = rails#singularize(rails#underscore(a:model_name))
  exe 'edit app/models/'.model_name.'.rb'
endfunction

function! s:Eschema(model_name)
  let model_name = rails#singularize(rails#underscore(a:model_name))

  if model_name == ''
    let model_name = s:CurrentModelName()
  endif

  edit db/schema.rb

  if model_name != ''
    let table_name = rails#pluralize(rails#underscore(model_name))
    call search('create_table "'.table_name.'"')
  endif
endfunction

function! s:CurrentModelName()
  let current_file = expand('%:p')

  if current_file =~ 'app/models/.*\.rb$'
    let filename = expand('%:t:r')
    return lib#CapitalCamelCase(filename)
  else
    return ''
  endif
endfunction

function! s:CompleteRailsModels(A, L, P)
  let names = []
  for file in split(glob('app/models/**/*.rb'), "\n")
    let name = fnamemodify(file, ':t:r')
    call add(names, name)
  endfor
  return join(names, "\n")
endfunction
