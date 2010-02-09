"
" Defines a command 'Implement' to generate a skeleton implementation
" of a class from a C++ header file containing one or more class declarations.
"
" Author:   Neil Vice
" Created:  01/12/05
" Modified: 12/05/05
"
" Updated 10/12/05, adding 'g:h_extensions' as a comma-separated list of
" header-file extensions to support. Also improved robustness and fixed
" some minor issues.
"
" Updated 12/05/05 - fixed bug where header include was not inserted with the
" absence of a header-maintaining plugin. Fixed bug where if InterFunctionGap
" was set to 1 a newline would not be inserted at end-of-file.
"
" Updated 12/05/05, adding 'g:cxx_extension' to use as file-extension for
" generated source files.
"
" Updated 01/05/05 to correctly handle destructors and ignore "method-like"
" constructs in attribute comments. Now does not copy comments to the
" implementation by default - added g:implComments for this purpose.
"
" Updated 27/04/05 to handle default parameters and brackets in Doxygen
" comments as well as adding the g:fnTypeSepLine flag. Also should be more
" compatible with other plugins that provide windows e.g. minibufexpl.
"
" Updated 26/04/05 to prevent the absence of a namespace declaration from
" causing errors.
"

" Default C++ file extension to .cpp
if !exists("g:cxx_extension")
	let g:cxx_extension = "cpp"
endif

" Default C++ header extensions
if !exists("g:h_extensions")
	let g:h_extensions = "h,hxx,hh,hpp"
endif

" Determines the number of lines to leave between functions
if !exists("g:InterFunctionGap")
	let g:InterFunctionGap = 1
endif

" Defaults to not forcing a new-line after the return type
if !exists("g:fnTypeSepLine")
	let g:fnTypeSepLine = 0
endif

" Defaults to NOT copy comments across to implementation
if !exists("g:implComments")
	let g:implComments = 0
endif

function s:SwitchWindows()
	if bufnr('%') != s:h_buf
		exe bufwinnr(s:h_buf) . " wincmd w"
	else
		exe bufwinnr(s:c_buf) . " wincmd w"
	endif

	" Switch to the last window 0 used to switch between two windows
	" normal \<c-w>p
endfunction

function CopyDescriptionToLastWindow()
	" Copy the file description field if present
	if match(getline(1), '/[*][*][ \t]*$') != -1 && match(getline(4), '^ [*] .*') != -1
		exe "4"
		normal V
		let line = 5
		while match(getline(line), '^ [*][ \t]*$') == -1
			normal j
			let line = line + 1
		endwhile
		exe "normal \"ay"
		call s:SwitchWindows()
		if match(getline(1), '/[*][*][ \t]*$') != -1 && match(getline(4), '^ [*] .*') != -1
			exe "4"
			exe "normal dd\"aP"
		endif
		call s:SwitchWindows()
	endif
endfunction

function s:ExtractToken(s)
	" Search for a label
	let found = match(a:s, "\\s*\\w\\{-}[^:]:[^:]")
	if found != -1
		return stridx(a:s, ":")
	else
		" Search for a statement
		let found = match(a:s, "[^;]*[^}]\\s*;")
		if found != -1
			return stridx(a:s, ";")
		else
			" Search for the end of a class
			let found = match(a:s, "\\s*}")
			if found != -1
				return stridx(a:s, "}")
			else
				return -1
			endif
		endif
	endif
	return -1
endfunction

function s:DownCheckEOF()
	let before = line(".")
	normal j
	if before >= line(".")
		return 1
	endif
	return 0
endfunction

