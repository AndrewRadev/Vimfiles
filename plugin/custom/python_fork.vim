python << PYTHON
import threading
import time
import vim

class Counter(threading.Thread):
  def run(self):
    self.done = False

    i = 1
    while not self.done:
      vim.command("let g:custom_status = {0}".format(i))
      vim.command("let &ro = &ro")
      time.sleep(1)
      i += 1

counter = Counter()

PYTHON

command! SetupThreadDemo let g:custom_status = 0 | set statusline=%{g:custom_status}
command! StartThreadDemo python counter.start()
command! StopThreadDemo python counter.done = True

autocmd VimLeavePre * StopThreadDemo
