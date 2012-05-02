require 'spec_helper'
require 'facter/util/defined_fact'

DefinedFact = Facter::Util::DefinedFact
describe DefinedFact do
  let(:valid_name) { "name" }
  let(:valid_type) { :string }
  let(:valid_description) { "a test fact description" }
  let(:fact) do
    DefinedFact.new valid_name, valid_type, valid_description
  end
  describe "#initialize" do
    describe "with invalid arguments" do
      it "should raise an error when no name" do
        lambda do
          DefinedFact.new nil, valid_type, valid_description
        end.should raise_error ArgumentError
      end
      it "should raise an error when no type" do
        lambda do
          DefinedFact.new valid_name, nil, valid_description
        end.should raise_error ArgumentError
      end
      it "should raise an error when no description" do
        lambda do
          DefinedFact.new valid_name, valid_type, nil
        end.should raise_error ArgumentError
      end
    end
    describe "with valid arguments" do
      it "should have a type" do
        fact.type.should == valid_type
      end
      it "should have a name" do 
        fact.name.should == valid_name
      end
      it "should have a description" do
        fact.description.should == valid_description
      end
    end
  end
  describe "after creation" do      
    it "should not allow you to change the name" do
      lambda { fact.name = "new name" }.should raise_error
    end
    it "should not allow you to change the type" do
      lambda { fact.type = :boolean }.should raise_error
    end
  end
  describe "#structured?" do
    { :string   => false,
      :numeric  => false,
      :boolean  => false,
      :hash     => true,
      :array    => true
    }.each do |type, expected|
      describe "when type is #{type}" do
        let(:fact) do
          fact = DefinedFact.new("test_fact", type, "a test fact description")
        end
        it "should be #{expected}" do
          fact.structured?.should == expected
        end
      end
    end
  end
  describe "#reset" do
    before(:each) do
      fact.value = "my test value"
    end
    it "should clear the resolved flag" do
      fact.should be_resolved
      fact.reset
      fact.should_not be_resolved
    end
    it "should clear the value" do
      fact.value.should_not be_nil
      fact.reset
      fact.value.should == :undef
    end
  end
  describe "#resolved?" do
    it "should be false if the value hasn't been set" do
      fact.value = "my test value"
      fact.should be_resolved
    end
    it "should be true if the value has been set" do
      fact.should_not be_resolved
    end
  end
  describe "#value" do
    it "should be :undef if the fact hasn't been resolved" do
      fact.value.should == :undef
    end
  end
end