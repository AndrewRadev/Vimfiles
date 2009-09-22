" vim IDE for the symfony PHP framework. Provides easy browsing between symfony modules. 
" Last Change:  28.05 2008
" Maintainer:   Nicolas MARTIN <email.de.nicolas.martin at gmail dot com>

function! ReconfigPaths()
  let file = expand('%:p')
  "if ( matchstr(file, '^apps') != '' )
    "let  g:sf_app_name = substitute(file, '.*apps\(/\|\\\)\(.\{-}\)\\.*', '\1', 'g')
    "let  g:sf_module_name = substitute(file, '.*modules\(/\|\\\)\(.\{-}\)\\.*', '\1', 'g')
    let g:sf_app_name = substitute(file, '.*apps\(/\|\\\)\(.\{-\}\)\(/\|\\\).*', '\2', 'g')
    let g:sf_module_name = substitute(file, '.*modules\(/\|\\\)\(.\{-\}\)\(/\|\\\).*', '\2', 'g')
  "endif

  if (exists("g:sf_root_dir"))
  call SetAppConfig()
  call SetModuleConfig()
  endif
endfunction

function! SetProjectConfig()
  let g:sf_config          = g:sf_root_dir . 'config/'
  let g:sf_batch           = g:sf_root_dir . 'batch/'
  let g:sf_lib             = g:sf_root_dir . 'lib/'
  let g:sf_lib_model       = g:sf_root_dir . 'lib/model/'
  let g:sf_model           = g:sf_config . 'schema.xml'
  let g:sf_data            = g:sf_root_dir . 'data/'
endfunction

function! SetAppConfig()
  let g:sf_app             = g:sf_root_dir . 'apps/' . g:sf_app_name . '/'
  let g:sf_app_templates   = g:sf_app . 'templates/'
  let g:sf_app_modules     = g:sf_app . 'modules/'
  let g:sf_app_config      = g:sf_app . 'config/'
endfunction

function! SetModuleConfig()
  let g:sf_module            = g:sf_app_modules . g:sf_module_name .'/'
  let g:sf_module_actions    = g:sf_module . 'actions/actions.class.php'
  let g:sf_module_components = g:sf_module . 'actions/components.class.php'
  let g:sf_module_templates  = g:sf_module . 'templates/'
  let g:sf_module_config     = g:sf_module . 'config/'
  let g:sf_module_lib        = g:sf_module . 'lib/'
endfunction

" find the corresponding template file of the current function surrounding the cursor
function! FindCurrentAction()
  call cursor(line('.')+1, 0, 0)
  let lineno               = search('public function\ \(.*\)(.*)', 'nbe')
  let action               = matchstr(getline(lineno), '\zsexecute\(.*\)\ze(.*)')
  call cursor(line('.')-1, 0, 0)
  if (action != '')
    "let template_file_name   = tolower(action)."Success.php"
    "return template_file_name
    return action
  else 
    return ''
  endif
endfunction

function! FindCurrentFileName()
  return GetFileName(expand('%'))
endfunction

" find the corresponding action file and function of a template
function! GetFileName(file)
  let current_template_name   = matchstr(a:file, '.\+\\\zs.*\ze')
  if (current_template_name != "")
    return current_template_name
  else 
    return ''
  endif
endfunction


" executeIndex => index
function! GetActionNameFromAction(action_name)
  let first_letter = matchstr(a:action_name, '\U\+\zs\u\ze.*')
  let remains      = matchstr(a:action_name, '\U\+\u\zs.*')
  return tolower(first_letter) . remains
endfunction

" indexSuccess.php => index
function! GetActionNameFromActionFileName(action_file_name)
  return matchstr(a:action_file_name, '\zs\U*\ze\u.*Success')
endfunction

" _index.php => index
function! GetComponentNameFromComponentFileName(component_file_name)
  return matchstr(a:component_file_name, '_\zs.*\ze\.')
endfunction


" index => indexSuccess.php
function! GetSuccessTemplateFromAction(action_name)
  return GetActionNameFromAction(a:action_name)."Success.php"
endfunction

" index => _index.php
function! GetSuccessTemplateFromComponent(component_name)
  return "_".GetActionNameFromAction(a:component_name.".php")
endfunction

" index => executeIndex
function! GetExecuteActionNameFromAction(action_name)
  return 'execute' . substitute(a:action_name, '^\(.\?\)', '\u\1\E', "g")
endfunction

function! ImAmInAModule() 
  if (matchstr(expand('%:p'), 'apps\(/\|\\\).\{-}\(/\|\\\)modules\(/\|\\\).\{-}\(/\|\\\)') != '')
    return 1
  else 
    return ''
  endif
