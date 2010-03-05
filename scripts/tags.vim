let g:tag_data       = {}
let g:tag_data.tags  = {}
let g:tag_data.kinds = {}
let g:tag_data.files = {}
function! CollectTags()
  for file in split(&tags, ',')
    if filereadable(file)
      for line in readfile(file)
        " Find a way to solve embedded tabs
        let [tdata; rest]    = split(line, ";\"\t")
        let textra           = join(rest, "\t")
        let [t, tfile; rest] = split(tdata, "\t")
        let tpattern         = join(rest, "\t")
        let k = textra
      endfor
    endif
  endfor
endfunction
command! CollectTags call CollectTags()
