#! /usr/bin/env python
# File: vimmpc.py
# About: Wrapper around basic MPD functionality
# Author: Gavin Gilmour (gavin (at) brokentrain dot net)
# Last Modified: September 07, 2009
# Version: 20070410
# Note: Please see the accompanying README.


from __future__ import division

import difflib
import os
import re
import sys
import time
from time import gmtime, strftime

import vim
import mpd

DEBUG = False
BUFFERS = {}

def debug(message):
    if DEBUG:
        output("MPC DEBUG: %s" % message)

def output(msg):
    print "[%s] %s" % (strftime("%m/%d/%y %H:%M:%S", gmtime()), msg)

class MPC:

    class ProgressBar:
        def __init__(self, minValue = 0, maxValue = 100, totalWidth=80):
            self.progBar = "[]"
            self.min = minValue
            self.max = maxValue
            self.span = maxValue - minValue
            self.width = totalWidth
            self.amount = 0
            self.percentDone = 0

        def setStep(self, newAmount):
            if newAmount < self.min:
                newAmount = self.min
            if newAmount > self.max:
                newAmount = self.max
            self.percentDone = newAmount
            self.save()

        def save(self):

            # Figure out how many hash bars the percentage should be
            allFull = self.width - 2
            numHashes = (self.percentDone / 100.0) * allFull
            numHashes = int(round(numHashes))

            if numHashes == 0:
                self.progBar = "[>%s]" % (' '*(allFull-1))
            elif numHashes == allFull:
                self.progBar = "[%s]" % ('='*allFull)
            else:
                self.progBar = "[%s>%s]" % ('='*(numHashes-1),
                                            ' '*(allFull-numHashes))

            percentPlace = (len(self.progBar) / 2) - len(str(self.percentDone))
            percentString = str(self.percentDone) + "%"

            self.progBar = ''.join([self.progBar[0:percentPlace], percentString,
                                    self.progBar[percentPlace+len(percentString):]
                                    ])
        def __str__(self):
            return str(self.progBar)

        def __call__(self, value):
            print '\r',
            sys.stdout.write(str(self))
            sys.stdout.flush()

    def __init__(self, filename):
        self.filename = filename
        self.buffer = vim.current.buffer
        self.originalbuffer = []
        self.window = vim.current.window
        self.track = {}
        self.status = {}
        self.regex = re.compile(r'#(\d+).*')
        self.stopAfterPlaying = False
        self.mpd = mpd.MPDClient()
        self.mpd.connect("localhost", 6600)

    def readPlaylist(self):
        self.playlist = self.mpd.playlistinfo()

    def checkForChange(self):

        # Autofocus playlist?
        if vim.eval(auto_focus) == '1':
            if self.getCurrentTrack() != self.track:
                if self.stopAfterPlaying:
                    self.stopAfterPlaying = False
                    self.stop()
                else:
                    self.highlightCurrent()

        self.getTrackInfo()
        self.drawStatusbar()

        vim.command('call feedkeys("\x80\xFD\x35")')

    def clearPlaylist(self, mpd=False):
        if mpd:
            self.mpd.clear()

        self.buffer[:] = None
        self.drawBanner()

    def displayPlaylist(self):
        self.clearPlaylist()
        debug("Populating playlist..")

        if playlist_mode == "folded":
            album = None
            artist = None
            palbum = None
            in_fold = False

            for track in self.playlist:
                if track.has_key("album"):
                    album = track["album"]
                if track.has_key("artist"):
                    artist = track["artist"]
                if palbum != None and palbum != album or not album:
                    if in_fold:
                        self.buffer.append("}}}")
                        in_fold = False
                    if album and artist:
                        self.buffer.append("{{{ %s - %s" % (artist, album))
                        in_fold = True
                    palbum = album

                if track.has_key("album"):
                    palbum = track["album"]
                else:
                    if palbum and in_fold:
                        self.buffer.append("}}}")
                        in_fold = False

                if track.has_key("artist") and track.has_key("title"):
                    self.buffer.append("#%s) %s - %s" 
                            % (track["id"], track["artist"], track["title"]))
                else:
                    self.buffer.append("#%s) %s" % (track["id"], track["file"]))
        else:
            for track in self.playlist:
                if track.has_key("artist") and track.has_key("title"):
                    self.buffer.append("#%s) %s - %s" 
                            % (track["id"], track["artist"], track["title"]))
                else:
                    self.buffer.append("#%s) %s" % (track["id"], track["file"]))

        self.originalbuffer = self.buffer[:]

    def drawBanner(self):
        conn = self.mpd
        self.buffer[-1] = "Playlist length: %s" % conn.status()['playlist']
        if conn.status().has_key('time'):
            self.buffer.append("Total time: %s" % conn.status()['time'])
        self.buffer.append('-'*25)
        self.buffer.append('')

    def drawStatusbar(self):
        statusText = "%state: %artist - %title (%elapsed/%total)\
                %=Random: [%random] Repeat: [%repeat]"

        statusText = statusText.replace(" ", "\ ")

        if self.track.has_key('artist') and self.track.has_key('title'):
            artist = self.track['artist'].replace(" ", "\ ")
            title = self.track['title'].replace(" ", "\ ")
            statusText = statusText.replace("%artist", artist)
            statusText = statusText.replace("%title", title)
        elif self.track.has_key('file'):
            file = self.track['file'].replace(" ", "\ ")
            statusText = statusText.replace("%artist", file)
            statusText = statusText.replace("%title", '')

        statusText = statusText.replace("%random", self.status['random'] and
        'x' or '_')
        statusText = statusText.replace("%repeat", self.status['repeat'] and
        'x' or '_')
        statusText = statusText.replace("%state", self.status['state'])

        if self.status.has_key('time'):
            totalTime = self.status['time'].split(':')
            currentElapsed = int(totalTime[0])
            trackLength = int(totalTime[1])

