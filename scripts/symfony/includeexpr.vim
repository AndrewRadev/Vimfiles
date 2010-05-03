function! SymfonyIncludeExpr(fname)
  " TODO possibly check for module named 'global'
  let quoted_capture = '\s*[''"]\(.\{-}\)[''"]\s*'
  let line = getline('.')

  let partial_patterns = [
        \ 'include_partial(',
        \ 'this->renderPartial(',
        \ 'this->getPartial(',
        \ 'get_partial(',
        \ ]

  for p in partial_patterns
    if s:InString(line, p) " Follow a partial include:
      let rx = p
      let rx .= quoted_capture
      let rx .= '[\s,)]' " Might end with different things

      let match = split(s:ExtractRx(line, rx, '\1'), '/')
      if len(match) == 2
        let [module, template] = match
        if module == 'global'
          let module_path = ''
        else
          let module_path = '/modules/'.module
        endif
      else
        let module_path = '/modules/'.symfony#CurrentModuleName()
        let template = match[0]
      endif
      return 'apps/'.symfony#CurrentAppName().module_path.'/templates/_'.template.'.php'
    endif
  endfor

  let component_patterns = [
        \ 'include_component(',
        \ 'this->renderComponent(',
        \ 'this->getComponent(',
        \ 'get_component(',
        \ ]

  for c in component_patterns
    if s:InString(line, c) " Follow a component include:
      let rx = c
      let rx .= quoted_capture
      let rx .= ','
      let rx .= quoted_capture
      let rx .= '[\s,)]' " Might end with different things

      let match = split(s:ExtractRx(line, rx, '\1 \2'))

      let [module, template] = match
      return 'apps/'.symfony#CurrentAppName().'/modules/'.module.'/templates/_'.template.'.php'
    endif
  endfor

  if s:InString(line, 'use_stylesheet') " Follow an included css:
    let rx = 'use_stylesheet('
    let rx .= quoted_capture
    let rx .= '[,)]'

    let fname = g:sf_web_dir.'/css/'.s:ExtractRx(line, rx, '\1')
    if fnamemodify(fname, ':e') == ''
      let fname = fname.'.css'
    endif

    return fname
  elseif s:InString(line, 'use_javascript') " Follow an included js:
    let rx = 'use_javascript('
    let rx .= quoted_capture
    let rx .= '[,)]'

    let fname = g:sf_web_dir.'/js/'.s:ExtractRx(line, rx, '\1')
    if fnamemodify(fname, ':e') == ''
      let fname = fname.'.js'
    endif

    return fname
  elseif line =~ '::getTable('
    let table = s:ExtractRx(line, '::getTable('.quoted_capture.')', '\1')
    return symfony#TablePath(table)
  elseif exists('*PhpIncludeExpr') " Fall back to a default
    return PhpIncludeExpr(a:fname)
  else
    return a:fname
  endif
endfunction

" Utility functions -- generally belong in a utility library, but copied here
" for convenience {{{

" Checks to see if {needle} is in {haystack}.
function! s:InString(haystack, needle)
  return (stridx(a:haystack, a:needle) != -1)
endfunction

" Extract a regex match from a string
function! s:ExtractRx(expr, pat, sub)
  let rx = a:pat

  if stridx(a:pat, '^') != 0
    let rx = '^.*'.rx
  endif

  if strridx(a:pat, '$') + 1 != strlen(a:pat)
    let rx = rx.'.*$'
  endif

  return substitute(a:expr, rx, a:sub, '')
endfunction
