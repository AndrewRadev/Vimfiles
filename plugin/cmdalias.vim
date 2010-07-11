" cmdalias.vim: Create aliases for Vim commands.
" Author: Hari Krishna Dara (hari.vim at gmail dot com)
" Last Change: 04-Sep-2009 @ 20:16
" Created:     07-Jul-2003
" Requires: Vim-7.0 or higher
" Version: 3.0.0
" Licence: This program is free software; you can redistribute it and/or
"          modify it under the terms of the GNU General Public License.
"          See http://www.gnu.org/copyleft/gpl.txt 
" Download From:
"     http://www.vim.org/script.php?script_id=745
" Usage:
"     :call CmdAlias('<lhs>', '<rhs>', [flags])
"     or
"     :Alias <lhs> <rhs> [flags]
"
"     :UnAlias <lhs> ...
"     :Aliases [<lhs> ...]
"
" Ex:
"     :Alias runtime Runtime
"     :Alias find Find
"     :Aliases
"     :UnAlias find
"
" Description:
"   - Vim doesn't allow us to create user-defined commands unless they start
"     with an uppercase letter. I find this annoying and constrained when it
"     comes to overriding built-in commands with my own. To override built-in
"     commands, we often have to create a new command that has the same name
"     as the built-in but starting with an uppercase letter (e.g., "Cd"
"     instead of "cd"), and remember to use that everytime (besides the
"     fact that typing uppercase letters take more effort). An alternative is
"     to use the :cabbr to create an abbreviation for the built-in command
"     (:cmap is not good) to the user-defined command (e.g., "cabbr cd Cd").
"     But this would generally cause more inconvenience because the
"     abbreviation gets expanded no matter where in the command-line you use
"     it. This is where the plugin comes to your rescue by arranging the cabbr
"     to expand only if typed as the first word in the command-line, in a
"     sense working like the aliases in csh or bash.
"   - The plugin provides a function to define command-line abbreviations such
"     a way that they are expanded only if they are typed as the first word of
"     a command (at ":" prompt). The same rules that apply to creating a
"     :cabbr apply to the second argument of CmdAlias() function too. You can
"     pass in optional flags (such as <buffer>) to the :cabbr command through
"     the third argument.
"   - The :cabbr's created this way, work like the bash aliases, except that
"     in this case, the alias is substituted in-place followed by the rules
"     mentioned in the |abbreviations|, and no arguments can be defined.
" Drawbacks:
"   - If the <rhs> is not of the same size as <lhs>, the in-place expansion
"     feels odd.
"   - Since the expansion is in-place, Vim command-line history saves the
"     <rhs>, not the <lhs>. This means, you can't retrieve a command from
"     history by partially typing the <lhs> (you have to instead type the
"     <rhs> for this purpose).

if exists("loaded_cmdalias")
  finish
endif
if v:version < 700
  echomsg "cmdalias: You need Vim 7.0 or higher"
  finish
endif
let loaded_cmdalias = 300

" Make sure line-continuations won't cause any problem. This will be restored
"   at the end
let s:save_cpo = &cpo
set cpo&vim

if !exists('g:cmdaliasCmdPrefixes')
  let g:cmdaliasCmdPrefixes = 'verbose debug silent redir'
endif

command! -nargs=+ Alias :call CmdAlias(<f-args>)
command! -nargs=* UnAlias :call UnAlias(<f-args>)
command! -nargs=* Aliases :call <SID>Aliases(<f-args>)

if ! exists('s:aliases')
  let s:aliases = {}
endif

" Define a new command alias.
function! CmdAlias(lhs, ...)
  let lhs = a:lhs
  if lhs !~ '^\w\+$'
    echohl ErrorMsg | echo 'Only word characters are supported on <lhs>' | echohl NONE
    return
  endif
  if a:0 > 0
    let rhs = a:1
  else
    echohl ErrorMsg | echo 'No <rhs> specified for alias' | echohl NONE
    return
  endif
  if has_key(s:aliases, rhs)
    echohl ErrorMsg | echo "Another alias can't be used as <rhs>" | echohl NONE
    return
  endif
  if a:0 > 1
    let flags = join(a:000[1:], ' ').' '
  else
    let flags = ''
  endif
  exec 'cnoreabbr <expr> '.flags.a:lhs.
	\ " <SID>ExpandAlias('".lhs."', '".rhs."')"
  let s:aliases[lhs] = rhs
endfunction

function! s:ExpandAlias(lhs, rhs)
  if getcmdtype() == ":"
    " Determine if we are at the start of the command-line.
    " getcmdpos() is 1-based.
    let partCmd = strpart(getcmdline(), 0, getcmdpos())
    let prefixes = ['^'] + map(split(g:cmdaliasCmdPrefixes, ' '), '"^".v:val."!\\?"." "')
    for prefix in prefixes
      if partCmd =~ prefix.a:lhs.'$'
	return a:rhs
      endif
    endfor
  endif
  return a:lhs
endfunction

function! UnAlias(...)
  if a:0 == 0
    echohl ErrorMsg | echo "No aliases specified" | echohl NONE
    return
  endif

  let aliasesToRemove = filter(copy(a:000), 'has_key(s:aliases, v:val) != 0')
  "let aliasesToRemove = map(filter(copy(s:aliases), 'index(a:000, v:val[0]) != -1'), 'v:val[0]')
  if len(aliasesToRemove) != a:0
    let badAliases = filter(copy(a:000), 'index(aliasesToRemove, v:val) == -1')
    echohl ErrorMsg | echo "No such aliases: " . join(badAliases, ' ') | echohl NONE
    return
  endif
  for alias in aliasesToRemove
    exec 'cunabbr' alias
  endfor
  call filter(s:aliases, 'index(aliasesToRemove, v:key) == -1')
endfunction

function! s:Aliases(...)
  if a:0 == 0
    let goodAliases = keys(s:aliases)
  else
    let goodAliases = filter(copy(a:000), 'has_key(s:aliases, v:val) != 0')
  endif
  if len(goodAliases) > 0
    let maxLhsLen = max(map(copy(goodAliases), 'strlen(v:val[0])'))
    echo join(map(copy(goodAliases), 'printf("%-".maxLhsLen."s %s", v:val, s:aliases[v:val])'), "\n")
  endif
endfunction

" Restore cpo.
let &cpo = s:save_cpo
unlet s:save_cpo

" vim6:fdm=marker sw=2
