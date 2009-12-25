set includeexpr=SymfonyIncludeExpr(v:fname)
function! SymfonyIncludeExpr(fname)
  " TODO possibly check for module named 'global'
  let quoted_capture = '\s*[''"]\(.\{-}\)[''"]\s*'
  let line = getline('.')

  if lib#InString(line, 'include_partial') " Follow a partial include:
    let rx = 'include_partial('
    let rx .= quoted_capture
    let rx .= '[\s,)]' " Might end with different things

    let match = split(lib#ExtractRx(line, rx, '\1'), '/')
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
  elseif lib#InString(line, 'include_component') " Follow a component include:
    let rx = 'include_component('
    let rx .= quoted_capture
    let rx .= ','
    let rx .= quoted_capture
    let rx .= '[\s,)]' " Might end with different things

    let match = split(lib#ExtractRx(line, rx, '\1 \2'))

    let [module, template] = match
    return 'apps/'.symfony#CurrentAppName().'/modules/'.module.'/templates/_'.template.'.php'
  elseif exists('*PhpIncludeExpr')
    return PhpIncludeExpr(a:fname)
  else
    return a:fname
  endif
endfunction
