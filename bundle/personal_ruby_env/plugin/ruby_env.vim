if !has('ruby')
  finish
endif

for dir in split(&rtp, ',')
  let fname = dir.'/ruby/env.rb'

  if (filereadable(fname))
    ruby require Vim.evaluate('fname')
  endif
endfor

for fname in split(globpath(&rtp, 'ruby_plugin/*.rb'), '<NL>')
  ruby require Vim.evaluate('fname')
endfor
