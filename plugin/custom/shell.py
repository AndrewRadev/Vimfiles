#import vim
import sys
from time import sleep
from threading import Thread
from subprocess import Popen, PIPE

class VimShell(Thread):
    def __init__(self, cmd):
        # thread configuration
        Thread.__init__(self)
        self.daemon = True

        self.cmd    = cmd
        self.shell  = Popen('irb', stdout = PIPE, stdin = PIPE)
        self.input  = self.shell.stdin
        #self.input = sys.stdout
        self.output = self.shell.stdout
        #self.buf    = vim.current.buffer

    def new(self):
        #vim.command('new')
        #vim.command('set bufhidden=hide')
        #self.buf = vim.current.buffer
        return self

    def run(self):
        while True:
            self.write(self.output.read(10))

    def write(self, msg):
        #self.buf.append(msg)
        print(msg)

    def message(self, msg):
        self.input.write(msg.encode())

shell = VimShell('irb').new()
shell.start()

while True:
    input = sys.stdin.readline()
    shell.message(input)
