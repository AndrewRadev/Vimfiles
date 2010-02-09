exec scriptmanager#DefineAndBind('s:c','g:vim_bg', '{}')

let s:vim = get(s:c,'vim', 'vim')

" you can use hooks to change colorscheme or such
" event one of start / stop
fun! bg#CallEvent(event)
  if has_key(s:c, a:event)
    call funcref#Call(s:c[a:event])
  endif
endf

fun! bg#ShEscape(...)
  return map(copy(a:000), 'escape(v:val,'.string("\"\\' ();{}").')')
endf

fun! bg#ListToCmd(cmd)
  if type(a:cmd) == type('')
    return a:cmd
  else
    return join(call("bg#ShEscape",a:cmd)," ")
  endif
endfun

fun! bg#Run(cmd, outToTmpFile, onFinish)
  call bg#CallEvent("start")
  let S = function('bg#ShEscape')

  let cmd = bg#ListToCmd(a:cmd)
  if a:outToTmpFile
    let tmpFile = tempname()
    let cmd .=  ' &> '.shellescape(tmpFile)
    let escapedFile = ','.S(string(tmpFile))[0]
  else
    let escapedFile = ''
  endif

  " call back into vim using client server feature.. This seams to be the only
  " thread safe way
  if has('clientserver')
    " force usage of /bin/sh
    let cmd .= '; '.s:vim.' --servername '.S(v:servername)[0].' --remote-send \<esc\>:debug\ call\ funcref#Call\('.S(string(a:onFinish))[0].',\[$?'.escapedFile.'\]\)\<cr\>' 
    echom cmd
    call system('/bin/sh',cmd.'&')
  else
    " fall back using system
    call system('/bin/sh',cmd)
    call funcref#Call(a:onFinish, [v:shell_error] + (a:outToTmpFile ? [tmpFile] : []))
    call bg#CallEvent("stop")
  endif
endf

" file either c for quickfix or l for location list
fun! bg#RunQF(cmd, file, ...)
  let efm = a:0 > 0 ? a:1 : 0
  call bg#Run(a:cmd, 1, library#Function('bg#LoadIntoQF', { 'args' : [efm, a:file]}))
endf

fun! bg#LoadIntoQF(efm, f, status, file)
  if a:efm != 0
    exec 'set efm='.a:efm
  endif
  exec a:f.'file '.a:file
endf

finish
" old code. Can be revived

  " =======================  run handlers ======================================
  fun! tovl#runtaskinbackground#RunHandlerPython(process)
    if !has('python') | throw "RunHandlerPython: no python support" | endif
    if get(a:process, 'fg', 0) && !has('clientserver') | throw "RunHandlerPython: no client server support!" | endif
    let vim = tovl#runtaskinbackground#Vim()
    " lets hope this vim has clientserver support..

    throw "untested.. the sh way works fine.. So I will only test and fix this if someone needs it"

  " if you know a better solution than using g:vimPID than mail me!
  let g:vimPID=a:process['id']
  let g:use_this_vim = vim
  let g:tempfile = a:process['tempfile']
  py << EOF
  vimPID = vim.eval("g:vimPID")
  thisOb = "config#GetG(''tovl#running_background_processes'')[%s]"%(vimPID)
  thread=MyThread(thisOb, vim.eval("g:use_this_vim"), vim.eval("v:servername"), vim.eval("v:tempfile"))
  thread.start()
  EOF
    unlet g:vimPID
    unlet g:use_this_vim
    unlet g:tempfile
    return [1,"python thread started"]
  endf

  fun! s:CallVimUsingSh(vim,vimcmd)
    " intentionally no quoting to pass $$ and $?
    let S = function('tovl#runtaskinbackground#EscapeShArg')
    return S(a:vim)." --servername ".S(v:servername).' --remote-send \<esc\>:'.a:vimcmd.'\<cr\>' 
  endfun

  if exists('g:pythonthreadclassinitialized') || !has('python')
    finish
  endif
  let g:pythonthreadclassinitialized=1
  py << EOF
  from subprocess import Popen, PIPE
  import threading
  import os
  import vim
  class MyThread ( threading.Thread ):
    def __init__(self, thisOb, vim, servername, tempfile):
      threading.Thread.__init__(self)
      self.thisOb = thisOb
      self.command = vim.eval("%s['realCmd']"%(thisOb))
      self.vim = vim
      self.tempfile = tempfile
      self.servername = servername

    def run ( self ):
      try:
        popenobj  = Popen(self.cmd,stdout=PIPE,stderr=PIPE)
        self.executeVimCommand("%s.SetProcessId(%s)"%(self.thisOb,popenobj.pid))
        stdoutwriter = open(self.tempfile,'w')
        stdoutwriter.writelines(popenobj.stdout.readlines())
        stdoutwriter.writelines(popenobj.stderr.readlines())
        stdoutwriter.close()
        popenobj.wait()
        self.executeVimCommand("%s.Finished(%d)"%(self.thisOb,popenobj.returncode))
      except Exception, e:
        self.executeVimCommand("echoe '%s'"%("exception: "+str(e)))
      except:
        # I hope command not found is the only error which might  occur here
        self.executeVimCommand("echoe '%s'"%("command not found"))
    def executeVimCommand(self, cmd):
      # can't use vim.command! here because vim hasn't been written for multiple
      # threads. I'm getting Xlib: unexpected async reply (sequence 0x859) ;-)
      # will use server commands again
      popenobj = Popen([self.vim,"--servername","%s"%(self.servername),"--remote-send","<esc>:%(cmd)s<cr>"%locals()])
      popenobj.wait()
  EOF


  " Thanks to Luc Hermitte <hermitte@free.fr> for his suggestions
  " He has written a similar script which can be found here:
  "     <http://hermitte.free.fr/vim/ressources/lh-BTW.tar.gz> (still in an
  "     alpha stage.)
  "     --
  "      Luc Hermitte
  "      http://hermitte.free.fr/vim/
