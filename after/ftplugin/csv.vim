if expand('%:e') == 'tsv'
  NewDelimiter \t
  let b:skip_clean_whitespace = 1
endif
