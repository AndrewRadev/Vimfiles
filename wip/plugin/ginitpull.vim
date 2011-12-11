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

  call OpenURL('https://github.com/'.github_path.'/pull/new/'.current_branch)
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
  if !filereadable('.git/HEAD')
    throw 'This doesn''t look like a git repository, .git/HEAD was not found.'
  endif

  let head_ref = readfile('.git/HEAD')[0]
  return substitute(head_ref, 'ref: refs/heads/\(.*\)', '\1', '')
endfunction
