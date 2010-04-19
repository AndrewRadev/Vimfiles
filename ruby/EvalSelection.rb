#!/usr/bin/env ruby
# EvalSelection.rb -- Evaluate text using an external interpreter
# @Author:      Thomas Link (samul AT web.de)
# @License:     GPL (see http://www.gnu.org/licenses/gpl.txt)
# @Created:     11-Mär-2004.
# @Last Change: 2007-05-09.
# @Revision:    0.323

# require "open3"

$EvalSelectionTalkers = Hash.new

class EvalSelectionAbstractInterpreter
    attr :iid
    attr_accessor :active
    
    def initialize
        @iid    = ""
        @menu   = false
        @menu_entries = []
        setup
        @active = initialize_communication
    end

    def setup 
        raise "#setup must be overwritten!"
    end

    def build_vim_menu(menu_name, list, menu_function, keys={})
        if VIM::evaluate(%{has("menu")})
            extra_menu = keys[:extra]
            remove_menu unless extra_menu
            ls         = list.sort
            menu_mode  = keys[:mode] || "a"
            menu_max   = VIM::evaluate(%{g:evalSelectionMenuSize}).to_i
            menu_break = ls.size > menu_max ? ls.size / menu_max : nil
            if menu_break
                menu_sub = 0
                menu_titles = []
                for i in 0..menu_break
                    j    = i * menu_max
                    from = ls[j]
                    to   = ls[j + menu_max - 1] || ls[-1]
                    menu_titles << %{&#{escape_menu(from)}\\ \\.\\.\\ #{escape_menu(to)}.}
                end
                    # menu_pre = menu_titles[0]
            else
                menu_pre = ""
            end
            menus = []
            sep   = false
            if keys[:update]
                VIM::command(%{amenu &#{menu_name}.&Update #{keys[:update]}}) 
                sep = true
            end
            if keys[:exit]
                VIM::command(%{amenu &#{menu_name}.&Exit #{keys[:exit]}}) 
                sep = true
            end
            if keys[:remove_menu]
                VIM::command(%{amenu &#{menu_name}.&Remove\\ Menu #{keys[:remove_menu]}})
                sep = true
            end
            if sep
                VIM::command(%{amenu &#{menu_name}.-Sep#{menu_name}- :})
            end
            ls.each_with_index do |i, idx|
                if menu_break and idx % menu_max == 0
                    menu_pre = menu_titles[menu_sub]
                    menu_sub += 1
                end
                VIM::command(%{#{menu_mode}menu &#{menu_name}.#{menu_pre}&#{escape_menu(i)} #{menu_function.call(i)}})
            end
            @menu = true
            @menu_entries << menu_name unless extra_menu
        end
    end
    
    def build_menu(initial=false)
    end

    def remove_menu
        if @menu and VIM::evaluate(%{has("menu")})
            @menu_entries.each do |e|
                # DBG begin
                    # VIM::command(":aunmenu #{e.gsub(/\\/, "\\\\\\\\"}}")
                    # VIM::command(%{:echom "Remove menu for: #{e}"})
                    VIM::command(%{:aunmenu #{e}})
                # rescue
                # end
            end
            @menu = false
            @menu_entries = []
        end
    end
    
    def initialize_communication
        raise "#initialize_communication must be overwritten!"
    end
    
    def tear_down
        raise "#tear_down must be overwritten!"
    end

    def interact(text)
        raise "#talk must be overwritten!"
    end
    
    def talk(text)
        blabber = text.gsub(/(["])/, '\\\\\1')
        VIM::command(%Q{let g:evalSelLastCmd   = "#{blabber}"})
        VIM::command(%Q{let g:evalSelLastCmdId = "#{@iid}"})
        # puts interact(text)
        rv = interact(text)
        if rv
            for i in rv
                puts i
            end
        end
    end

    def postprocess(text)
        text
    end
end

class EvalSelectionInterpreter < EvalSelectionAbstractInterpreter
    def initialize
        @ioIn        = nil
        @ioOut       = nil
        @ioErr       = nil
        @interpreter = nil # The command-line to start the interpreter
        @printFn     = nil # The function that prints %{BODY}'s result and a record marker
        @quitFn      = nil # The function that quits the interpreter
        @recEndChar  = nil # A character end of record mark (default=ESCAPE)
        @recPromptRx = nil # A ruby pattern marking an empty prompt line
        @markFn      = nil # Mark end of output
        @recMarkRx   = nil # Match end of output
        @bannerEndRx = nil # skip banner until this regexp matches
        @recSkip     = 0   # skip first N records
        @useNthRec   = 0   # Use every Nth+1 record
        super
    end
    
    def initialize_communication
        unless @ioIn
            # there is no popen3 under Windows
            # @ioIn, @ioOut, @ioErr = Open3.popen3(@interpreter)
            @ioIn = @ioOut = IO.popen(@interpreter, File::RDWR)
            listen(true) if @bannerEndRx or @recSkip > 0
            return @ioIn != nil
        end
    end
    
    def tear_down 
        if @ioOut
            begin
                @ioOut.puts(@quitFn)
                @ioOut.close
            rescue
            end
            @ioIn = @ioOut = @ioErr = nil
        end
        return !@ioOut
    end
    
    def interact(text)
        say(text)
        # listen().gsub(/(["])/, "'")
        listen()
    end
    
    def say(body) 
        #+++ use look back rx
        pr = @printFn.gsub(/(^|[^%])%\{BODY\}/, "\\1#{body}")
        pr.gsub!(/%%/, "%")
        pr += @markFn if @markFn
        @ioOut.puts(pr)
    end

    def listen(atStartup=false)
        if atStartup
            if @bannerEndRx
                recMarkRx = @bannerEndRx
                ign       = 0
            elsif @recSkip > 0
                recMarkRx = nil
                ign       = @recSkip - 1
            else
                return ""
            end
        else
            ign       = @useNthRec
            recMarkRx = @recMarkRx
        end
        unless (@recEndChar || @recPromptRx || recMarkRx)
            raise "Either @recEndChar, @recMarkRx, or @recPromptRx must be non-nil!"
        end
        if @recPromptRx or recMarkRx
            markRx = /#{(recMarkRx || "") + (@recPromptRx || "")}$/
        else
            markRx = nil
        end
        if ign < 0
            return ""
        else
            # VIM::message(markRx.inspect)
            if VIM::evaluate("g:evalSelectionDebugLog") != "0"
                VIM::evaluate(%{EvalSelectionLog("'DBG:'")})
            end
            while ign >= 0
                ign -= 1
                l    = ""
                until @ioIn.eof
                    c = @ioIn.getc()
                    if @recEndChar and c == @recEndChar
                        break
                    else
                        if VIM::evaluate("g:evalSelectionDebugLog") != "0"
                            VIM::evaluate(%{EvalSelectionLog("#{("\"%c\"" % c).gsub(/"/, '\\\\"').gsub(/^\s*$/, "")}", 1)})
                        end
                        l << c
                        # VIM::message(l)
                        if markRx and l =~ markRx
                            l.sub!(markRx, "")
                            break
                        end
                    end
                end
            end
            l = postprocess(l)
            return l
        end
    end
end

class EvalSelectionStdInFileOut < EvalSelectionInterpreter
    def initialize
        @outfile = nil
        super
        unless @outfile
            raise "@outfile must be defined!"
        end
    end
    
    def listen(atStartup=false)
        # rv = File.open(@outfile) {|io| io.read}
        # # VIM::command(%{echom "#{rv}"})
        # rv
        File.open(@outfile) {|io| io.read}
    end
end

class EvalSelectionOLE < EvalSelectionAbstractInterpreter
    attr :ole_server

    def initialize
        @ole_server = nil
        super
    end

    def initialize_communication
        ole_setup unless @ole_server
        return @ole_server != nil
    end
    
    def interact(text)
        m = /^#(\w+)(\s.*)?$/.match(text)
        if m
            args = [m[1]]
            text = m[2]
            while (m = /^(\s+("(\\"|[^"])*"|([0-9]+)|(\S+)))/.match(text))
                if m[3]
                    args << m[3]
                elsif m[4]
                    args << m[4].to_i
                elsif m[5]
                    args << m[5]
                else
                    raise "EvalSelection: Parse error: #{text}"
                end
                text = m.post_match
            end
            if text.nil? or text.empty?
                rv = @ole_server.send(*args)
            else
                raise "EvalSelection: Parse error: #{text}"
            end
        else
            begin
                rv = postprocess(ole_evaluate(text))
            rescue WIN32OLERuntimeError => e
                VIM::command(%{echohl Error})
                for l in e.to_s
                    VIM::command(%{echo "#{l.gsub(/"/, '\\\\"')}"})
                end
                VIM::command(%{echohl None})
            end
        end
        if rv.kind_of?(Array)
            rv.shift if rv.first == ""
            rv.pop if rv.last == ""
            rv.collect {|e| "%s" % e}.join("\n")
        elsif rv.nil?
            rv
        else
            "%s" % rv
        end
    end

    def tear_down
        if @ole_server
            begin
                ole_tear_down
            rescue
            end
        # else
        end
        true
    end
    
    def ole_setup
        raise "#setup must be overwritten!"
    end

    def ole_tear_down
        raise "#setup must be overwritten!"
    end

    def ole_evaluate(text)
        raise "#setup must be overwritten!"
    end

    alias :ole_evaluate_no_return :ole_evaluate
end

module EvalSelection
    module_function

    def withId(id, *args)
        i = $EvalSelectionTalkers[id]
        if i
            i.send(*args)
        else
            VIM::command(%Q{throw "EvalSelectionTalk: Set up interaction with #{id} first!"})
        end
    end
    
    def setup(name, interpreterClass, quiet=false)
        i = $EvalSelectionTalkers[name]
        if !i
            i = interpreterClass.new
            if i
                $EvalSelectionTalkers[i.iid] = i
                i.build_menu(true)
            end
            if VIM::evaluate(%{exists("*EvalSelectionPostSetup_#{name}")}) == "1"
                VIM::command(%{call EvalSelectionPostSetup_#{name}()})
            end
        elsif !quiet
            VIM::command(%Q{echom "EvalSelection: Interaction with #{name} already set up!"})
        end
        return i
    end

    def talk(id, text) 
        withId(id, :talk, text)
    end
   
    def tear_down(id)
        remove_menu(id)
        if withId(id, :tear_down)
            $EvalSelectionTalkers[id] = nil
            if VIM::evaluate(%{exists("*EvalSelectionPostTearDown_#{name}")}) == "1"
                VIM::command(%{call EvalSelectionPostTearDown_#{name}())})
            end
        else
            VIM::command(%Q{echoerr "EvalSelection: Can't stop #{id}!"})
        end
    end

    def tear_down_all
        $EvalSelectionTalkers.each do |id, interp|
            begin
                if interp and interp.tear_down
                    $EvalSelectionTalkers[id] = nil
                end
            rescue Exception => e
                VIM::command(%{echom "Error when shutting down #{id}"})
            end
        end
    end

    def remove_menu(id)
        begin
            withId(id, :remove_menu)
        rescue Exception => e
            VIM::command(%{echom "Error when removing the menu for #{id}"})
        end
    end
    
    def build_menu(id)
        begin
            withId(id, :build_menu)
        rescue Exception => e
            VIM::command(%{echom "Error when building the menu for #{id}"})
        end
    end

    def update_menu(id)
        begin
            remove_menu(id)
            build_menu(id)
        rescue Exception => e
            VIM::command(%{echom "Error when updating the menu for #{id}"})
        end
    end
end

# vim: ff=unix
