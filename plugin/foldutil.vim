" foldutil.vim -- utilities for creating folds.
" Author: Hari Krishna Dara (hari_vim at yahoo dot com)
" Last Change: 10-Oct-2006 @ 11:42
" Created:     30-Nov-2001
" Requires: Vim-7.0, genutils.vim(2.0)
" Version: 3.0.0
" Acknowledgements:
"   Tom Regner (tomte at tomsdiner dot org): Enhanced to work even when
"     foldmethod is not 'manual'.
"   John A. Peters (japeters at pacbell dot net) for giving feedback and
"     giving the idea of supporting an outline mode (the "-1" context).
"   Dr. Charles Campbell (drchip at campbellfamily dot biz) for helping me
"     with the negated search pattern.
"   Alex Efros (powerman at sfky dot net dot us) and others for contributing
"     with misc. things, such as examples, bug reports and other feedback.
" Licence: This program is free software; you can redistribute it and/or
"          modify it under the terms of the GNU General Public License.
"          See http://www.gnu.org/copyleft/gpl.txt 
" Download From:
"     http://www.vim.org/script.php?script_id=158
" Description:
"   The plugins provides useful commands for the ease of creating folds using
"   different match-criteria. They support creating folds in three different
"   modes, in the whole buffer, or only in the selected range:
"       - block mode
"         You give a starting and ending pattern for the blocks.
"       - outline mode
"         You give a pattern that determines the start of the block. A new
"         block automatically starts whenever the pattern is found.
"       - non-block mode
"         You give a pattern which determines the set of lines that should be
"         included in the folds. Useful to see only the matching/non-matching
"         lines with or without context.
"
"   The first set of commands use pattern matching criteria (using the
"   built-in =~ operator, see help on |expr-=~|).
"   
"     FoldMatching - All arguments are optional. The first argument specifies
"                    the begin pattern and an optional second argument can be
"                    passed to specify an end pattern (for block mode) and
"                    additionally the number of context lines to be shown
"                    (which defaults to 1 if not specified). To specify an
"                    outline mode, a special value of -1 should be specified
"                    as context.
"         Syntax:
"           [range]FoldMatching[!] [pattern] [endPattern] [context]
" 
"         Ex:
"           FoldMatching
"             Uses current search pattern and creates folds in non-block mode
"             with the default context of 1.
"           FoldMatching! ^\s*// 0
"             This potentially folds away all the lines that are not in
"             C++/Java single-line comments such that you can see only those
"             comments.
"           FoldMatching public -1
"             Uses "public" as the pattern and creates folds in outline mode.
"           FoldMatching /\* \*/ 0
"             Creates folds for all the C++/Java style block comments with no
"             context.
"
"     FoldNonMatching - This is just an alias for "FoldMatching" with a bang.
"
"   The following commands use line number as match criteria
"   
"     FoldShowLines - Pass a comma-separated list of line numbers and an
"                     optional number of context lines to show/hide. All the
"                     rest of the lines (excluding those in context) will be
"                     folded away. You can also create blocks by specifying an
"                     optional list of line numbers as a second argument. You
"                     can give a range too.
"         Syntax:
"           [range]FoldShowLines[!] {lineNumbers} [endLineNumbers] [context]
"   
"         Ex:
"           FoldShowLines 10,50,100 3
"             Creates four folds exposing the lines 10, 50 and 100 with a
"             context of 3 lines.
"           FoldShowLines! 5,15,25 10,20,30 0
"             Creates three folds with 5 to 10, 15 to 20 and 25 to 30 as blocks.
"
"     FoldShowMarks - Shows all the lines that have a mark defined in the
"                     current buffer, by folding away all the rest of the
"                     lines. Only the marks from a-z and A-Z are considered
"                     for match criteria.
"         Syntax:
"           [range]FoldShowMarks [context]
"
"   The following command takes a highlight group as a match criteria, and
"     uses it to show/hide lines.
"   
"     FoldShowHiGroup - Pass a highlight group name and an optional number of
"                     context lines to be shown. All the rest of the lines
"                     (excluding those in context) will be folded away. You
"                     can also create blocks by specifying an optional end
"                     highligh group as a second argument. You can give a
"                     range too.
"         Syntax:
"           [range]FoldShowHiGroup[!] {HiGroup} [endHiGroup] [context]
"   
"         Ex:
"           FoldShowHiGroup Todo
"             Folds away all the lines except those that have a TODO item
"             mentioned (in Java, this is all the comments containing the
"             words TODO or FIXME, by default) with a context of 1 line.
"           FoldShowHiGroup Special 0
"             In HTML this reveals just the lines containing special characters.
"           FoldShowHiGroup! Comment 0
"             This will fold away all the comment lines in any language.
"   
"   The following is purely for convenience to reduce the number of commands
"   to be executed (you need to create separate folds).
"
"     FoldShowRange - All the lines are folded except for the lines in the range
"                     given. Helps to search only in a range of lines, as it is
"                     easy to identify when the cursor goes out of the range.
"                     Also consider removing "search" and "jump" from
"                     'foldopen' setting.
"         Syntax:
"           [range]FoldShowRange
"   
"         Ex:
"           50,500FoldShowRange
"   
"       The defaults for pattern and context are current search pattern
"         (extracted from / register) and 1 respectively.
"       The outline mode additionally modifies the 'foldtext' such that the
"         starting line shows up as the summary line for the fold (without the
"         usual dashes and number of lines in the prefix). This allows you to
"         view the matched lines more clearly and also follow the same
"         indentation as the original (nice when folding code). You can
"         however set g:foldutilFoldText to any value that is acceptable for
"         'foldtext' and customize this behavior (e.g., to view the number of
"         lines in addition to the matched line, set it to something like:
"             "getline(v:foldstart).' <'.(v:foldend-v:foldstart+1).' lines>'").
"
"       Ex: 
"         - Open a vim script and try: 
"             FoldNonMatching \<function\> -1
"         - Open a java class and try: 
"             FoldNonMatching public\|private\|protected -1
"         - Open files with diff/patch output for several files and try:
"             FoldMatching diff -1
"
"         Please send me other uses that you found for the "-1" context and I
"         will add it to the above list.
"
"   Notes:
"   - The plugin provides several ways to specify the fold blocks, but not all
"     of them might make sense to you, especially when used with the *bang*
"     option to invert the match.
"
"   - For :FoldMatching command, the pattern is searched using the built-in
"     search() function, so any limitations application to this function apply
"     to the patterns passed to the command as well.
"
"   - You can change the default for context by setting g:foldutilDefContext.
"
"   - The arguments are separated by spaces, so to include spaces in the
"     patterns, you need to protect them with a back-slash. Specifying a bang
"     makes the match inverse, so it allows you to show matching lines,
"     instead of folding them away.
"
"   - You can change the context alone by using :FoldSetContext command or
"     completely end folding and revert the settings modified by the plugin by
"     using the :FoldEndFolding command.
"
"   - When the commands are executed, if the current 'foldmethod' is not
"     "manual", it is switched to "manual" temporarily and restored when the
"     folding is ended using the :FoldEndFolding command. It also remembers
"     other fold related settings (such as the existing folds and
"     'foldminlines') and restores them as much as possible. For help on
"     working with folds, see help on |folding|.
"
"   - The plugin by default, first clears the existing folds before creating the
"     new folds. But you can change this by setting g:foldutilClearFolds to 0,
"     in which case the new folds are added to the existing folds, so you can
"     create folds incrementally.
"
"   - The plugin provides a function to return a string with Vim commands to
"     recreate the folds in the current window. Executing the string later
"     results in the folds getting recreated as they were before (so you can
"     use it to save the folds). You need to make sure that 'fdm' is either in
"     "manual" or "marker" mode to be able to execute the return value (though
"     lline is an int, you can pass in the string '$' as a shortcut to mean
"     the last line).
"
"       String  FoldCreateFoldsStr(int fline, int lline)
"
"   - You can create your own match criteria and extend the functionality of
"     the plugin by using the b:fuSearchFn variable. If you set the name of
"     your search function with custom match criteria to this variable, before
"     calling the :FoldMatching or :FoldNonMatching commands, the plugin uses
"     the custom function instead of one of the standard search functions that
"     comes with the plugin. The prototype of the function is:
"
"       int Search(pattern, negate)
"
"     The function should behave very much like the built-in search()
"     function, ie., it should search for the next line matching the give
"     pattern (using your custom match criteria), position the cursor at the
"     matched line and return the line number. When the match fails, it
"     should return 0 and shouldn't change the cursor position
"     (see :help search()).
"
"     See one of the existing functions, s:SearchForPattern(),
"     s:PositionAtNextLine() and s:PositionAtNextHiGroup() for examples.
"
" Summary Of Features:
"   Command Line:
"     FoldMatching (or FoldNonMatching), FoldShowLines, FoldShowMarks,
"     FoldShowHiGroup, FoldShowRange, FoldEndFolding
"
"   Functions:
"     FoldCreateFoldsStr
"
"   Settings:
"       g:foldutilDefContext, g:foldutilClearFolds, g:foldutilFoldText
" TODO:
"   - Support specifying line ranges for FoldShowLines.

