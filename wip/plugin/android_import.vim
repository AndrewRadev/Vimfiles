" Disabled at the moment, something to revisit
finish

let g:android_root = '/opt/android-sdk/sources/android-17/'

" TODO (2014-11-16) Don't import a class twice
" TODO (2014-11-16) Sort list
" TODO (2014-11-16) OnItemClickListener (for example) is a class sitting
" within a different package. Find a way to import the right one.
command! -nargs=* -complete=tag Import call s:Import(<f-args>)
function! s:Import(...)
  if a:0 > 0
    let class_name = a:1
  else
    let class_name = expand('<cword>')
  endif

  let taglist = taglist('^'.class_name.'$')
  let packages = map(taglist, 's:Modulize(g:android_root, v:val.filename)')

  if len(packages) == 0
    echomsg "Don't know how to import ".class_name
    return
  endif

  if len(packages) > 1
    let choice = inputlist(['Select package'] + map(copy(packages), '(v:key + 1) . ") " . v:val'))
    if choice > 0
      let package = packages[choice - 1]
    endif
  else
    let package = packages[0]
  endif

  let saved_view = winsaveview()

  " First, search for other imports
  normal! G
  if search('^import', 'bW') > 0
    call append(line('.'), ['import '.package.';'])
    let saved_view.lnum += 1
  elseif search('^package', 'bW') > 0
    call append(line('.'), ['', 'import '.package.';'])
    let saved_view.lnum += 2
  else
    call append(0, ['import '.package.';', ''])
    let saved_view.lnum += 2
  endif

  call winrestview(saved_view)
endfunction

function! s:Modulize(root, path)
  let root = a:root
  let path = a:path

  let path        = substitute(path, '^\V'.root, '', '')
  let path        = substitute(path, '\.java$', '', '')
  let module_name = substitute(path, '/', '.', 'g')

  return module_name
endfunction
