foo 1, 2, {
  :one => 1,
  :two => 2,
  :three => 'three'
}

foo = {
  :bar => 'baz',
  :one => 'two'
}

class Bar
  foo 1, 2, {
    :one => 1,
    :two => 2,
    :three => 'three'
  }
end

Bar.new do |b|
  puts b.to_s
  puts 'foo'
end

Bar.new do
  puts self.to_s
end

class Baz
  def qux
    if problem?
      return
    end

    foo 1, 2, {
      :one => 1,
      :two => 2,
      :three => 'three'
    }

    foo 1, 2, {
      :one => 1,
      :two => 2
    } do
      something
    end

    if condition?
      foo 1, 2, {
        :one => 1,
        :two => 2,
        :three => 'three'
      }
    end

    if one.two?
      foo = "bar"
    end

    unless something_wrong?
      return 42
    end
  end
end