if exists("loaded_foldutil")
  finish
endif

if v:version < 700
  echomsg 'foldutil: You need at least Vim 7.0'
  finish
endif

if !exists('loaded_genutils')
  runtime plugin/genutils.vim
endif
if !exists('loaded_genutils') || loaded_genutils < 200
  echomsg 'foldutil: You need a newer version of genutils.vim plugin'
  finish
endif

let loaded_foldutil=400

" Make sure line-continuations won't cause any problem. This will be restored
"   at the end
let s:save_cpo = &cpo
set cpo&vim

" Initializations {{{

if ! exists("g:foldutilDefContext")
  let g:foldutilDefContext = 1
endif

if ! exists("g:foldutilClearFolds")
  " First eliminate all the existing folds, by default.
  let g:foldutilClearFolds = 1
endif

" 'foldtext' to be used for '-1' context case.
if ! exists("g:foldutilFoldText")
  let g:foldutilFoldText = 'getline(v:foldstart)'
endif

" We use current line as the default because using "%" will change the current
" line, and there is no workaround it. The currentline is treated as "%".
command! -range -bang -nargs=* FoldMatching
      \ :let b:fuSearchFn = 's:SearchForPattern' |
      \ call <SID>FoldMatching(<line1>, <line2>, '<bang>', <f-args>)
