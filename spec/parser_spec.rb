require 'spec_helper'

describe 'The STIL parser' do

  it 'can parse example 1' do
    f = "#{Origen.root}/examples/example1.stil"
    ast = OrigenSTIL.parse_file(f)
    ast.should be
    ast.find(:version).should == s(:version, 1, 0)
    ast.find(:header).find(:title).value.should == "Hello World"
    ast.find(:header).find(:history).find_all(:annotation).size.should == 2
    ast.find(:signals).find_all(:signal).size.should == 18
  end

  it 'can yield vector lines' do
    f = "#{Origen.root}/examples/example1.stil"
    f = OrigenSTIL::File.new(f)
    f.each_vector_with_index("blah") do |vec, i|
      vec[:pindata]["ALL"].should == "0110110110110110110111011"
      if i == 0
        vec[:timeset].should == "wft1"
      else
        vec[:timeset].should == nil
      end
      if i == 0
        vec[:comments].size.should == 4
      elsif i == 3
        vec[:comments].size.should == 1
      else
        vec[:comments].size.should == 0
      end
    end
  end
end
