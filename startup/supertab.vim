let g:SuperTabDefaultCompletionType        = 'context'
let g:SuperTabContextDefaultCompletionType = '<c-n>'
let g:SuperTabRetainCompletionDuration     = 'insert'
let g:SuperTabMidWordCompletion            = 1
let g:SuperTabMappingForward               = '<c-j>'
let g:SuperTabMappingBackward              = '<c-k>'
let g:SuperTabCompletionContexts           = 
      \ ['s:ContextText', 'SafeTagsExpansion']

function! SafeTagsExpansion()
  for tagfile in tagfiles()
    if filereadable(tagfile)
      return "\<c-x>\<c-]>"
    endif
  endfor

  return "\<c-p>"
endfunction
