require 'spec_helper'
require 'rspec_struct'

describe RspecStruct do
  it "can be parsed from a string" do
    struct = RspecStruct.parse('it "should be okay"')

    struct.type.should eq :it
    struct.body.should eq 'should be okay'
  end
end
