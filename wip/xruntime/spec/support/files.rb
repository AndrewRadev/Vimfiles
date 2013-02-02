module Support
  module Files
    def set_file_contents(string)
      write_file(filename, string)
      @vim.edit!(filename)
    end

    def output_file_contents
      IO.read(output_filename).chop # remove trailing newline
    end

    def assert_output_file_contents(string)
      output_file_contents.should eq normalize_string_indent(string)
    end
  end
end
