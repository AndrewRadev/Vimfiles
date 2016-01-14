command! -complete=custom,s:GinitpullComplete -nargs=* Ginitpull call s:Ginitpull(<f-args>)
function! s:Ginitpull(...)
  let remote_name = get(a:000, 0, 'origin')
  let branch_name = get(a:000, 1, '')

  try
    if branch_name == ''
      let branch_name = s:CurrentGitBranch()
    endif

    let github_path = s:GithubPath(remote_name)
  catch /./
    echoerr v:exception
  endtry

  call Open('https://github.com/'.github_path.'/pull/new/'.branch_name)
endfunction

function! s:GinitpullComplete(argument_lead, command_line, cursor_position)
  if a:argument_lead != ''
    " then we're in the middle of an argument, remove it from the command-line
    let start_of_line = substitute(a:command_line, a:argument_lead.'$', '', '')
  else
    " just take the entire command-line
    let start_of_line = a:command_line
  end

  let arg_count = len(split(start_of_line, '\s\+'))

  if arg_count <= 1
    " first argument: remote
    let completions = lib#TrimLines(system('git remote'))
  elseif arg_count == 2
    " second argument: branch
    let completions = substitute(system('git branch'), '\*\s*', '', 'g')
    let completions = lib#TrimLines(completions)
  else
    " can't handle more than 2 arguments
    let completions = ''
  endif

  return completions
endfunction

function! s:GithubPath(remote_name)
  for remote in split(system('git remote -v'), "\n")
    if remote =~ '^'.a:remote_name
      if remote =~ 'git@github.com'
        return substitute(remote, '.*git@github.com:\(.*\)\.git.*', '\1', '')
      elseif remote =~ 'https\?://github\.com'
        return substitute(remote, '.*https\?://github\.com/\(.*\)\.git.*', '\1', '')
      endif
    endif
  endfor

  throw 'No remote "'.a:remote_name.'" was found, or remote is not from github.'
endfunction

function! s:CurrentGitBranch()
  " Search upwards for relevant files
  let head_file    = findfile('.git/HEAD', ';')
  let dot_git_file = findfile('.git', ';')

  if filereadable(head_file)
    let head_ref = readfile(head_file)[0]
  elseif filereadable(dot_git_file)
    let module_file = readfile(dot_git_file)[0]
    let module_file = substitute(module_file, 'gitdir: \(.*\)', '\1/HEAD', '')
    let head_ref    = readfile(module_file)[0]
  else
    throw 'This doesn''t look like a git repository, neither .git/HEAD nor .git were found.'
  endif

  return substitute(head_ref, 'ref: refs/heads/\(.*\)', '\1', '')
endfunction