#            bar = self.ProgressBar(0, 100, 30)
#            bar.setStep(int((currentElapsed/trackLength)*100))
#            bar = str(bar)
#            bar = bar.replace(" ", "\ ")
#            bar = bar.replace("%", "%%")
#            statusText = statusText.replace("%bar", bar)

            statusText = statusText.replace("%elapsed",
                    time.strftime("%M:%S", time.gmtime(currentElapsed)))

            statusText = statusText.replace("%total",
                    time.strftime("%M:%S", time.gmtime(trackLength)))

        vim.command("silent! setlocal statusline=%s" % statusText)

    def getFocusId(self):
        try:
            cursor_row, cursor_col = self.window.cursor
            self.current_line = self.buffer[cursor_row-1]
            current_char = self.current_line[cursor_col-1]

            # It'd be nice if we could use some sort of model instead of this junk
            if self.current_line.startswith("#"):
                return self.regex.findall(self.current_line)[0]
        except IndexError:
            return None

    def playSelection(self):
        id = self.getFocusId()
        if id:
            self.mpd.playid(int(id))
            self.highlightCurrent()

    def highlightCurrent(self):
        try:
            id = self.mpd.currentsong()['id']
            vim.command("match none")
            vim.command("call search('^#%s)', 'w')" % id)
            vim.command("exe 'match Visual /^#%s.*/'" % id)

            # Open a fold if we're in folded mode
            if playlist_mode == "folded":

                # Don't open a fold if the current track isn't IN one!
                if vim.eval("foldlevel('.')") != '0':
                    vim.command("normal zo")

            vim.command("normal z.")
        except KeyError:
            pass

    def diffPlaylist(self):
        output('\n'.join(difflib.context_diff(self.originalbuffer,
            self.buffer)))

    def destroyPlaylist(self):
        debug('Cleaning up buffer')
        vim.command('au! BufDelete ' + self.filename)
        vim.command('silent! bdelete! ' + self.filename)
        MPC_removeBuffer(self.filename)

    def playPause(self):
        self.getTrackInfo()
        if self.status['state'] == 'stop' or self.status['state'] == 'pause':
            self.mpd.play()
        elif self.status['state'] == 'play':
            self.mpd.pause(1)

    def stop(self):
        self.mpd.stop()

    def next(self):
        self.mpd.next()
        self.highlightCurrent()

    def prev(self):
        self.mpd.previous()
        self.highlightCurrent()

    def update(self):
        self.mpd.update()
        output("Updating database..")

    def enqueueTrack(self):
        buffer = vim.current.buffer
        window = vim.current.window
        cursor_row, cursor_col = window.cursor
        current_line = buffer[cursor_row-1]

        filename = self.mpd.find('title', current_line)

        if not filename:
            filename = self.mpd.find('file', current_line)

        self.mpd.add(filename[0]['file'])
        output("Added %s to playlist" % filename[0]['file'])

    def showDatabase(self):
        filename = "Database"
        exists = MPC_createBuffer(filename, database_type, 
                database_direction, database_size, "database")

        if not exists:
            buffer = vim.current.buffer
            for entry in self.mpd.lsinfo():
                folder = entry['directory']
                tracks = self.mpd.listallinfo(entry['directory'])
                buffer.append("{{{ %s" % folder)
                for track in tracks:
                    if track['type'] == 'file':
                        try:
                            buffer.append(track['title'])
                        except KeyError:
                            buffer.append(track['file'])
                    else:
                        buffer.append(track['directory'])
                buffer.append("}}}")

        else:
            debug("Closing '%s'" % filename)
            mpc = MPC_lookupBuffer(filename)
            vim.command('au! BufDelete ' + filename)
            vim.command('silent! bdelete! ' + filename)
            MPC_removeBuffer(filename)

    def toggleShuffle(self):
        self.getTrackInfo()
        if self.status['random']:
            self.mpd.random(0)
            output("Random off")
        else:
            self.mpd.random(1)
            output("Random on")

    def toggleStopAfterPlaying(self):
        if self.stopAfterPlaying:
            output("Resuming playlist!")
            self.stopAfterPlaying = False
        else:
            output("Stopping after current!")
            self.stopAfterPlaying = True

    def toggleRepeat(self):
        self.getTrackInfo()
        if self.status['repeat']:
            self.mpd.repeat(0)
            output("Repeat off")
        else:
            self.mpd.repeat(1)
            output("Repeat on")

    def showInfo(self):
        id = self.getFocusId()
        if id:
            output(self.mpd.playlistid(int(id)))

    def updatePlaylist(self):
        self.clearPlaylist()
        self.readPlaylist()
        self.displayPlaylist()

    def getTrackInfo(self):
        conn = self.mpd
        conn_status = conn.status()
        self.status = {
                'state' : conn_status['state'],
                'random' : int(conn_status['random']),
                'repeat' : int(conn_status['repeat']),
                'updating' : int(conn_status.has_key('updating_db'))
        }
        if conn_status.has_key('time'):
            self.status['time'] = conn_status['time']
        self.track = conn.currentsong()

    def getCurrentTrack(self):
        conn = self.mpd
        return conn.currentsong()