" An alias for FoldMatching!. Makes sense only for non-block mode.
command! -range -nargs=* FoldNonMatching :<line1>,<line2>FoldMatching! <args>
" Our sense of <bang> is different from that of FoldMatching.
command! -range -bang -nargs=+ FoldShowLines
      \ :let b:fuSearchFn = 's:PositionAtNextLine' |
      \ call <SID>FoldMatching(<line1>, <line2>, ('<bang>' == '' ? '!' : ''),
      \   <f-args>)
command! -range -nargs=? FoldShowMarks
      \ :let b:fuSearchFn = 's:PositionAtNextLine' |
      \ call <SID>FoldMatching(<line1>, <line2>, '!', <SID>GetMarkedLines(),
      \ <f-args>)
command! -range -bang -nargs=+ FoldShowHiGroup
      \ :let b:fuSearchFn = 's:PositionAtNextHiGroup' |
      \ call <SID>FoldMatching(<line1>, <line2>, ('<bang>' == '' ? '!' : ''),
      \   <f-args>)
command! -range FoldShowRange
      \ :<line1>,<line2>call <SID>FoldShowRange(<line1>, <line2>)

command! -nargs=1 FoldSetContext :call <SID>FoldSetContext(<f-args>)
command! FoldEndFolding :call <SID>EndFolding()

" Initializations }}}

