" Superior Haskell Interaction Mode (SHIM) {{{
" ==============================================================================
" Copyright: Lars Kotthoff <lars@larsko.org> 2008,2009
"            Released under the terms of the GPLv3
"            (http://www.gnu.org/copyleft/gpl.html)
" Name Of File: shim.vim
" Version: 0.3.3
" Description: GHCi integration for VIM
" Requirements: VIM or gVIM with Ruby support, Ruby, and GHCi.
" Installation: Copy this file into the plugin/ subdirectory of your vim
"               installation -- /etc/vim/ for system-wide installation,
"               .vim/ for user installation. Alternatively, you can manually
"               source the file with ":source shim.vim".
" Usage: The file exposes 4 commands, GhciFile, GhciRange, GhciReload, and
"        GhciInit. The first takes no arguments and loads the current buffer
"        into GHCi (":l <file>"). If autowrite is set and the buffer has been
"        modified, the buffer is written before it is loaded. The second command
"        takes a range as an argument and pastes these lines into GHCi without
"        any interpretation. The third command kills GHCi, clears the ghci
"        buffer, and restarts GHCi. Note that it doesn't reload any files. The
"        fourth command sets up GHCi and the VIM buffer and window for it. You
"        should never need to call this manually; it may be helpful to recover
"        GHCi after something went wrong though.
"
"        You can bind these functions to key combinations for quicker access,
"        e.g. put something like
"
"        autocmd FileType haskell nmap <C-c><C-l> :GhciRange<CR>
"        autocmd FileType haskell vmap <C-c><C-l> :GhciRange<CR>
"        autocmd FileType haskell nmap <C-c><C-f> :GhciFile<CR>
"        autocmd FileType haskell nmap <C-c><C-r> :GhciReload<CR>
"
"        into your .vimrc or .gvimrc.
"
"        The first time you run any of these functions, GHCi will be started
"        automatically in a split window below the current one. You can
"        customize the following options:
"
"        g:shim_ghciInterp -- the name of the GHCi executable, default "ghci"
"        g:shim_ghciArgs -- extra arguments passed to GHCi, default ""
"        g:shim_ghciPrompt -- a regular expression matching the GHCi prompt
"        g:shim_ghciTimeout -- the timeout for waiting for GHCi to return after
"                              sending commands, default 10 seconds
"        g:shim_jumpToGhci -- whether to jump to the GHCi window after executing
"                             a GHCi command, default "false"
"        g:shim_quickfix -- whether to integrate SHIM with quickfix (more on
"                           that below), default "true"
"        g:shim_defaultWindowSize -- the height of the GHCi window, default 15
"
"        When quickfix integration is turned on, the output received from GHCi
"        is passed through quickfix to find any errors. This means that you get
"        a list of errors and the cursor is automatically put to the position of
"        the first error. See :help quickfix for more details.
"        If this feature is not working properly for you, you probably need to
"        set the error format for GHC output; you can find Haskell mode for VIM,
"        which includes an error format, at
"        http://www.cs.kent.ac.uk/people/staff/cr3/toolbox/haskell/Vim/.
"        Note that this only applies if a file is loaded into GHCi, as there is
"        no possibility of pinpointing the error position in a file if only a
"        part of the file is passed to GHCi with the GhciRange function.
"
"        The "ghci" buffer behaves much like an actual GHCi prompt. The cursor
"        is always positioned after the last prompt and <CR> is remapped to
"        GhciRange for the current line, i.e. you can start typing after the
"        prompt and hit <Enter> and the line you typed is sent to GHCi, the
"        output appended to the buffer. The prompt text is stripped off before
"        passing the text on to GHCi.
"
"        GHCi is quit automatically when you quit VIM or destroy the "ghci"
"        buffer.
" ==============================================================================
" }}}

if has("ruby")

if !exists('g:shim_ghciInterp')
    let g:shim_ghciInterp = "ghci"
endif
if !exists('g:shim_ghciPrompt')
    let g:shim_ghciPrompt = "^[\*A-Z][A-Za-z\. ]+>"
endif
if !exists('g:shim_ghciTimeout')
    let g:shim_ghciTimeout = 10
endif
if !exists('g:shim_jumpToGhci')
    let g:shim_jumpToGhci = "false"
endif
if !exists('g:shim_quickfix')
    let g:shim_quickfix = "true"
endif
if !exists('g:shim_defaultWindowSize')
    let g:shim_defaultWindowSize = 15
endif
if !exists('g:shim_ghciArgs')
    let g:shim_ghciArgs = ""
endif

command! GhciReload ruby ghci.reloadGhci
command! GhciInit ruby ghci.initGhciBuffer
command! GhciFile ruby ghci.ghciSourceFile
command! -range GhciRange ruby ghci.writeRangeToGhci(<line1>, <line2>)