def MPC_createBuffer(filename, type, direction, size, name):

    try:
        vim.command("let dummy = buflisted(\"%s\")" % filename)

        if vim.eval("dummy") == '1':
            debug("File '%s' already exists!" % filename)
            return 1
        else:
            debug("Buffer '%s' doesn't exist!" % filename)

            vim.command("silent! %s %s %s %s" % 
                    (type, size, direction, filename))

            vim.command("silent! setlocal buftype=nofile")
            vim.command("silent! setlocal cul")
#            vim.command("silent! setlocal nomodifiable")
            vim.command("silent! setlocal nonumber")
            vim.command("silent! setlocal nospell")
            vim.command("silent! setlocal noswapfile")
            vim.command("silent! setlocal nowrap")
            vim.command("silent! setlocal winfixheight")

            # Special considerations for lyrics window
            if name == "database":
                vim.command("silent! setlocal bufhidden=delete")
                vim.command("silent! setlocal titlestring=Database")
                vim.command("silent! setlocal tw=50")
                vim.command('silent! setlocal foldtext=DatabaseFoldText()')

                vim.command('nnoremap <buffer> <silent> %s :python \
                        MPC_lookupBuffer("%s").enqueueTrack()<CR>' %
                        (play_selection_key, "Playlist"))
            else:

                vim.command("silent! setlocal titlestring=Playlist")
                vim.command('silent! setlocal updatetime=1000')
                vim.command('silent! setlocal foldtext=TrackFoldText()')

                vim.command('autocmd BufDelete %s :python \
                        MPC_lookupBuffer("%s").destroyPlaylist()' %
                        (filename, filename))

                vim.command('autocmd CursorHold * :python \
                        MPC_lookupBuffer("%s").checkForChange()' %
                        filename)

                # Remote
                vim.command('nnoremap <buffer> <silent> %s :python \
                        MPC_lookupBuffer("%s").playPause()<CR>' %
                        (remote_play_pause_key, filename))

                vim.command('nnoremap <buffer> <silent> %s :python \
                        MPC_lookupBuffer("%s").stop()<CR>' %
                        (remote_stop_key, filename))

                vim.command('nnoremap <buffer> <silent> %s :python \
                        MPC_lookupBuffer("%s").next()<CR>' %
                        (remote_next_key, filename))

                vim.command('nnoremap <buffer> <silent> %s :python \
                        MPC_lookupBuffer("%s").prev()<CR>' %
                        (remote_prev_key, filename))

                vim.command('nnoremap <buffer> <silent> %s :python \
                        MPC_lookupBuffer("%s").toggleShuffle()<CR>' %
                        (remote_toggle_random_key, filename))

                vim.command('nnoremap <buffer> <silent> %s :python \
                        MPC_lookupBuffer("%s").toggleRepeat()<CR>' %
                        (remote_toggle_repeat_key, filename))

                vim.command('nnoremap <buffer> <silent> %s :python \
                        MPC_lookupBuffer("%s").toggleStopAfterPlaying()<CR>' %
                        (remote_toggle_stop_after_playing_key, filename))

                vim.command('nnoremap <buffer> <silent> %s :python \
                        MPC_lookupBuffer("%s").update()<CR>' %
                        (remote_update_key, filename))

                # Playlist specific
                vim.command('nnoremap <buffer> <silent> %s :python \
                        MPC_lookupBuffer("%s").playSelection()<CR>' %
                        (play_selection_key, filename))

                vim.command('nnoremap <buffer> <silent> %s :python \
                        MPC_lookupBuffer("%s").highlightCurrent()<CR>' % 
                        (focus_current_track_key, filename))

                vim.command('nnoremap <buffer> <silent> %s :python \
                        MPC_lookupBuffer("%s").clearPlaylist(True)<CR>' % 
                         (clear_playlist_key, filename))

                vim.command('nnoremap <buffer> <silent> %s :python \
                        MPC_lookupBuffer("%s").updatePlaylist()<CR>' % 
                         (refresh_playlist_key, filename))

                vim.command('nnoremap <buffer> <silent> %s :python \
                        MPC_lookupBuffer("%s").showInfo()<CR>' % 
                         (show_info_key, filename))