function! s:FoldMatching(fline, lline, bang, ...) " {{{
  call s:BeginFolding()
  if a:0 > 3
    echohl Error | echo "Too many arguments" | echohl None
    return
  endif

  " Set/reset context {{{
  if a:0 > 0
    let b:fuBgPattern = a:1
  else
    " If there is no pattern provided, use the current / register.
    let b:fuBgPattern = @/
  endif
  if b:fuBgPattern == ""
    echohl Error | echo "No previous search pattern exists. Pass a search " .
          \ "pattern as argument or do a search using the / command before " .
          \ "re-running this command" | echohl None
    return
  endif
  let b:fuEnPattern = ''
  let b:fuContext = g:foldutilDefContext
  if a:0 > 2
    let b:fuEnPattern = a:2
    let b:fuContext = a:3
  elseif a:0 > 1
    if a:2 =~ '^-\?\d\+$'
      let b:fuContext = a:2
    else
      let b:fuEnPattern = a:2
    endif
  endif
  " We treat "range-current-line" as if it is "%".
  if a:fline == a:lline && a:fline == line('.')
    let b:fuFline = 1
    let b:fuLline = line('$')
  else
    let b:fuFline = a:fline
    let b:fuLline = a:lline
    " FIXME: Check if this is required (ie., check if vim already does it for
    " us).
    if b:fuFline < 1
      let b:fuFline = 1
    endif
    if b:fuLline > line('$')
      let b:fuLline = line('$')
    endif
  endif
  let b:fuBgNegate = (a:bang == '!')

  " fuBlockMode just indicates that the begin and end patters are different.
  if b:fuEnPattern != '' || b:fuContext == -1
    " We don't support "-1" context when fubgPattern and fuenPattern are
    "   different.
    if b:fuContext == -1
      let b:fuEnPattern = b:fuBgPattern
      let b:fuBlockMode = 2
      let b:fuContext = 0
    else
      let b:fuBlockMode = 1
    endif
    let b:fuEnNegate = b:fuBgNegate
  else
    let b:fuBlockMode = 0
    let b:fuEnPattern = b:fuBgPattern
    let b:fuEnNegate = ! b:fuBgNegate
  endif
  let s:insideFold = 0
  let s:blockStarted = 0
  let s:skipLineNr = 0
  let s:nFolds = 0

  if b:fuBlockMode == 2
    call s:SaveSetting('foldtext')
    let &l:foldtext=g:foldutilFoldText
  else
    call s:SaveSetting('foldtext')
    setl foldtext=
  endif

  if !exists('b:fuSearchFn')
    " Use the default matcher.
    let b:fuSearchFn = 's:SearchForPattern'
  endif
  " end context }}}

  call s:SaveSetting('foldlevel')
  setl foldlevel=0
  call s:SaveSetting('foldminlines')
  setl foldminlines=0
  let stTime = localtime()
  call s:CreateFoldsInLoop()
  if s:nFolds != 0
    redraw | echo "Created: " . s:nFolds . ' folds in: ' .
          \ (localtime() - stTime) . ' seconds'
  endif
endfunction " }}}

function! s:FoldShowRange(fline, lline) range " {{{
  if a:fline == a:lline && a:lline == line('.')
    return
  endif
  call s:BeginFolding()
  call s:SaveSetting('foldopen')
  set foldopen-=search
  if a:firstline != 1
    exec '1,'.a:firstline.'-1 fold'
  endif
  if a:lastline != line('$')
    exec a:lastline.'+1,$ fold'
  endif
endfunction " }}}

function! s:FoldSetContext(newCntxt) " {{{
  if exists('b:fuSettStr')
    call s:FoldMatching(b:fuFline, b:fuLline, (b:fuBgNegate ? "!" : ""),
          \ b:fuBgPattern, (b:fuBlockMode != 2) ? '' : b:fuEnPattern,
          \ a:newCntxt)
  endif
endfunction " }}}

