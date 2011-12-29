call ExtractSnipsFile(expand(g:snippets_dir).'android_java.snippets', 'java')
call ExtractSnipsFile(expand(g:snippets_dir).'android_xml.snippets', 'xml')

autocmd Filetype xml,java RunCommand !ant debug install
