module Vim
  class Buffer
    include Enumerable

    def lines
      to_a
    end

    def each_line
      length.times do |i|
        yield self[i + 1]
      end
    end

    alias each each_line
  end
end
