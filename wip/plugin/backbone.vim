command! -nargs=+ -complete=custom,s:CompleteBackbone Backbone call s:Backbone(<f-args>)
function! s:Backbone(event, ...)
  let quote    = '[''"]'
  let event    = a:event
  let selector = join(a:000, '\s\+')

  let pattern = quote.'.\{-}'.event.'.\{-}'.selector.'.\{-}'.quote

  call search(pattern, '')
  let callback = lib#ExtractRx(getline('.'), ':\s*'.quote.'\(.*\)\s*'.quote.'\s*$', '\1')
  call search('^\s*\zs'.callback.':.*[-=]>', '')
endfunction

function! s:CompleteBackbone(arg, command_line, cursor)
  let lines  = getbufline('%', 1, '$')
  let events = s:ExtractBackboneEvents(lines)
  let args   = split(a:command_line, '\s\+')

  if len(args) > 2 || (len(args) == 2 && a:command_line =~ '\s\+$')
    let event     = args[-1]
    let selectors = s:Flatten(map(s:FuzzyIndex(events, event), 'v:val[0]'))
    return join(selectors, "\n")
  else
    return join(keys(events), "\n")
  endif
endfunction

function! s:Flatten(collection)
  let flat_collection = []

  for subcollection in a:collection
    for item in subcollection
      call add(flat_collection, item)
    endfor
  endfor

  return flat_collection
endfunction

function! s:FuzzyIndex(collection, key_prefix)
  let values = []

  for [key, value] in items(a:collection)
    if key =~ a:key_prefix
      call add(values, value)
    endif
  endfor

  return values
endfunction

function! s:ExtractBackboneEvents(lines)
  let quote         = '[''"]'
  let word_pattern  = '\%(\w\|\s\|\.\)\{-}'
  let event_pattern = quote.'\('.word_pattern.'\)'.quote.':\s*'.quote.'\('.word_pattern.'\)'.quote.'\s*$'

  let lines  = a:lines
  let events = {}
  let found  = 0

  for line in lines
    if line =~ 'events:'
      let found = 1
    elseif found
      if line !~ event_pattern
        break
      else
        let [event_description, callback] = split(lib#ExtractRx(line, event_pattern, '\1:\2'), ':')
        let [event; selectors] = split(event_description, '\s\+')
        let events[event] = [selectors, callback]
      endif
    endif
  endfor

  return events
endfunction
