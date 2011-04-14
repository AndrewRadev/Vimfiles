describe Foo do
  it "should be" do
    foo = Foo.new
    foo.should be
  end

  it "should also not be" do
    foo = Foo.new
    foo.should_not be
  end

  context "as a bar" do
    it "should be bar by default" do
      foo = Foo.new
      foo.should be_bar
    end

    it "should be baz with an additional option" do
      foo = Foo.new(:baz => true)
      foo.should be_baz
    end
  end

  describe "a bar" do
    it "should equal a normal bar" do
      foo = Foo.new
      bar = Bar.new
      foo.should eq bar
    end

    it "should not equal a normal bar when it's baz" do
      foo = Foo.new(:baz => true)
      bar = Bar.new
      foo.should_not eq bar
    end
  end
end
