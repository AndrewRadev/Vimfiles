module Support
  module Vim
    def self.define_extra_methods(vim)
      def vim.xcompile(filename, output_filename)
        command("call xruntime#Compile('#{filename}', '#{output_filename}')")
      end
    end
  end
end
