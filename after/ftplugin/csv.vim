if expand('%:e') == 'tsv'
  NewDelimiter \t
  " NewDelimiter |
  let b:skip_clean_whitespace = 1
endif
