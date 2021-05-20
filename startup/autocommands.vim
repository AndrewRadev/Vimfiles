augroup custom
  autocmd!

  " Clean all useless whitespace:
  autocmd BufWritePre *
        \ if !exists('g:skip_clean_whitespace') && !exists('b:skip_clean_whitespace') |
        \   exe "CleanWhitespace"                                                      |
        \ endif

  " When editing a file, always jump to the last known cursor position.
  autocmd BufReadPost *
        \ if line("'\"") > 1 && line("'\"") <= line("$") |
        \   exe "keepjumps normal! g`\""                 |
        \ endif

  " Check if editing a directory
  autocmd VimEnter * call s:MaybeEnterDirectory(expand("<amatch>"))

  " Check if we're opening an http://github.com/... path
  autocmd BufNewFile * nested call s:MaybeOpenGithubFile()

  " Check if it's necessary to create a directory
  autocmd BufNewFile * call s:EnsureDirectoryExists()

  " Write stats on note files
  autocmd BufWritePost * call s:SaveFileStats(expand('%:t'))

  " Check if the buffer needs to be refreshed from disk (using 'autoread').
  " Useful when branch-hopping with git.
  autocmd FocusGained * checktime
  autocmd WinEnter    * checktime

  autocmd BufRead *.c    compiler gcc
  autocmd BufRead *.cpp  compiler gcc
  autocmd BufRead *.php  compiler php
  autocmd BufRead *.html compiler tidy
  autocmd BufRead *.xml  compiler eclim_xmllint

  autocmd BufRead *.hsc        set filetype=haskell
  autocmd BufRead *.tags       set filetype=tags
  autocmd BufRead httpd*.conf  set filetype=apache
  autocmd BufRead *.prawn      set filetype=ruby
  autocmd BufRead *.hdbs       set filetype=handlebars

  " For some reason, this doesn't work in ftplugin/man.vim
  autocmd FileType man set nonu

  " Afterimage for jpegs
  autocmd BufReadPre,FileReadPre   *.jpg,*.jpeg setlocal bin
  autocmd BufReadPost,FileReadPost *.jpg,*.jpeg if AfterimageReadPost("convert %s xpm:%s")|set ft=xpm|endif|setlocal nobin

  " Maximise on open on Win32:
  if has('win32')
    autocmd GUIEnter * simalt ~x
  endif
augroup END

function! s:MaybeEnterDirectory(file)
  if a:file == '' || !isdirectory(a:file)
    return
  endif

  let dir = a:file
  exe "cd ".fnameescape(dir)

  if filereadable('_project.vim')
    edit _project.vim
    setfiletype vim
    source _project.vim
    echomsg "Loaded project file"
    NERDTree
    wincmd w
  else
    NERDTree
    only
  endif
endfunction

function! s:EnsureDirectoryExists()
  let required_dir = expand("%:h")

  if required_dir =~ '^https\=:\/\/'
    " it's not a "real" file, it's intended for some other callback, ignore it
    return
  endif

  if !isdirectory(required_dir)
    if !confirm("Directory '" . required_dir . "' doesn't exist. Create it?")
      return
    endif

    try
      call mkdir(required_dir, 'p')
    catch
      echoerr "Can't create '" . required_dir . "'"
    endtry
  endif
endfunction

function! s:SaveFileStats(filename)
  let filename = a:filename

  if getcwd() != $HOME
    return
  endif

  let stats_filename = 'stats.'.filename.'.csv'

  if filereadable(stats_filename) && filewritable(stats_filename)
    let today              = strftime('%Y-%m-%d')
    let current_line_count = split(system('wc -l '.filename), '\s\+')[0]
    let last_line          = lib#Trim(system('tail -n 1 '.stats_filename))

    if last_line == ''
      let date = ''
    else
      let [_line_count, date] = split(last_line, ',')
    endif

    let new_last_line = current_line_count.','.today

    if date == today
      " replace the line
      call system("sed -i '$c".new_last_line."' ".stats_filename)
    else
      " add new line
      call system("echo '".new_last_line."' >> ".stats_filename)
    endif

    if v:shell_error
      echoerr "Couldn't write stats file"
    endif
  endif
endfunction

function! s:MaybeOpenGithubFile()
  let url = expand('%')

  let pattern = 'github\.com/\%(.\{-}\)/blob/\%([^/]\+\)/\(.\{-}\)\%(#L\(\d\+\)\%(-L\d\+\)\=\)\=$'
  let match = matchlist(url, pattern)

  if len(match) == 0
    return
  endif

  let [_, path, line; _rest] = match

  if !filereadable(path)
    echoerr "File doesn't exist: ".fnamemodify(path, ':p')
    return
  endif

  exe 'keepalt edit '.path
  if line != ''
    exe line
  endif
endfunction