ruby << EOF
module VIM
	class Buffer
		class << self
			def getForName(name)
				(0...self.count).each { |i|
					return self[i] if self[i].name =~ name
				}
			end
		end
	end

	class Window
		class << self
			def forBufferNumber(bufferNumber)
				(0...self.count).each { |i|
					return self[i] if self[i].buffer.number == bufferNumber
				}
                return nil
			end

			def number(window)
				(0...self.count).each { |i|
					return i + 1 if self[i] == window
				}
			end
		end
	end
end
EOF

ruby << EOF
require 'expect'

class Ghci
	def initialize
		@ghciInterp = VIM::evaluate("g:shim_ghciInterp")
		@ghciArgs = VIM::evaluate("g:shim_ghciArgs")
		@ghciPrompt = Regexp.new(VIM::evaluate("g:shim_ghciPrompt"))
		@ghciTimeout = VIM::evaluate("g:shim_ghciTimeout").to_i
		@jumpToGhci = VIM::evaluate("g:shim_jumpToGhci") == "true" ? true : false
		@quickfix = VIM::evaluate("g:shim_quickfix") == "true" ? true : false
		@defaultWindowSize = VIM::evaluate("g:shim_defaultWindowSize").to_i

		@buffer = nil
		@pipe = nil
	end

	def setupWindow
		originatorWin = VIM::Window.current
		VIM::command("below split +e ghci")
		VIM::command("res " + @defaultWindowSize.to_s)
		VIM::command("setlocal buftype=nofile noswapfile filetype=haskell")
		VIM::command("imap <buffer> <CR> <Esc>:GhciRange<CR>a")

		@buffer = VIM::Buffer.getForName(Regexp.new(Regexp.escape(File::Separator) + "ghci$"))

		VIM::command(VIM::Window.number(originatorWin).to_s + "wincmd w") unless @jumpToGhci
	end

	def initGhciBuffer
		setupWindow
                openGhci
	end

    def openGhci
		@ghciArgs = VIM::evaluate("g:shim_ghciArgs")
		# ghci writes some stuff to stderr...
		@pipe = IO.popen(@ghciInterp + " " + @ghciArgs + " 2>&1", File::RDWR)
		readFromGhci
    end

	def closeGhci
		if(!@pipe.nil?)
			@pipe.syswrite(":q\n")
			@pipe.close
			@pipe = nil
		end
	end

    def reloadGhci
		if(@pipe.nil?)
            openGhci
        else
            closeGhci
            @buffer.length.times { @buffer.delete(1) }
            openGhci
        end
    end

	def readFromGhci
		if(!@buffer.nil? && !@pipe.nil?)
			output = @pipe.expect(@ghciPrompt, @ghciTimeout)
			break if output.nil?
			text = output.join("\n").strip + " "

			text.split(/\r?\n/).each { |line|
				@buffer.append(@buffer.count, line)
			}

			originatorWin = VIM::Window.current
			window = VIM::Window.forBufferNumber(@buffer.number)

			if(@quickfix)
				VIM::command("cex " + text.inspect) unless text =~ /<interactive>/
			end
			
			window.cursor = [ @buffer.count, @buffer[@buffer.count].length ] unless window.nil?

			if(@buffer.number != VIM::Window.current.buffer.number && !window.nil?)
				# switch to the ghci window and refresh it to
				# make sure the new output is visible, then switch
				# back unless we wanted to go there anyway
				VIM::command(VIM::Window.number(window).to_s + "wincmd w")
				VIM::command("redraw")
				VIM::command(VIM::Window.number(originatorWin).to_s + "wincmd w") unless @jumpToGhci
			end
		else
			VIM::message("Ghci buffer or pipe isn't open!")
		end
	end

	def writeToGhci(text)
		text.strip!
		if(text.length > 0)
			initGhciBuffer if @buffer.nil?

			if(!@buffer.nil? && !@pipe.nil?)
                # if the input matches the prompt, it was typed
                # in the interpreter window and we don't need to
                # echo it; also remove it before passing it on to ghci
				if(!(text =~ @ghciPrompt).nil?)
					text.gsub!(@ghciPrompt, "")
				else
					text.split(/\r?\n/).each { |line|
						@buffer.append(@buffer.count, line)
					}
				end

                begin
                    @pipe.syswrite(text + "\n")
                rescue SystemCallError
                    VIM::message("Restarting Ghci, write failed: " + $!)
                    openGhci
                    retry
                end
				readFromGhci
			else
				VIM::message("Ghci buffer or pipe isn't open!")
			end
		end
	end

	def ghciSourceFile
		autowrite = VIM::evaluate("&autowrite")
		modified = VIM::evaluate("&mod")
		VIM::command("w") if((modified == "1") && (autowrite == "1"))
		writeToGhci(":l " + VIM::Buffer.current.name)
	end

	def writeRangeToGhci(line1, line2)
		text = []
		(line1..line2).each { |i|
			text << VIM::Buffer.current[i]
		}
		writeToGhci(text.join("\n"))
	end
end
ghci = Ghci.new
EOF

autocmd BufDelete ghci ruby ghci.closeGhci
autocmd VimLeavePre * ruby ghci.closeGhci

endif
