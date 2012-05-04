require 'facter/util/namespace'
Namespace = Facter::Util::Namespace
describe Namespace do
  describe ".traverse" do
  end
  describe ".sub_namespace" do
    let(:data_value) {"test_value"}
    describe "with no prefix" do
      let(:prefix) { nil }
      it "should not add a top level namespace delimiter" do
        Namespace.sub_namespace(prefix, data_value).should_not =~ /^::/
      end
      it "should only be the current data value" do
        Namespace.sub_namespace(prefix, data_value).should == data_value
      end
    end
    describe "with prefix" do
      let(:prefix) {"test::prefix"}
      it "should append the current data value with the :: namespace separator" do
        Namespace.sub_namespace(prefix, data_value).should == "#{prefix}::#{data_value}"
      end
    end
  end
  describe ".index_namespace" do
    let(:index) { 1 }
    describe "when no prefix" do
      let(:prefix) { nil }
      it "should add only the array notation with the index" do
        Namespace.index_namespace(prefix, index).should == "#{prefix}[#{index}]"
      end
    end
    describe "with prefix" do
      let(:prefix) { "some_prefix" }
      it "should add then index at the end of the prefix with array notation" do
        Namespace.index_namespace(prefix, index).should == "#{prefix}[#{index}]"
      end
    end
  end
end