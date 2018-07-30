require 'ast'
require 'treetop'
module OrigenSTIL
  module Syntax
    class Node < ::AST::Node
      attr_reader :input, :interval, :file, :number_of_lines

      # Returns the value at the root of an AST node like this:
      #
      #   node # => (module-def
      #               (module-name
      #                 (SCALAR-ID "Instrument"))
      #
      #   node.value  # => "Instrument"
      #
      # No error checking is done and the caller is responsible for calling
      # this only on compatible nodes
      def value
        val = children.first
        val = val.children.first while val.respond_to?(:children)
        val
      end

      # Returns the first child node of the given type that is found
      def find(type)
        nodes = find_all(type)
        nodes.first
      end

      # Returns an array containing all child nodes of the given type(s)
      def find_all(*types)
        Extractor.new.process(self, types)
      end

      def line_number
        input.line_of(interval.first)
      end

      def text_value
        input[interval]
      end

      def directory
        if file
          Pathname.new(file).dirname
        end
      end

      protected

      # I'd rather see the true symbol
      def fancy_type
        @type
      end
    end

    class Extractor
      include ::AST::Processor::Mixin

      attr_reader :types
      attr_reader :results

      def process(node, types = nil)
        if types
          @types = types
          @results = []
          # node = AST::Node.new(:wrapper, node) unless node.respond_to?(:to_ast)
        end
        super(node) if node.respond_to?(:to_ast)
        results
      end

      def handler_missing(node)
        @results << node if types.include?(node.type)
        process_all(node.children)
      end
    end
  end
end

# Some helpers to create the to_ast methods in syntax nodes
module Treetop
  module Runtime
    class SyntaxNode
      def n(type, *children)
        properties = children.pop if children.last.is_a?(Hash)
        properties ||= {}
        properties[:input] ||= input
        properties[:interval] ||= interval
        properties[:file] ||= file
        OrigenSTIL::Syntax::Node.new(type, children, properties)
      end

      def elements_to_ast(elmnts = elements)
        elmnts.map do |e|
          if e.respond_to?(:to_ast)
            e.to_ast
          elsif e.nonterminal? && !e.elements.empty?
            elements_to_ast(e.elements)
          end
        end.compact.flatten
      end

      def number_of_lines(elmnts = elements)
        elmnts.inject(0) do |sum, e|
          lines = e.text_value.split("\n").size
          sum + lines
        end
      end

      def file
        OrigenSTIL::Syntax::Parser.file
      end
    end
  end
end
