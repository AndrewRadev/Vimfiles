setlocal foldmethod=indent
setlocal nofoldenable

call SetupPreview('js', 'coffee -p %s')
RunCommand Preview
