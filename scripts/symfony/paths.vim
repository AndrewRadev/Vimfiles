function! TemplatePath(module, template)
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
