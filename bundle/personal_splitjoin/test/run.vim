function! TestFiletype(ft)
  if a:ft == 'html'
    9  | SplitjoinSplit
    13 | SplitjoinSplit
    17 | SplitjoinSplit
  elseif a:ft == 'rb'
    1  | SplitjoinSplit
    7  | SplitjoinSplit
    13 | SplitjoinSplit
    20 | SplitjoinSplit
    25 | SplitjoinSplit
    31 | SplitjoinSplit
    35 | SplitjoinSplit
    41 | SplitjoinSplit
    48 | SplitjoinSplit
    49 | SplitjoinSplit
    56 | SplitjoinSplit
    60 | SplitjoinSplit
  elseif a:ft == 'erb'
    9  | SplitjoinSplit
    10 | SplitjoinSplit
    17 | SplitjoinSplit
    22 | SplitjoinSplit
    26 | SplitjoinSplit
    31 | SplitjoinSplit
    35 | SplitjoinSplit
    39 | SplitjoinSplit
    40 | SplitjoinSplit
    45 | SplitjoinSplit
  endif
endfunction

"------------------------------------------

let original_dir = getcwd()
cd %:h

for ft in ['rb', 'html', 'erb']
  tabnew
  silent exec("e examples/test.".ft)
  silent exec("w! output/test.".ft)
  silent exec("e output/test.".ft)

  silent call TestFiletype(ft)
  w

  silent exec("diffsplit expectations/test.".ft)
endfor

exec "cd ".original_dir
