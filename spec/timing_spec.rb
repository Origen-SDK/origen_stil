require 'spec_helper'

describe 'The Timing Block parser' do

  def simple_timing_with_period(val)
    stil = <<-END
STIL 1.0;
Timing t_dft_mod_top_tmer {
  WaveformTable Waveset1 { 
    Period '#{val}' ;
    Waveforms {
    }
  }
}
END
    ast = OrigenSTIL::Syntax::Parser.parse(stil)
    p = OrigenSTIL::Processor::Timesets.new
    p.run(ast)
  end

  it 'can extract a simple timeset period' do
    t = simple_timing_with_period('100ns')
    debugger
    t["Waveset1"][:period_in_ns].should == 100
  end

  it 'can handle more complex timeset period examples' do
    t = simple_timing_with_period('100ns * 2')
    t["Waveset1"][:period_in_ns].should == 200

    t = simple_timing_with_period('100ns - 20ns')
    t["Waveset1"][:period_in_ns].should == 80

    t = simple_timing_with_period('(100ns - 20ns) * (3 - 1)')
    t["Waveset1"][:period_in_ns].should == 160

    t = simple_timing_with_period('((100ns - 20ns) * (3 - 1)) * 2')
    t["Waveset1"][:period_in_ns].should == 320
  end
end
