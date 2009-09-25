" TODO: Rename, clean up and move to autoload

function! GetPath()
"  call Dfunc( "GetPath()" )

  let current_path = NERDTreeGetCurrentPath()

  " TODO: figure out the problem with strForOs(0)
  let result = current_path.drive . current_path.strAbs()
"  Decho( result )
  let result = substitute( result, '\\\ ', '%20', 'g' )
"  Decho( result )
  let result = substitute( result, '\\', '/', 'g' )
"  Decho( result )
  let result = 'file://'.result
"  Decho( result )

"  call Dret( "GetPath" )
  return result
endfunction

nmap <buffer> gu :exe printf("Utl ol %s", GetPath())<cr><cr>