function! s:CreateFoldsInLoop() " {{{
  call genutils#SaveHardPosition('FoldUtil')
  if g:foldutilClearFolds
    " First eliminate all the existing folds.
    normal zE
  endif

  " Position the cursor on the last char of previous line.
  " Works for all lines except when firstline is 1.
  let foldCount = 0
  " So that when there are no matches, we can avoid creating one big fold.
  let matchFound = 0
  let stLine = 0
  let enLine = 0
  let lastBlock = 0
  " For outline mode, we want all lines to be included in a fold
  " (simplification).
  if b:fuBlockMode == 2
    let s:blockStarted = 1
  endif
  exec b:fuFline
  normal 0
  while 1
    try
      if !s:blockStarted
        let stLine = {b:fuSearchFn}(b:fuBgPattern, b:fuBgNegate)
        if stLine != 0 && stLine <= b:fuLline
          " Found begin pattern.
          let s:blockStarted = line('.')
        else
          break
        endif
      else
        " Search for the end of the block and create a fold if applicable.
        let enLine = {b:fuSearchFn}(b:fuEnPattern, b:fuEnNegate)
        if enLine > b:fuLline
          let enLine = b:fuLline
          exec enLine
        endif
        let lastBlock = 0
        if enLine == 0
          if b:fuBlockMode != 1
            let enLine = b:fuLline
            exec enLine
            let lastBlock = 1
          else
            break
          endif
        endif
        if enLine != 0 " Found the end of the block.
          if b:fuBlockMode != 1 && !lastBlock
            let enLine = enLine - 1
          endif
          if (enLine - s:blockStarted) >
                \ (b:fuContext + (!lastBlock * b:fuContext) - 1)
            call s:CreateFold(s:blockStarted + b:fuContext,
                  \ enLine - (!lastBlock * b:fuContext))
          endif
          if b:fuBlockMode == 2
            let s:blockStarted = line('.')
          else
            let s:blockStarted = 0
          endif
        endif
      endif
    finally
      let curLine = line('.')
      +
      if line('.') > b:fuLline || curLine == line('.')
        break
      endif
      normal 0
    endtry
  endwhile
  redraw | echo "Folds created: " . foldCount
  call genutils#RestoreHardPosition('FoldUtil')
endfunction

function! s:CreateFold(st, en)
  if a:st != 0 && (a:en - a:st + 1) > &foldminlines
    exec a:st.",".a:en."fold"
    let s:nFolds = s:nFolds + 1
  endif
endfunction
" }}}

" FIXME: This can probably be merged with CreateFoldsInLoop().
function! FoldCreateFoldsStr(fline, lline) " {{{
  let crFoldStr = ''
  let inFold = 0
  let foldLevel = 0
  let prevFoldLevel = 0
  " We need a stack of start lines, as we need to take care of the nesting.
  let foldStLines = []
  let line = (a:fline > 0) ? a:fline : 1
  let lline = (a:lline == '$' || a:lline > line('$')) ? line('$') : a:lline
  while line <= lline
    let foldLevel = foldlevel(line)
    " If greater than previous fold level, that means we just entered into a
    "   new fold, so start the fold.
    if foldLevel > prevFoldLevel
      " Push this line.
      call add(foldStLines, line)
    elseif foldLevel < prevFoldLevel
      let stLine = foldStLines[-1] " Last element.
      " Strictly speaking, this is not possible.
      if stLine != ''
        call remove(foldStLines, len(foldStLines)-1)
        let crFoldStr = crFoldStr . stLine.','.(line-1)."fold\n"
      endif
    endif
    let prevFoldLevel = foldLevel
    let line = line + 1
  endwhile
  " Close all the unclosed folds (possible because of the restricted range).
  let stLine = 0
  for stLine in reverse(foldStLines)
    " Strictly speaking, this is not possible.
    if stLine != ''
      let crFoldStr = crFoldStr . stLine.','.(line-1)."fold\n"
    endif
  endfor
  return crFoldStr
endfunction " }}}

" utility-functions {{{

