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

      def on_include(node)
        name, file_name = *node
        name = name.value if name.try(:type) == :name
        file = name.gsub('"', '')
        path = Pathname.new("#{Origen.root}/#{file}")
        @include_ast = OrigenSTIL::Pattern.new(path).ast
        period = @include_ast.find_all(:timing)
        unless period.empty?
          Origen.log.info "Parsing Timeset and Period from #{name}"
          name = @include_ast.find(:timing).to_a[1].to_a[0].value
          @timesets[name] = {}
          @timesets[name][:period_in_ns] =  @include_ast.find(:timing).to_a[1].to_a[1].find(:period).value
        end
      end

      def on_waveform_table(node)
        name = node.to_a[0]
        name = name.value if name.try(:type) == :name
        @timesets[name] = {}
        if period = node.find(:period)
          @timesets[name][:period_in_ns] = process_all(period.children).first * 1_000_000_000
        end
      end

      def on_time_expr(node)
        Expression.new.run(node)
      end
    end
  end
end
