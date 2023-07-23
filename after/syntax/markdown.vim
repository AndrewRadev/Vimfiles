if &background == 'dark'
  hi markdownCodeDelimiter ctermbg=Black
  hi markdownCode ctermbg=Black
endif

unlet b:current_syntax

syntax include @Yaml syntax/yaml.vim
syntax include @toml syntax/toml.vim

syntax region yamlFrontmatter start=/\%^---/ end=/^---/ keepend contains=@Yaml
syntax region tomlFrontmatter start=/\%^+++/ end=/^+++/ keepend contains=@toml

let b:current_syntax = 'markdown'
