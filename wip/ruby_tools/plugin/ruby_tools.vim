" TODO
"   - Move cursor to necessary line
"   - Use search instead of matching, in order to move cursor
"   - Separate object for each kind of token
"   - Build hierarchy after parsing

autocmd FileType ruby call s:AttachCustomBehaviour()

function! s:AttachCustomBehaviour()
  call s:CustomBehaviour()

  autocmd! BufWrite <buffer> call s:CustomBehaviour()
endfunction

function! s:CustomBehaviour()
  let parser = ruby_tools#parser#Construct()

  for line in getbufline('%', 1, '$')
    if line =~ '\<class\>'
      call parser.AddToken('class', line)
    elseif line =~ '\<def\>'
      call parser.AddToken('def', line)
    elseif line =~ '\<\(public\|private\|protected\)\>'
      call parser.AddToken('access_modifier', line)
    endif
  endfor

  let b:parser = parser
endfunction
