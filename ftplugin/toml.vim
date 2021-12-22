if expand('%:t') =~# '^Cargo.\%(toml\|lock\)$'
  nnoremap <buffer> gm :call rustbucket#toml#Doc()<cr>
endif
