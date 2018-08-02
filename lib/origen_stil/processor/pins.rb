module OrigenSTIL
  module Processor
    class Pins < Base
      attr_reader :model

      # Adds pins from the given node to the given model
      def run(node, model, options = {})
        @model = model
        process(node)
      end

      def on_signal(node)
        name, direction = *node
        if direction == 'In'
          direction = :input
        elsif direction == 'Out'
          direction = :output
        elsif direction == 'InOut'
          direction = :io
        else
          direction = nil
        end
        # Currently does not add pins defined as "Supply" or "Pseudo"
        if direction
          # No need to do anything if it already responds to this pin name
          unless model.has_pin?(name)
            # Otherwise might need to add an alias for different casing being used
            if model.has_pin?(name.downcase)
              model.add_pin_alias(name.to_sym, name.downcase)
            elsif model.has_pin?(name.upcase)
              model.add_pin_alias(name.to_sym, name.upcase)
            # Need to add a new pin
            else
              model.add_pin(name.to_sym, direction: direction)
            end
          end
        end
      end
    end
  end
end
