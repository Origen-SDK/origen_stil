require 'spec_helper'

describe 'The STIL parser' do

  it 'can parse example 1' do
    f = "#{Origen.root}/examples/example1.stil"
    ast = OrigenSTIL.parse_file(f)
    ast.should be
    ast.find(:version).should == s(:version, 1, 0)
  end

end
