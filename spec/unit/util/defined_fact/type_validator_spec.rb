require 'facter/util/defined_fact/type_validator'

TypeValidator = Facter::Util::DefinedFact::TypeValidator

describe TypeValidator do
  it "should load the validator based on type" do
    TypeValidator.valid?(:string, "").should be_false
  end
  
  it "should default to true if it can't find a validtor" do
    TypeValidator.valid?(:my_crazy_type, nil).should be_true
  end
  describe "string validator" do
    describe "scenarios" do
      { nil     => false,
        ""      => false,
        " "     => false,
        "test"  => true,
      }.each do |value, expected|
        it "when '#{value}' should be #{expected}" do
          TypeValidator.valid?(:string, value).should == expected
        end
      end
    end
  end
end