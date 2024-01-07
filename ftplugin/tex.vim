RunCommand call LatexRun(expand('%'))

function! LatexRun(fname)
  if !exists('b:output_directory')
    let b:output_directory = tempname()
  endif

  echo "Compiling ..."
  let output = systemlist(
        \   'latexmk -silent -pdf -aux-directory=aux/ -outdir=' .. b:output_directory ..
        \   ' ' .. shellescape(a:fname)
        \ )
  if v:shell_error
    for line in output
      echoerr line
    endfor
    return
  endif

  let pdf = substitute(a:fname, '\.tex$', '.pdf', '')
  call system('evince ' .. shellescape(b:output_directory .. '/' .. pdf) .. ' &')

  redraw
  echo "Compiling done"
endfunction
