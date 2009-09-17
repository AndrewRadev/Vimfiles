" DrChip's debugger syntax file
" Language   : DrChip's Dfunc/Decho/Dret output
" Maintainer : Charles E. Campbell, Jr.
" Last change: Aug 12, 2008
" Version    : 5

" Remove any old syntax stuff hanging around
syn clear

" DechoTab support
syn match	dechoTabTitleSep			"^---------$"
syn match	dechoTabTitle			"^Decho Tab$"

" Delimiters, strings, numbers
syn match   dechoDelimiter			"[{}]$"
syn match   dechoDelimiter			","
syn region  dechoAngleBrkt			oneline	matchgroup=Green	start="\w<"lc=1	matchgroup=Green	end=">" contains=dechoNotify,dechoAngleBrktInc,dechoString
syn region  dechoAngleBrktInc	contained	oneline				start="<"					end=">" contains=dechoNotify,dechoAngleBrktInc,dechoString
syn region  dechoString				oneline	matchgroup=Blue	start='"'		matchgroup=Blue	end='"' contains=dechoNotify
syn match   dechoNumber				"\<-\=[0-9]\+\>"
syn match   dechoNumber				"\<-\=[0-9]\+\ze:"
syn match   dechoNumber				"\<=-\=[0-9a-fA-F]\+\>"
syn match   dechoNumber				"\<[0-9a-fA-F]\+x$"
syn match   dechoNumber				"\<[0-9a-fA-F]\+x[^a-zA-Z=]"me=e-1

" Let me see errors/warnings/severe messages easily
syn keyword dechoNotify				fatal error severe
syn match   dechoNotify				"!!!\|???"
syn keyword	dechoWarning     			warning

" Bars, Function names, Return
syn match   dechoFunction contained		"\%([sS]:\)\=\h[a-zA-Z0-9_#]*"
syn match   dechoBar				"^|\+"
syn match   dechoStartFunc			"^|*\%([sS]:\)\=\h[a-zA-Z0-9_#]*("			contains=dechoBar,dechoFunction,dechoDelimStart
syn match   dechoStopFunc    			"^|\+return \%([sS]:\)\=\h[a-zA-Z0-9_#]*"		contains=dechoBar,dechoFunction
syn match   dechoComment     			"^[ \t]*#.*$"
syn match   dechoMatrix				"^|[-+ 0-9.e]\+|$"					contains=dechoMatrixBar
syn match   dechoMatrixBar contained	"|"

" Problems
syn keyword dechoProblem	PROBLEM[:]	COMBAK[:]	WARNING[:]	SEVERE[:]	NOTE[:]	DIFFER[S:]

if !exists("did_drchip_decho_syntax")
  let did_drchip_decho_syntax= 1

  " Links
  hi link dechoAngleBrktInc	dechoAngleBrkt

  " If the "Warning" highlighting group hasn't been defined,
  " then this script will define it.
  let s:id_hlname= hlID("Warning")
  let s:fg_hlname= synIDattr(synIDtrans(s:id_hlname),"fg")
  if s:id_hlname == 0 || s:fg_hlname == 0 || s:fg_hlname == -1
   hi Warning term=NONE cterm=NONE gui=NONE ctermfg=black ctermbg=yellow guifg=black guibg=yellow
  endif
  unlet s:id_hlname s:fg_hlname

  hi link dechoAngleBrkt	String
  hi link dechoComment		Comment
  hi link dechoDelimiter	Delimiter
  hi link dechoFunction		Statement
  hi link dechoMatrixBar	Delimiter
  hi link dechoNotify		Error
  hi link dechoNumber		Number
  hi link dechoProblem		Error
  hi link dechoString		String
  hi link dechoWarning		Warning
  hi link dechoTabTitle		PreProc
  hi link dechoTabTitleSep	Delimiter

  " HLTest: tests if a highlighting group has been set up {{{2
  fun! s:HLTest(hlname)
    let id_hlname= hlID(a:hlname)
    if id_hlname == 0
     return 0
    endif
    let id_trans = synIDtrans(id_hlname)
    if id_trans == 0
     return 0
    endif
    let fg_hlname= synIDattr(id_trans,"fg")
    let bg_hlname= synIDattr(id_trans,"bg")
    if fg_hlname == -1 && bg_hlname == -1
     return 0
    endif
    if fg_hlname == "" && bg_hlname == ""
     return 0
    endif
    return 1
  endfun

  " define DechoBarHL as needed
  if s:HLTest("Magenta")
   hi link DechoBarHL	Magenta
  else
   hi DechoBarHL	start=[m[35m stop=[m[32m	ctermfg=magenta	guifg=magenta term=none	cterm=none	gui=none
  endif
  delf s:HLTest
  hi link dechoBar     		DechoBarHL
endif
" vim: ts=6
