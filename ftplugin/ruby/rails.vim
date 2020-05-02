if exists(':Emodel')
  finish
endif

command! -nargs=1 -complete=custom,s:CompleteRailsModels Emodel call s:Emodel(<q-args>)

function! s:Emodel(model_name)
  let model_name = rails#singularize(rails#underscore(a:model_name))
  exe 'edit app/models/'.model_name.'.rb'
endfunction

function! s:CompleteRailsModels(A, L, P)
  let names = []
  for file in split(glob('app/models/**/*.rb'), "\n")
    let name = fnamemodify(file, ':t:r')
    call add(names, name)
  endfor
  return join(names, "\n")
endfunction
