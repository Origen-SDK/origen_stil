require 'ast'
module OrigenSTIL
  module Processor
    class Base
      include AST::Processor::Mixin

      def handler_missing(node)
        node.updated(nil, process_all(node.children))
      end

      def process(node)
        return node unless node.respond_to?(:to_ast)
        super
      end
    end
  end
end
