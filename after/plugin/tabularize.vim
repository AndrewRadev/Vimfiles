if !has('ruby')
  finish
endif

AddTabularPattern! equals       /^[^=]*\zs=/
AddTabularPattern! ruby_hash    /^[^=>]*\zs=>/
AddTabularPattern! commas       /,\s*\zs\s/l0
AddTabularPattern! colons       /:\s*\zs\s/l0
AddTabularPattern! curly_braces /{/