endfunction

function! ImAmInAnAction() 
  if (matchstr(expand('%:p'), 'apps\(/\|\\\).\{-}\(/\|\\\)modules\(/\|\\\).\{-}\(/\|\\\)actions\(/\|\\\)actions.class.php') != '')
    return 1
  else 
    return ''
  endif
endfunction

function! ImAmInAComponent() 
  if (matchstr(expand('%:p'), 'apps\(/\|\\\).\{-}\(/\|\\\)modules\(/\|\\\).\{-}\(/\|\\\)actions\(/\|\\\)components.class.php') != '')
    return 1
  else 
    return ''
  endif
endfunction

function! ImAmInAComponentTemplate()
  if (matchstr(expand('%:p'), 'apps\(/\|\\\).\{-}\(/\|\\\)modules\(/\|\\\).\{-}\(/\|\\\)templates\(/\|\\\)_.\{-}.php') != '')
    return 1
  else 
    return ''
  endif
endfunction
  
function! ImAmInAnActionTemplate()
endif

endfunction

function! g:EchoError(msg)
    echohl errormsg
    echo a:msg
    echohl normal
endfunction

" switch from the template file to the corresponding function code of the action 
" and from the action to the corresponding template
function! Switch()
  
  if (!exists("g:sf_root_dir"))
    call SfPluginLoad(getcwd())
  endif
    
  if (ImAmInAModule())

    if (FindCurrentAction() != '') 

      " we are in an action file so let's go the success template file

      let g:last_action_line = getpos('.')
      
      if (ImAmInAnAction())
        if (g:last_template_line != [])
          exec 'edit ' . g:sf_module_templates.GetSuccessTemplateFromAction(FindCurrentAction())
          call cursor(g:last_template_line[1], g:last_template_line[2], 0)
        else
          exec 'edit ' . g:sf_module_templates.GetSuccessTemplateFromAction(FindCurrentAction())
        endif
      elseif (ImAmInAComponent())
        if (g:last_template_line != [])
          exec 'edit ' . g:sf_module_templates.GetSuccessTemplateFromComponent(FindCurrentAction())
          call cursor(g:last_template_line[1], g:last_template_line[2], 0)
        else
          exec 'edit ' . g:sf_module_templates.GetSuccessTemplateFromComponent(FindCurrentAction())
        endif
      endif

      let g:last_template_line = []

    else
      " we are in a template  so let's go the current module action/function
      
      let g:last_template_line = getpos('.')

      if (ImAmInAComponentTemplate())
        if (g:last_action_line != [])
          exec 'edit ' . g:sf_module_components
          call cursor(g:last_action_line[1], g:last_action_line[2], 0)
        else
          exec 'edit +/' . GetExecuteActionNameFromAction(GetComponentNameFromComponentFileName(FindCurrentFileName())) .  ' ' . g:sf_module_components
        endif
      else
        if (g:last_action_line != [])
          exec 'edit ' . g:sf_module_actions 
          call cursor(g:last_action_line[1], g:last_action_line[2], 0)
        else
          exec 'edit +/' . GetExecuteActionNameFromAction(GetActionNameFromActionFileName(FindCurrentFileName())) .  ' ' . g:sf_module_actions 
        endif
      endif
      

      let g:last_action_line = []

      " jump to the last line of the function
      "call cursor(search('}')-1, 100, 0)
    endif

  else 
    call g:EchoError("Not in a symfony module context, unable to switch view")
    return 0
  endif

endfunction


""""""""""""""""""""""""""""
" map <F8> :SfSwitchView <CR>

command! -n=? -complete=dir SfSwitchView :call Switch()
command! -nargs=1 -complete=dir SfPluginLoad :call SfPluginLoad(<args>)


let g:sf_app_name      = ""
let g:sf_module_name   = "" 

let g:last_template_line = []
let g:last_action_line = []

autocmd BufEnter,BufLeave,BufWipeout * call SfPluginLoad(getcwd())  " Automatically reload .vimrc when changing

function! SfPluginLoad(path)
  if ( finddir('apps', a:path) != '') "&& (finddir('config', a:path) != '') && (finddir('lib', a:path) != '') && (finddir('web', a:path) != '')
    let g:sf_root_dir = a:path.'/'
    exec(':cd '.g:sf_root_dir)
    call ReconfigPaths()
  endif

  if exists("g:sf_root_dir")
    :call SetProjectConfig()
    :call SetAppConfig()
    :call SetModuleConfig()
  endif
endfunction