function s:ParseClass()
	" Get the class name
	exe "normal w\"cye/{\<cr>j"
	let class = getreg('c')

	" Parse the class declaration
	let done = 0
	let pos = -1
	let line = ""

	" Parse a token (label, function or attribute) at a time
	while done == 0
		" Start from where we left off
		if pos == -1 || pos == strlen(line)
			let line = getline(line("."))
			let done = s:DownCheckEOF()
		else
			let line = strpart(line, pos)
		endif

		" Skip single-line comments & empty lines
		while done == 0 && (match(line, "^\\s*//") != -1 || match(line, "^\\s*$") != -1)
			let line = getline(line("."))
			let done = s:DownCheckEOF()
		endwhile

		" Remove comments at end of string
		let comment_pos = match(line, "//")
		if comment_pos != -1
			let line = strpart(line, 0, comment_pos)
		endif

		" Extract a token (label, function or attribute)
		let token_end = -1
		let token_end = s:ExtractToken(line)
		while done == 0 && token_end == -1
			" Suffix a new line (removing comments)
			let newline = getline(line("."))
			let comment_pos = match(newline, "//")
			if comment_pos != -1
				let newline = strpart(newline, 0, comment_pos)
			endif
			let line = line . "\<cr>" . newline
			let done = s:DownCheckEOF()

			" Search for a token
			let token_end = s:ExtractToken(line)
		endwhile
		let token = strpart(line, 0, token_end + 1)
		let pos = token_end + 1

		" Determine token type
		if strpart(token, strlen(token) - 1) == ";"
			" Determine whether we've got a Method or Attribute
			let type = "attribute"
			if match(token, "/[*][*]") != -1
				" Ignore brackets etc. in comments
				if match(token, "/[*][*]\\_.\\{-}[*]/\\_.\\{-}[^{};]*[^;{})]([^{}();]*)[^;(){}0]*;$") != -1
					let type = "method"
				endif
			else
				if match(token, "[^{};]*[^;{})]([^{}();]*)[^;(){}0]*;$") != -1
					let type = "method"
				endif
			endif

			" Method
			if type == "method"
				call s:SwitchWindows()

				" Remove all leading spaces
				let token = substitute(token, "^\\s*", "", "g")

				" Remove 'virtual' and 'static' keywords
				let token = substitute(token, "^virtual ", "", "g")
				let token = substitute(token, "^static ", "", "g")

				" Remove default values
				let token = substitute(token, "\\s*=\\s*[^,)]*", "", "g")

				" Insert class name
				if match(token, "/[*][*]") != -1
					let token = substitute(token, "\\(/[*][*]\\_.\\{-}[*]/\\_.\\{-}\\)\\([~]\\?\\i*\\s*\\)(", "\\1" . class . "::\\2(", "")
				else
					let token = substitute(token, "\\([~]\\?\\i*\\s*\\)(", class . "::\\1(", "")
				endif

				" Remove trailing semicolon
				let token = substitute(token, ";\\s*$", "", "")

				" Separate return type onto new line if requested
				if g:fnTypeSepLine == 1
					if match(token, "\<cr>\\s*" . class . "::") == -1 && match(token, "^\\s*" . class . "::") == -1
						let token = substitute(token, "^\\(\\s*.\\{-}\\)" . class . "::", "\\1\<cr>" . class . "::", "")
					endif
				endif

				" If not requested, remove all comments
				if g:implComments == 0
					let token = substitute(token, "/[*][*].*\<cr>\\s*[*]/\\s*\<cr>", "", "g")
				else
					" Nicely format Doxygen comments for use with C++ syntax macros
					let token = substitute(token, "\\s*/[*][*]", "/**", "")
					"let token = substitute(token, "\\(/[*][*].\\{-}\\) [*] ", "\\1\<cr>", "g")
					let token = substitute(token, "\\(/[*][*].*\\)\<cr>\\s*[*]/\\s*\<cr>", "\\1\<cr>/\<cr>", "g")
					let token = substitute(token, "\<cr>\\s* [*] ", "\<cr>", "g")
					let token = substitute(token, "\<cr>\\s* [*]", "\<cr>", "g")
				endif

				" Remove leading whitespace & newlines
				let token = substitute(token, "^\<cr>*", "", "")
				let token = substitute(token, "^\\s*", "", "g")
				let token = substitute(token, "\<cr>\\s*", "\<cr>", "g")

				" If the functions is abstract then ignore
				if match(token, " = *0 *;$") == -1
					exe "normal ddo" . token . "\<Esc>"
					exe "normal o{\<cr>}\<cr>"

					" Insert spacing after the function
					let i = 0
					while i < g:InterFunctionGap
						exe "normal o\<Esc>"
						let i = i + 1
					endwhile
				endif

				call s:SwitchWindows()
			else
				" Attribute - TODO: Handle static initialisers
			endif
		elseif strpart(token, strlen(token) - 1) == ":"
			" Label - no processing required
		elseif strpart(token, strlen(token) - 1) == "}"
			" End of class
			let done = 1
		else
			" Unknown ??
		endif
	endwhile
