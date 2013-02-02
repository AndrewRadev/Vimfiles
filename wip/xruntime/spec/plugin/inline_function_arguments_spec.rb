require 'spec_helper'

describe "Inlining function arguments" do
  let(:vim)             { VIM }
  let(:filename)        { 'test.vim' }
  let(:output_filename) { 'output.vim' }

  specify "simple case" do
    set_file_contents <<-EOF
      """ LANGUAGE InlineFunctionArguments

      function Test(arg)
        return arg
      endfunction
    EOF

    vim.xcompile(filename, output_filename)

    assert_output_file_contents <<-EOF
      """ LANGUAGE InlineFunctionArguments

      function Test(arg)
      let arg = a:arg
        return arg
      endfunction
    EOF
  end
end
