function! xruntime#inline_function_arguments#Run(lines)
  let function_pattern = '^\s*fu[nction!]* \%(\w:\)\=\%(\k\+\)(\(.\{-}\)).*$'
  let processed_lines = []

  for line in a:lines
    call add(processed_lines, line)

    if line =~ function_pattern
      let function_arguments = substitute(line, function_pattern, '\1', '')
      let variables          = split(function_arguments, ',\s*')

      for var in variables
        if var == '...'
          continue
        endif

        call add(processed_lines, 'let '.var.' = a:'.var)
      endfor
    endif
  endfor

  return processed_lines
endfunction
