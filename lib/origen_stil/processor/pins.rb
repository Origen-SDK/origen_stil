module OrigenSTIL
  module Processor
    class Pins < Base
      attr_reader :model

      # Adds pins from the given node to the given model
      def run(node, model, options = {})
        @model = model
        process(node)
      end

      def on_include(node)
        name, file_name = *node
        name = name.value if name.try(:type) == :name
        file = name.gsub('"', '')
        path = Pathname.new("#{Origen.root}/#{file}")
        @include_ast = OrigenSTIL::Pattern.new(path).ast
        pins = @include_ast.find_all(:signals)
        unless pins.empty?
          pins.to_a[0].to_a.each do |x|
            pinname = x.to_a[0]
            direction = x.to_a[1]
            if direction == 'In'
              direction = :input
            elsif direction == 'Out'
              direction = :output
            elsif direction == 'InOut'
              direction = :io
            else
              direction = nil
            end

            if direction
              # No need to do anything if it already responds to this pin name
              unless model.has_pin?(pinname)
                # Otherwise might need to add an alias for different casing being used
                if model.has_pin?(pinname.downcase)
                  model.add_pin_alias(pinname.to_sym, pinname.downcase)
                elsif model.has_pin?(pinname.upcase)
                  model.add_pin_alias(pinname.to_sym, pinname.upcase)
                # Need to add a new pin
                else
                  model.add_pin(pinname.to_sym, direction: direction)
                end
              end
            end
          end
        end
      end

      def on_signal(node)
        name, direction = *node
        name = OrigenSTIL.unquote(name)
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

      private

      def unquote(str)
        str.gsub(/\A("|')|("|')\Z/, '')
      end
    end
  end
end
