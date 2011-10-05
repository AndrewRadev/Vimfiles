""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Speech.vim - Speech to text and text to speech via google speech api.  "
" Copyright (C) <2011>  Onur Aslan  <onur@onur.im>                       "
"                                                                        "
" Speech to text:                                                        "
" <Leader>r for record your voice and press again to convert to text and "
" append after cursor.                                                   "
"                                                                        "
" Text to speech:                                                        "
" <Leader>s to get speech of your current line.                          "
"                                                                        "
" Requiments: In order to run this script, you need ffmpeg (with flac    "
" encode support), wget and mplayer. This also works under UNIX like     "
" systems.                                                               "
"                                                                        "
" This script uses ALSA to record your voice. If you have trouble when   "
" you recording your voice, try to change SpechHwId variable. It comes   "
" with hw:0,0 default. You can test your hw id with:                     "
"                                                                        "
" ffmpeg -f alsa -ar 16000 -ac 2 -i hw:0,0 -acodec flac -ab 96k out.flac "
"                                                                        "
" 'arecord -l' will give you list of audio devices.                      "
"                                                                        "
" You can change language with SpeechLang variable.                      "
"                                                                        "
" LICENSE:                                                               "
"                                                                        "
" This program is free software: you can redistribute it and/or modify   "
" it under the terms of the GNU General Public License as published by   "
" the Free Software Foundation, either version 3 of the License, or      "
" (at your option) any later version.                                    "
"                                                                        "
" This program is distributed in the hope that it will be useful,        "
" but WITHOUT ANY WARRANTY; without even the implied warranty of         "
" MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the          "
" GNU General Public License for more details.                           "
"                                                                        "
" You should have received a copy of the GNU General Public License      "
" along with this program.  If not, see <http://www.gnu.org/licenses/>.  "
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

let g:SpeechLang = 'en-us'
let g:SpeechHwId = 'hw:0,0'

let s:SpeechToTextPid = 0

function! SpeechToText ()
  if s:SpeechToTextPid == 0
    let x = system ('rm -rf /tmp/vimspeech.flac')
    let s:SpeechToTextPid = system ('ffmpeg -f alsa ' .
                                    \ '-ar 16000 ' .
                                    \ '-ac 2 ' .
                                    \ '-i ' . g:SpeechHwId . ' ' .
                                    \ '-acodec flac ' .
                                    \ '-ab 96k ' .
                                    \ '/tmp/vimspeech.flac > /dev/null 2>&1 & ' .
                                    \ 'echo $!')
    echo 'Speak now'
    call getchar()
    call SpeechToText()
  else
    echo 'Converting...'
    let x = system ('kill -1 ' . s:SpeechToTextPid)
    let result = system ('wget -q -U ' . shellescape ('Mozilla/5.0') .
                         \ ' --post-file=/tmp/vimspeech.flac' .
                         \ ' --header=' .
                         \ shellescape ('Content-Type: audio/x-flac; ' .
                         \              'rate=16000') .
                         \ ' -O - ' .
                         \ shellescape ('http://www.google.com/speech-api/v1/' .
                         \              'recognize?lang=' . g:SpeechLang .
                         \              '&client=chromium'))
    let match = matchlist (result, '.*"utterance":"\(.*\)",.*')
    if !exists('match[1]')
      echo 'Unable to determine voice'
      let s:SpeechToTextPid = 0
      return
    endif
    exe ('normal a'.match[1].' ')
    let s:SpeechToTextPid = 0
  endif
endfunction

function! TextToSpeech (string)
  echo 'Reading'
  let string = substitute (a:string, '[^A-Za-z0-9,. ]', '', 'g')
  let x = system ('mplayer ' .
                  \ shellescape ('http://translate.google.com/' .
                                 \ 'translate_tts?ie=UTF-8&tl=' . g:SpeechLang .
                                 \ '&q=' . string) .
                  \ ' > /dev/null 2>&1')
endfunction

command! -count=0 Speak call s:Speak(<count>)
function! s:Speak(count)
  if a:count > 0
    call TextToSpeech(s:GetVisual())
  else
    call TextToSpeech(getline('.'))
  endif
endfunction

function! s:GetVisual()
  let original_cursor   = getpos('.')
  let original_reg      = getreg('z')
  let original_reg_type = getregtype('z')

  normal! gv"zy
  let text = @z

  call setreg('z', original_reg, original_reg_type)
  call setpos('.', original_cursor)

  return text
endfunction
