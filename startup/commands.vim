" Simpler tag searches:
runtime plugin/tagfinder.vim

DefineTagFinder Function f,function,F,singleton\ method
DefineTagFinder Class    c,class
DefineTagFinder Module   m,module
DefineTagFinder Command  c,command
DefineTagFinder Mapping  m

" Toggle settings:
command! -nargs=+ MapToggle call lib#MapToggle(<f-args>)

MapToggle sl list
MapToggle sh hlsearch
MapToggle sw wrap
MapToggle ss spell
MapToggle sc cursorcolumn

" Rebuild tags database:
command! RebuildTags !ctags -R .

" Refresh snippets
command! RefreshSnips runtime after/plugin/snippets.vim

" Clear up garbage:
command! CleanWhitespace call lib#InPlace('%s/\s\+$//e')
command! CleanAnsiColors call lib#InPlace('%s/\[.\{-}m//ge')
command! CleanEol        call lib#InPlace('%s/$//e')

" Cheat sheet shortcut
command! -nargs=* -complete=custom,s:CheatComplete Cheat new | call s:Cheat(<q-args>)
function! s:Cheat(args)
  silent exe "e! ".tempname()
  silent exe "0r!cheat ".a:args
  set nomodified
  normal gg
endfunction
function! s:CheatComplete(A, L, P)
  return system('cheat sheets | cut -b3-')
endfunction

" Easy check of current syntax group
command! Syn call syntax_attr#SyntaxAttr()

" Quit tab, even if it's just one
command! Q call s:Q()
function! s:Q()
  try
    tabclose
  catch /E784/ " Can't close last tab
    qall
  endtry
endfunction

" Quickly open up note-files
command! Note belowright split notes.txt

" Outline the contents of the buffer
command! -nargs=* Outline call s:Outline(<f-args>)
function! s:Outline(...)
  if a:0 > 0
    call lib#Outline('\<\('.join(a:000, '\|').'\)\>')
  elseif exists('b:outline_pattern')
    call lib#Outline(b:outline_pattern)
  else
    echoerr "No b:outline_pattern for this buffer"
  endif
endfunction

" Setup the "Run" and "Console" commands for the current filetype
command! -nargs=* RunCommand
      \ command! -range=% -buffer -complete=file -nargs=* Run <args>
command! -nargs=* ConsoleCommand
      \ command! -range=% -buffer -complete=file -nargs=* Console <args>

" Should probably be in a project-specific file
command! ReadCucumberSteps r!cucumber | sed -n -e '/these snippets/,$ p' | sed -n -e '2,$ p'

command! Chmodx !chmod +x '%'

command! -nargs=* ProjInit call s:ProjInit(<f-args>)
function! s:ProjInit(...)
  e _project.vim
  write

  if a:0 > 0
    let project_name = a:1
  else
    let project_name = expand('%:p:h:t')
  end

  let cwd          = getcwd()
  let project_file = expand('%:p')

  ProjFile

  let project_body = [
        \ '',
        \ '['.project_name.']',
        \ 'path = '.cwd,
        \ 'vim = '.project_file,
        \ ]

  call append(line('$'), project_body)
  write
  ProjReload

  exec "Proj ".project_name
endfunction

" Make filename under cursor relative/absolute
command! -range Absolutize call <SID>TransformFilenameUnderCursor('p')
command! -range Relativize call <SID>TransformFilenameUnderCursor('.')
function! s:TransformFilenameUnderCursor(modifier)
  let transformation = 'fnamemodify(submatch(0), ":'.a:modifier.'")'
  let current_mode   = mode()

  if current_mode == 'v' || current_mode == 'V'
    call lib#InPlace('s/\%V.*\%V/\='.transformation)
  else
    call lib#InPlace('s/\f*\%#\f*/\='.transformation)
  endif
endfunction

" Open all files in quickfix window in tabs
command! Ctabs call s:Ctabs()
function! s:Ctabs()
  let files = {}
  for entry in getqflist()
    let filename = bufname(entry.bufnr)
    let files[filename] = 1
  endfor

  for file in keys(files)
    silent exe "tabedit ".file
  endfor
endfunction

" Assume that the current file consists only of a ruby error backtrace and
" load it in the quickfix list.
"
" TODO Handle a generic backtrace by using errorformat?
" TODO Automate backtrace saving somehow?
command! LoadBacktrace call s:LoadBacktrace()
function! s:LoadBacktrace()
  let entries = []
  for line in getbufline('%', 1, '$')
    if line !~ '.*:.*:.*'
      continue
    endif

    let [filename, lnum, text] = split(line, ':')
    call add(entries, {
          \ 'filename': filename,
          \ 'lnum':     lnum,
          \ 'text':     text,
          \ })
  endfor

  call setqflist(entries)
  copen
endfunction

command! -nargs=* -complete=command Bufferize call s:Bufferize(<f-args>)
function! s:Bufferize(...)
  let cmd = join(a:000, ' ')
  redir => output
  silent exe cmd
  redir END

  new
  setlocal nonumber
  call append(0, split(output, "\n"))
  set nomodified
endfunction

command! Gfiles call s:Gfiles()
function! s:Gfiles()
  let files = split(system('git status -s -uall | cut -b 4-'), '\n')

  for file in files
    silent exe "tabedit ".file
  endfor
endfunction

command! -nargs=1 -complete=file Rnew call s:Rnew(<f-args>)
function! s:Rnew(name)
  let parts     = split(a:name, '/')
  let base_name = parts[-1]
  let dir_parts = parts[0:-2]

  if base_name =~ '_'
    let camelcased_name  = lib#CamelCase(base_name)
    let underscored_name = base_name
  else
    let camelcased_name  = base_name
    let underscored_name = lib#Underscore(base_name)
  endif

  if !empty(dir_parts)
    let dir = join(dir_parts, '/')
    if !isdirectory(dir)
      call mkdir(join(dir_parts, '/'), 'p')
    endif
  endif

  let file_name = join(dir_parts + [underscored_name . '.rb'], '/')
  let spec_name = join(dir_parts + [underscored_name . '_spec.rb'], '/')

  if spec_name =~ '\<app/'
    let spec_name = s:SubstitutePathSegment(spec_name, 'app', 'spec')
  else
    let spec_name = s:SubstitutePathSegment(spec_name, 'lib', 'spec')
  endif

  " TODO (2011-10-24) generate module/class chain from camelcased name

  call s:EnsureDirectoryExists(file_name)
  call s:EnsureDirectoryExists(spec_name)

  exe 'edit '.file_name
  write
  exe 'split '.spec_name
  write
endfunction

function! s:SubstitutePathSegment(expr, segment, replacement)
  return substitute(a:expr, '\(^\|/\)'.a:segment.'\(/\|$\)', '\1'.a:replacement.'\2', '')
endfunction

function! s:EnsureDirectoryExists(file)
  let dir = fnamemodify(a:file, ':p:h')

  if !isdirectory(dir)
    call mkdir(dir, 'p')
  endif
endfunction
