if expand('%:t') =~# '^Cargo.\%(toml\|lock\)$'
  nnoremap <buffer> gm :call <SID>Doc()<cr>

  function! s:Doc()
    let saved_view = winsaveview()

    try
      if !sj#SearchUnderCursor('\%([[:keyword:]-]\+\)\ze\s*=')
        return
      endif

      let package_name = sj#Rtrim(sj#GetMotion('vt='))
      let url = 'https://crates.io/crates/'.package_name

      " Is there an explicit definition we can get a url out of?
      if search('=\s*\zs{', 'W', line('.'))
        let string_definition = sj#GetMotion('va{')
        let json_definition = substitute(string_definition, '\([[:keyword:]-]\+\)\s*=', '"\1": ', 'g')
        let definition = json_decode(json_definition)

        if definition.git =~ '^https\=://'
          let url = definition.git

          if has_key(definition, 'branch')
            let url .= '/tree/' . definition.branch
          elseif has_key(definition, 'rev')
            let url .= '/tree/' . definition.rev
          elseif has_key(definition, 'tag')
            let url .= '/tree/' . definition.tag
          endif
        endif
      endif

      if package_name != ''
        call OpenURL(url)
      endif
    finally
      call winrestview(saved_view)
    endtry
  endfunction
endif