#                vim.command('nnoremap <buffer> <silent> %s :python \
#                        MPC_lookupBuffer("%s").diffPlaylist()<CR>' % 
#                         (diff_key, filename))

                vim.command('nnoremap <buffer> <silent> %s :python \
                        MPC_lookupBuffer("%s").showDatabase()<CR>' % 
                         (show_database_key, filename))

            return 0
    except:
        debug("Error: '%s'" % sys.exc_info()[0])

def MPC_removeBuffer(filename):
    if BUFFERS.has_key(filename):
        debug ("Deleting '%s' from buffer list" % filename)
        del BUFFERS[filename]
    else:
        debug("Lookup: unable to find match for '%s'" % filename)

def MPC_lookupBuffer(filename):
    if BUFFERS.has_key(filename):
        instance = BUFFERS[filename]
        debug("Found existing instance: '%s'" % instance)
        return instance
    else:
        debug("Lookup: unable to find match for '%s'" % filename)
    return None

def MPC_init(filename):
    exists = MPC_createBuffer(filename, playlist_type, playlist_direction,
            playlist_size, "playlist")

    if not exists:
        debug("Opening new buffer for '%s'" % filename)

        mpc = MPC(filename)
        mpc.readPlaylist()
        mpc.displayPlaylist()
        mpc.highlightCurrent()

        BUFFERS[filename] = mpc
    else:
        debug("Closing '%s'" % filename)
        mpc = MPC_lookupBuffer(filename)
        mpc.destroyPlaylist()