function! s:SearchForPattern(pat, negate)
  let line = 0
  if line('.') == 1
    if match(getline(1), a:pat) != -1 && ! a:negate
      let line = 1
    endif
  endif
  if line == 0
    -
    normal $
    if a:negate
      let line = search('^\(\('.a:pat.'\)\@!.\)*$', 'W')
    else
      let line = search(a:pat, 'W')
    endif
  endif
  return line
endfunction

let s:curLinesPattern = ''
let s:curLines = []
function! s:PositionAtNextLine(lines, negate)
  if s:curLinesPattern ==# a:lines
    let lines = s:curLines
  else
    let lines = sort(split(a:lines, ','), 'genutils#CmpByNumber')
    let s:curLines = lines
    let s:curLinesPattern = a:lines
  endif

  if a:negate
    let lastLine = line('$')
    let i = line('.')
    while i <= lastLine && index(lines, i) != -1
      let i = i + 1
    endwhile
    if i > lastLine
      return 0
    else
      exec i
      return i
    endif
  else
    let curLine = line('.')
    for nextLine in lines
      if nextLine > curLine
        exec nextLine
        return nextLine
      endif
    endfor
  endif
  return 0
endfunction

function! s:PositionAtNextHiGroup(hiName, negate)
  let firstLine = line('.')
  let lastLine = line('$')
  let i = firstLine
  while i <= lastLine
    try
      let lastCol = col('$')
      let matches = 0
      if lastCol != 1 " Blank line
        " We need to look through the entire line to determine whether the
        " highlight group exists or doesn't exist.
        let j = 1
        while j < lastCol
          let matches = matches ||
                \ (synIDtrans(synID(i, j, 0)) == hlID(a:hiName))
          let j = j + 1
        endwhile
      endif
      if a:negate
        let matches = !matches
      endif
      if matches
        break
      endif
    finally
      let i = i + 1
      exec i
    endtry
  endwhile
  if matches
    -
    return i - 1
  else
    exec firstLine
    return 0
  endif
endfunction

function! s:GetMarkedLines()
  let lines = ''
  let marks = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ"
  let i = 0
  let max = strlen(marks)
  while i < max
    let line = line("'".marks[i])
    if line != 0
      let lines = lines.line.','
    endif
    let i = i + 1
  endwhile
  return lines
endfunction

" We save settings in the buffer variable, though window variable will be more
" appropriate. This is because, the rest of the functionality acts local to
" the buffer.
function! s:SaveSetting(setting)
  if exists('b:fuOrg{a:setting}')
    " Avoid overwriting an already saved value.
    return
  endif
  if !exists('b:fuOrgSettings')
    let b:fuOrgSettings = []
  endif
  "let b:fuOrg{a:setting} = &l:{a:setting}
  exec 'let b:fuOrg{a:setting} = &l:'.a:setting
  call add(b:fuOrgSettings, a:setting)
endfunction

function! s:RestoreSettings()
  for nextSett in b:fuOrgSettings
    "let &l:{nextSett} = b:fuOrg{nextSett}
    exec 'let &l:'.nextSett.' = b:fuOrg{nextSett}'
    unlet b:fuOrg{nextSett}
  endfor
  unlet b:fuOrgSettings
endfunction

function! s:BeginFolding()
  if !exists('b:fuSettStr')
    let b:fuSettStr = ''
    call s:SaveSetting('foldmethod')
    if &foldmethod == 'manual'
      let b:fuSettStr = b:fuSettStr . FoldCreateFoldsStr(1, line('$'))
    endif
    setl foldmethod=manual
  endif
endfunction

function! s:EndFolding()
  if exists('b:fuSettStr')
    normal zE
    call s:RestoreSettings()
    unlet! b:fuSearchFn b:fuBgPattern b:fuEnPattern b:fuBgNegate b:fuEnNegate
          \ b:fuContext b:fuFline b:fuLline b:fuBlockMode b:fuSettStr
  else
    echo 'FoldEndFolding: Nothing to do.'
  endif
endfunction

" utility-functions }}}

" Restore cpo.
let &cpo = s:save_cpo
unlet s:save_cpo

" vim6:fdm=marker et
