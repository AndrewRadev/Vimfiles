" Custom autocommands group:
augroup custom
  " Clear all custom autocommands:
  autocmd!

  " Clean all useless whitespace:
  let g:clean_whitespace = 1
  autocmd BufWritePre *
        \ if g:clean_whitespace   |
        \   exe "CleanWhitespace" |
        \ endif

  " When editing a file, always jump to the last known cursor position.
  autocmd BufReadPost *
        \ if line("'\"") > 1 && line("'\"") <= line("$") |
        \   exe "normal! g`\""                           |
        \ endif

  " Check if editing a directory
  autocmd BufEnter,VimEnter * call s:MaybeEnterDirectory(expand("<amatch>"))

  " Check if it's necessary to create a directory
  autocmd BufNewFile * :call s:EnsureDirectoryExists()

  " Write stats on note files
  autocmd BufWritePost * :call s:SaveFileStats(expand('%:t'))

  autocmd BufEnter *.c    compiler gcc
  autocmd BufEnter *.cpp  compiler gcc
  autocmd BufEnter *.php  compiler php
  autocmd BufEnter *.html compiler tidy
  autocmd BufEnter *.xml  compiler eclim_xmllint
  autocmd BufEnter *.js   compiler jsl

  autocmd BufEnter *.hsc        set filetype=haskell
  autocmd BufEnter *.tags       set filetype=tags
  autocmd BufEnter httpd*.conf  set filetype=apache

  autocmd User BufEnterRails Rnavcommand factory spec/factories -glob=* -suffix=.rb -default=model()
  autocmd User BufEnterRails Rnavcommand feature features -glob=**/* -suffix=.feature
  autocmd User BufEnterRails command! -buffer Rroutes edit config/routes.rb

  " For some reason, this doesn't work in ftplugin/man.vim
  autocmd FileType man set nonu

  " Maximise on open on Win32:
  if has('win32')
    autocmd GUIEnter * simalt ~x
  endif
augroup END

function! s:MaybeEnterDirectory(file)
  if a:file != '' && isdirectory(a:file)
    let dir = a:file

    exe "cd ".dir
    if filereadable('_project.vim')
      source _project.vim
      echo "Loaded project file"
    endif
  endif
endfunction

function! s:EnsureDirectoryExists()
  let required_dir = expand("%:h")

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
    let [line_count, date] = split(last_line, ',')
    let new_last_line      = current_line_count.','.today

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
