let g:vsnips_snippet_files = split(globpath('~/.vim/wip/vsnips', 'examples/*.snippets'), "\n")

inoremap <c-t> <c-r>=ExpandVsnip()<cr>

function! ExpandVsnip()
  let position = getpos('.')

  let line      = getline(position[1])
  let col       = position[2]
  let candidate = line[0:col - 2]

  for snippet in SnippetsForFiletype(&filetype)
    if candidate =~ snippet.title.'$'
      let match     = candidate[len(candidate) - len(snippet.title):]
      let expansion = snippet.body

      exe 's/'.escape(match, '/').'$/'.escape(expansion, '/').'/'

      let position[2] += len(expansion) - len(match)

      break
    endif
  endfor

  call setpos('.', position)

  return ''
endfunction

function! SnippetsForFiletype(filetype)
  " TODO (2011-12-18) a:filetype ignored for now

  let snippets = []

  for file in g:vsnips_snippet_files
    let lines           = readfile(file)
    let current_snippet = {}

    for line in lines
      if line =~ '^snippet'
        " then we initialize the snippet
        if !empty(current_snippet)
          let current_snippet.body = join(current_snippet.lines, "\n")
          call add(snippets, current_snippet)
          let current_snippet = {}
        endif

        let current_snippet.title = substitute(line, 'snippet \(.*\)$', '\1', '')
        let current_snippet.lines = []
      elseif line =~ '^\t'
        " then it's part of the body
        call add(current_snippet.lines, substitute(line, '^\t\(.*\)$', '\1', ''))
      endif
    endfor

    " add final snippet
    if !empty(current_snippet)
      let current_snippet.body = join(current_snippet.lines, "\n")
      call add(snippets, current_snippet)
    endif
  endfor

  return snippets
endfunction
