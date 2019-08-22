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

      def on_signal_groups(node)
        groups = node.children
        if groups.first.type == :name
          groups = groups.dup
          # Not doing anything with named groups currently
          @current_signal_group_domain = groups.shift.value
          groups.freeze
          Origen.log.warning "Signal groups for domain \"#{@current_signal_group_domain}\" are being ignored (support for named signal groups is not implemented yet)"
          # process_all(groups)
        else
          @current_signal_group_domain = nil
          process_all(groups)
        end
      end

      def on_signal_group(node)
        name, expr = *node
        name = OrigenSTIL.unquote(name.value)
        @current_signal_group = name
        unless model.has_pin?(name)
          ids = process(expr).to_a[0]
          model.add_pin_group name.to_sym, *ids
        end
      end

      def on_name(node)
        id = node.value
        if model.has_pin?(id)
          # Expand any references to another pin group
          id = id.to_sym
          if dut.pin_groups.ids.map(&:to_sym).include?(id)
            model.pin(id).map(&:id)
          else
            [id]
          end
        else
          fail "Pin #{id} referenced at #{node.file}:#{node.line_number} but DUT does not have this pin/pin_group"
        end
      end

      def on_add(node)
        lhs, rhs = *node
        Array(process(lhs)) + Array(process(rhs))
      end

      def on_subtract(node)
        fail 'Subtraction in pin groups is not supported yet'
      end

      def on_parens(node)
        process_all(node.children).first
      end
    end
  end
end
