require 'spec_helper'

describe 'The STIL parser' do

  class StilTestDUT
    include Origen::TopLevel
  end

  before :each do
    Origen.target.temporary = -> do
      StilTestDUT.new
    end
    Origen.load_target
  end

  it 'can parse example 1' do
    f = "#{Origen.root}/examples/example1.stil"
    ast = OrigenSTIL::Pattern.new(f).ast
    ast.should be
    ast.find(:version).should == s(:version, 1, 0)
    ast.find(:header).find(:title).value.should == "Hello World"
    ast.find(:header).find(:history).find_all(:annotation).size.should == 2
    ast.find(:signals).find_all(:signal).size.should == 18
  end

  it 'handles pin group expressions' do
    f = "#{Origen.root}/examples/example1.stil"
    pat = OrigenSTIL::Pattern.new(f)
    pat.add_pins
    dut.pins(:a0_pin).size.should == 1
    dut.pins(:b0_pin).size.should == 1
    dut.pins(:abus_pins).size.should == 8
    dut.pins(:bbus_pins).size.should == 8
    #dut.pins(:bbus_odd).size.should == 4
    dut.pins(:xbus).size.should == 2
  end

  it 'decomposes nested pin groups' do
    f = "#{Origen.root}/examples/example1.stil"
    pat = OrigenSTIL::Pattern.new(f)
    pat.add_pins
    dut.pins(:abus_pins_alias).size.should == 8
  end
end
