" File: symfony.vim
" Author: Andrew Radev
" Description: Functions to use in symfony projects. Mostly helpful in
" commands to navigate across the project. All the functions assume the
" default directory structure of a symfony project.
" Last Modified: November 22, 2009

let s:PS = has('win32') ? '\\' : '/'
let s:capture_group = '\(.\{-}\)'
let s:anything = '.*'

function! symfony#CurrentModuleName()
  if exists('b:current_module_name')
    return b:current_module_name
  endif

  let rx = '^'

  let rx .= s:anything
  let rx .= 'modules'
  let rx .= s:PS
  let rx .= s:capture_group
  let rx .= s:PS

  let rx .= s:anything
  let rx .= '$'

  if match(expand('%:p'), rx) == -1
    throw 'Couldn''t find app name'
  endif

  let result = substitute(expand('%:p'), rx, '\1', '')

  return result
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
    throw 'Couldn''t find app name'
  endif

  let result = substitute(expand('%:p'), rx, '\1', '')

  return result
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
      throw 'Couldn''t find action' | return
    endif

    return substitute(path, rx, '\1', '')
  else " we're in an action
    let function_line = search('function', 'b')
    if function_line == 0
      throw 'Couldn''t find action' | return
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
        throw 'Couldn''t find action' | return
      endif

      let result = substitute(getline(function_line), rx, '\l\1', '')

      return result
    endif
  endif
endfunction

function! symfony#CurrentModelName()
  let rx = '^'

  let rx .= s:capture_group
	let rx .= '\(Table\|FormFilter\|Form\)\{,1}'

  let rx .= '\.class\.php'
  let rx .= '$'

  if match(expand('%:t'), rx) == -1
    throw 'Couldn''t find model name'
  endif

  let result = substitute(expand('%:t'), rx, '\1', '')

  return result
endfunction
