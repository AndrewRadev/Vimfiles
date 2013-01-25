command! -nargs=1 -complete=custom,s:CompleteFind Find call s:Find(<f-args>)
command! GenerateFindTags call s:GenerateFindTags()

augroup update_file_tags
  autocmd BufWrite * call <SID>MaybeUpdateFileTags()
augroup END

function! s:Find(filename)
  try
    let saved_tags = &tags
    let &tags = 'files.tags'

    let results = taglist(a:filename)

    if empty(results)
      echo 'No results for "'.a:filename.'".'
    elseif len(results) == 1
      exe 'edit '.results[0].filename
    else
      call s:SetqflistFromTaglist(results)
      cfirst
      copen
    endif

  finally
    let &tags = saved_tags
  endtry
endfunction
function! s:CompleteFind(argument_lead, command_line, cursor_position)
  let taglist   = s:FileTaglist(a:argument_lead)
  let filenames = map(taglist, 'v:val.name')

  return join(sort(s:Uniq(filenames)), "\n")
endfunction

function! s:GenerateFindTags()
  let file_tags =
        \ [
        \ '!_TAG_FILE_FORMAT	2	/extended format;/',
        \ '!_TAG_FILE_SORTED	1	/0=unsorted, 1=sorted, 2=foldcase/',
        \ ]

  for file in split(system("find ! -path '*.git*'"), "\n")
    if isdirectory(file)
      continue
    endif

    let basename = fnamemodify(file, ':t')
    let path     = substitute(file, '^\./', '', '')

    call add(file_tags, basename."\t".path."\t;\"\tf")
  endfor

  call sort(file_tags)
  call writefile(file_tags, 'files.tags')
endfunction

function! s:MaybeUpdateFileTags()
  let current_filename = expand('%')
  if filewritable('files.tags') && empty(s:FileTaglist(current_filename))
    call s:GenerateFindTags()
  endif
endfunction

function! s:FileTaglist(pattern)
  if a:pattern == ''
    let pattern = '.'
  else
    let pattern = a:pattern
  endif

  let saved_tags = &tags
  let &tags = 'files.tags'
  let taglist = taglist(pattern)
  let &tags = saved_tags

  return taglist
endfunction

function! s:Uniq(list)
  let set = {}

  for entry in a:list
    let set[entry] = 1
  endfor

  return keys(set)
endfunction

function! s:SetqflistFromTaglist(taglist)
  let qflist = []

  for entry in a:taglist
    let filename = entry.filename
    let pattern  = substitute(entry.cmd, '^/\(.*\)/$', '\1', 'g')

    call add(qflist, {
          \ 'filename': filename,
          \ 'pattern':  pattern,
          \ })
  endfor

  call setqflist(qflist)
endfunction
