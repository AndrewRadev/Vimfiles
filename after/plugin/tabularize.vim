if !has('ruby')
  finish
endif

AddTabularPattern! equals    /^[^=]*\zs=/
AddTabularPattern! ruby_hash /^[^=>]*\zs=>/
AddTabularPattern! commas    /,\s*\zs\s/l0
AddTabularPattern! colons    /^[^:]*:\s*\zs\s/l0

AddTabularPipeline space / \+/
      \ map(a:lines, "substitute(v:val, ' \+', ' ', 'g')")
      \   | tabular#TabularizeStrings(a:lines, ' ', 'l0')
