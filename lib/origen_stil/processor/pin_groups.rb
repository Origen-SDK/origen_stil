module OrigenSTIL
  module Processor
    class PinGroups < Base
      attr_reader :model

      # Adds pin groups from the given node to the given model
      def run(node, model, options = {})
        @model = model
        node.find_all(:signal_groups).each do |signal_groups|
          process(signal_groups)
        end
      end

      def on_signal_group(node)
        name, expr = *node
        unless model.has_pin?(name)
          ids = process(expr).to_a[0]
          model.add_pin_group name.to_sym, *ids
        end
      end

      def on_add(node)
        lhs, rhs = *node
        Array(process(lhs)) + Array(process(rhs))
      end

      def on_subtract(node)
        fail 'Subract not implemented yet!'
      end

      def on_paren(node)
        fail 'Parenthesis not implemented yet!'
      end
    end
  end
end
