Pattern.create do
  tester.set_timeset('func', 100)
  file = "#{Origen.root}/examples/example3.stil"
  OrigenSTIL.add_pins(file)
  dut.pin_pattern_order(*dut.pins.map { |id, pin| id })
  OrigenSTIL.execute(file)
end
