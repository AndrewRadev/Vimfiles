" Extracted from ftplugin/css_folding.vim
"
function! css_folding#FoldText()
  let line = getline(v:foldstart)
  let nnum = nextnonblank(v:foldstart + 1)
  while nnum < v:foldend+1
    let line = line . " " . substitute(getline(nnum), "^ *", "", "g")
    let line = substitute(line, '\S\zs\s\+', ' ', 'g')
    let nnum = nnum + 1
  endwhile
  return line
endfunction
