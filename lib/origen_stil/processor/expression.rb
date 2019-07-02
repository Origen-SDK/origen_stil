module OrigenSTIL
  module Processor
    # Evaluates an expression to a final answer
    class Expression < Base
      # Given node should be a top-level expression node, like a :time_expr
      def run(node, options = {})
        process(node).value
      end

      def on_number_with_unit(node)
        val = node.find(:value).value
        if p = node.find(:prefix)
          case p.value
          when "E"
            val = val * 1000000000000000000
          when "P"
            val = val * 1000000000000000
          when "T"
            val = val * 1000000000000
          when "G"
            val = val * 1000000000
          when "M"
            val = val * 1000000
          when "k"
            val = val * 1000
          when "m"
            val = val / 1000.0
          when "u"
            val = val / 1000000.0
          when "n"
            val = val / 1000000000.0
          when "p"
            val = val / 1000000000000.0
          when "f"
            val = val / 1000000000000000.0
          when "a"
            val = val / 1000000000000000000.0
          else
            fail "Unknown number prefix #{p.value}"
          end
        end
        val
      end

      def on_parens(node)
        process_all(node.children).first
      end

      def on_multiply(node)
        a, b = *process_all(node.children)
        a * b
      end

      def on_divide(node)
        a, b = *process_all(node.children)
        a / (b * 1.0)
      end

      def on_add(node)
        a, b = *process_all(node.children)
        a + b
      end

      def on_subtract(node)
        a, b = *process_all(node.children)
        a - b
      end
    end
  end
end
