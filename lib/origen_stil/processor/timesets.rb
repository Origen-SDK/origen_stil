module OrigenSTIL
  module Processor
    class Timesets < Base
      # Extract WaveformTables from the given AST and return as a hash of
      # timesets and attributes
      def run(node, options = {})
        @timesets = {}
        process(node)
        @timesets
      end

      def on_waveform_table(node)
        name = node.to_a[0]
        # Pass on resolving the period for now, could involve parameter cross referencing
        period = node.find(:period)
        @timesets[name] = {}
      end
    end
  end
end
