command! -nargs=* Ginitpull call s:Ginitpull(<f-args>)
function! s:Ginitpull(...)
  if a:0 == 0
    let remote_name = 'origin'
  else
    let remote_name = a:1
  endif

  try
    let current_branch = s:CurrentGitBranch()
    let github_path    = s:GithubPath(remote_name)
  catch /./
    echoerr v:exception
  endtry

  call lib#OpenUrl('https://github.com/'.github_path.'/pull/new/'.current_branch)
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
  if filereadable('.git/HEAD')
    let head_ref = readfile('.git/HEAD')[0]
  elseif filereadable('.git')
    let module_file = readfile('.git')[0]
    let module_file = substitute(module_file, 'gitdir: \(.*\)', '\1/HEAD', '')
    let head_ref    = readfile(module_file)[0]
  else
    throw 'This doesn''t look like a git repository, neither .git/HEAD nor .git were found.'
  endif

  return substitute(head_ref, 'ref: refs/heads/\(.*\)', '\1', '')
endfunction
