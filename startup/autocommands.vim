augroup custom
  autocmd!

  " Clean all useless whitespace:
  autocmd BufWritePre *
        \ if !exists('g:skip_clean_whitespace') && !exists('b:skip_clean_whitespaste') |
        \   exe "CleanWhitespace"                                      |
        \ endif

  " When editing a file, always jump to the last known cursor position.
  autocmd BufReadPost *
        \ if line("'\"") > 1 && line("'\"") <= line("$") |
        \   exe "keepjumps normal! g`\""                 |
        \ endif

  " Check if editing a directory
  autocmd VimEnter * call s:MaybeEnterDirectory(expand("<amatch>"))

  " Check if it's necessary to create a directory
  autocmd BufNewFile * call s:EnsureDirectoryExists()

  " Write stats on note files
  autocmd BufWritePost * call s:SaveFileStats(expand('%:t'))

  autocmd BufRead *.c    compiler gcc
  autocmd BufRead *.cpp  compiler gcc
  autocmd BufRead *.php  compiler php
  autocmd BufRead *.html compiler tidy
  autocmd BufRead *.xml  compiler eclim_xmllint
  autocmd BufRead *.js   compiler jsl

  autocmd BufRead *.hsc        set filetype=haskell
  autocmd BufRead *.tags       set filetype=tags
  autocmd BufRead httpd*.conf  set filetype=apache
  autocmd BufRead *.hdbs       set filetype=handlebars

  " Automatic backup for pentadactyl-opened files
  autocmd BufWrite /tmp/pentadactyl* call s:BackupPentadactyl()

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

function! s:BackupPentadactyl()
  if !exists('b:backup_filename')
    let existing_backups = split(glob('/tmp/pentadactyl.txt.backup.*'), "\n")
    let suffixes         = map(existing_backups, 'matchstr(v:val, "\\.\\zs\\d$")')
    let numbers          = map(suffixes, 'str2nr(v:val)')
    let max_number       = max(numbers)

    let b:backup_filename = '/tmp/pentadactyl.txt.backup.'.(max_number + 1)
  endif

  exe 'silent write! '.b:backup_filename
endfunction
