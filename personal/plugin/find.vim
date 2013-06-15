let s:root_dir = expand('<sfile>:p:h:h:h')

command! -nargs=1 -complete=custom,s:CompleteFind Find call s:Find(<f-args>)
command! GenerateFindTags call s:GenerateFindTags()

augroup update_file_tags
  autocmd BufWrite * call <SID>MaybeUpdateFileTags()
augroup END

function! s:Find(filename)
  if !filereadable('files.tags')
    if confirm("No `files.tags` file, generate it?")
      call s:GenerateFindTagsSync()
    else
      return
    endif
  endif

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

" Note: asynchronous
function! s:GenerateFindTags()
  let script_name = s:root_dir.'/scripts/generate-find-tags'
  call system(script_name.' &')
endfunction

function! s:GenerateFindTagsSync()
  let script_name = s:root_dir.'/scripts/generate-find-tags'
  call system(script_name)
endfunction

function! s:MaybeUpdateFileTags()
  let current_filename = expand('%:t')

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