def MPC_setVariable(option, value):
    vim.command("let dummy = exists(\"%s\")" % option)

    if vim.eval("dummy") == '1':
        value = vim.eval(option)
        debug("Option '%s' exists, using the value '%s'"
                % (option, value))
    else:
        debug("Option '%s' doesn't exist, using default value '%s'"
                % (option, value))

    return value


# Set default variables unless they're otherwise configured elsewhere.
# NOTE: These are default values only, and should not be modified.

# Remote
remote_play_pause_key = MPC_setVariable("g:mpc_remote_play_pause_key", "p")
remote_stop_key = MPC_setVariable("g:mpc_remote_stop_key", "s")
remote_next_key = MPC_setVariable("g:mpc_remote_next_key", "l")
remote_prev_key = MPC_setVariable("g:mpc_remote_prev_key", "h")
remote_toggle_random_key = MPC_setVariable("g:mpc_remote_toggle_random_key", "r")
remote_toggle_repeat_key = MPC_setVariable("g:mpc_remote_toggle_repeat_key", "e")
remote_toggle_stop_after_playing_key = MPC_setVariable("g:mpc_remote_stop_after_playing_key", "x")
remote_update_key = MPC_setVariable("g:mpc_remote_update_key", "u")

# Playlist
play_selection_key = MPC_setVariable("g:mpc_play_selection_key", "<CR>")
focus_current_track_key = MPC_setVariable("g:mpc_focus_current_track_key", "<C-L>")
show_info_key = MPC_setVariable("g:mpc_show_info_key", "<C-I>")
refresh_playlist_key = MPC_setVariable("g:mpc_refresh_playlist_key", "<C-R>")
clear_playlist_key = MPC_setVariable("g:mpc_clear_playlist_key", "c")
show_database_key = MPC_setVariable("g:mpc_show_database_key", "<C-D>")

# Database

# General
playlist_size = MPC_setVariable("g:mpc_playlist_size", "10")
playlist_direction = MPC_setVariable("g:mpc_playlist_direction", "split")
playlist_type = MPC_setVariable("g:mpc_playlist_type", "new") # :help opening-window

database_size = MPC_setVariable("g:mpc_database_size", "30")
database_direction = MPC_setVariable("g:mpc_database_direction", "vsplit")
database_type = MPC_setVariable("g:mpc_database_type", "aboveleft") # :help opening-window

# Other
playlist_mode = MPC_setVariable("g:mpc_playlist_mode", "folded") # standard, folding
#folding_mode = MPC_setVariable("g:mpc_folding_mode", "hybrid") # hybrid, hierarchy
auto_focus = MPC_setVariable("g:mpc_auto_focus", "1")

# Experimental
#diff_key = MPC_setVariable("g:mpc_diff", "<C-D>")


# vim: set et sw=4 st=4 tw=79:
