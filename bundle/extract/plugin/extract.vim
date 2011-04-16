finish " don't mind all of this for now

for file in split(globpath(&rtp, 'ruby/lib/extract.rb'), '\n')
  exec "rubyfile ".file
endfor

autocmd BufEnter *_spec.rb ruby $extractor = Extractor.new
