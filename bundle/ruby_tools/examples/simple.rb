module ModuleName
  #comments

  def foo
    bar
  end

  class ClassName
    attr_accessor :x, :y

    def bar
      baz
      bla
    end

    def qux
      bla
      bla
    end

    def self.something
      self.something_else
    end

    private

    def something
      something_else
    end
  end

  def another_function
    # comment
  end
end