endfunction

function! IsExtensionHeader(ext)
	let header = 0
	let i = 1
	let x = "h"
	while x != "" && header == 0
		let x = GetNthItemFromList(g:h_extensions, i)
		if a:ext == x
			let header = 1
		endif
		let i = i + 1
	endwhile
	return header
endfunction

function Implement()
	" Ensure this is a header file
	if IsExtensionHeader(expand("%:e")) != 0
		mark Z

		" Store the buffer number for the header
		let s:h_buf = bufnr('%')

		" Open the implementation in a new window
		let s:file = expand("%:p:r") . "." . g:cxx_extension
		let s:header = expand("%:t")
		silent "w " . s:file
		exe "normal \<c-w>s"
		exe "e " . s:file

		" Store the buffer number for the implementation
		let s:c_buf = bufnr('%')

		" If an implementation didn't already exist
		if filereadable(s:file) == 0
			" Disable folding
			let s:newfold = &l:foldenable
			set nofoldenable

			" Return to original window & disable folding
			call s:SwitchWindows()
			let s:oldfold = &l:foldenable
			set nofoldenable

			call CopyDescriptionToLastWindow()

			" Insert an include line for the header
			call s:SwitchWindows()
			exe "normal Go#include \"" . s:header . "\"\<Esc>o"
			let i = 0
			while i < g:InterFunctionGap
				exe "normal o\<Esc>"
				let i = i + 1
			endwhile

			" Switch back to the header file
			call s:SwitchWindows()

			" Insert any namespace present
			normal gg
			let lastline = line(".")
			try
				exe "normal /namespace\<CR>"
			catch *
			endtry
			if lastline < line(".")
				exe "normal v/{\<cr>\"cy"
				call s:SwitchWindows()
				normal P
				exe "normal /{\<CR>o"
				call s:SwitchWindows()
				let s:Namespace = 1
			else
				let s:Namespace = 0
			endif

			" For each class declared...
			try
				let lastline = -1
				exe "normal /^\\s*class\<CR>"
				while lastline < line(".")
					" Parse the class declaration
					call s:ParseClass()

					" Search for another class
					let lastline = line(".")
					exe "normal /^\\s*class\<CR>"
				endwhile
			catch *
			endtry

			" Re-enable folding and return cursor position (in orig window)
			normal 'Z
			let &l:foldenable = s:oldfold
			call s:SwitchWindows()
			normal dk
			if s:Namespace == 1
				normal O}
			endif
			set nofoldenable
			if g:InterFunctionGap < 2
				exe "normal Go\<Esc>"
			endif
			try
				exe "normal gg/{\\n\\s*}\<CR>"
				exe "normal o"
			catch *
			endtry
		endif
	endif
endfunction

" Function : GetNthItemFromList (PRIVATE)
" Purpose  : Support reading items from a comma seperated list
"            Used to iterate all the extensions in an extension spec
"            Used to iterate all path prefixes
" Args     : list -- the list (extension spec, file paths) to iterate
"            n -- the extension to get
" Returns  : the nth item (extension, path) from the list (extension
"            spec), or "" for failure
" Author   : Michael Sharpe <feline@irendi.com>
"            Taken from the a.vim plugin.
function! GetNthItemFromList(list, n)
   let itemStart = 0
   let itemEnd = -1
   let pos = 0
   let item = ""
   let i = 0
   while (i != a:n)
      let itemStart = itemEnd + 1
      let itemEnd = match(a:list, ",", itemStart)
      let i = i + 1
      if (itemEnd == -1)
         if (i == a:n)
            let itemEnd = strlen(a:list)
         endif
         break
      endif
   endwhile
   if (itemEnd != -1)
      let item = strpart(a:list, itemStart, itemEnd - itemStart)
   endif
   return item
endfunction

command Implement call Implement()

