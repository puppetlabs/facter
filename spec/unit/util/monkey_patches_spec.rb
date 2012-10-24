require 'spec_helper'
require 'tempfile'

describe 'Monkey Patches' do
  let(:subject) { "a b c d e f\ng h i j" }

  context 'String' do
    it "should respond to lines" do
       subject.lines.to_a.should == ["a b c d e f\n", "g h i j"]
    end
    it "should accept a block" do
      our_lines = []
      subject.lines do |line| our_lines << line end
      our_lines.should == ["a b c d e f\n", "g h i j"]
    end
  end

  context 'IO' do
    it "should respond to lines" do
      our_lines = nil
      Tempfile.open("lines") do | file |
        file.write(subject)
        file.flush
        file.rewind
        our_lines = file.lines.to_a
      end
      our_lines.should == ["a b c d e f\n", "g h i j"]
    end
    it "should accept a block" do
      our_lines = []
      file = Tempfile.new("lines")
      file.write(subject)
      file.flush
      file.rewind
      file.lines.each do |line| our_lines << line end
      file.unlink
      our_lines.should == ["a b c d e f\n", "g h i j"]
    end
  end

end

