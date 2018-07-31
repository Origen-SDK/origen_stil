require 'treetop'
require 'origen_stil/syntax/node'
module OrigenSTIL
  module Syntax
    class Parser
      def self.parser
        @parser ||= begin
          require "#{Origen.root!}/grammars/stil"
          GrammarParser.new
        end
      end

      def self.parse_file(path, options = {})
        stil = OrigenSTIL::File.new(path)
        parse(stil.frontmatter, options.merge(file: stil.path))
      end

      def self.parse(data, options = {})
        @file = options[:file]
        tree = parser.parse(data)

        # If the AST is nil then there was an error during parsing,
        # we need to report a simple error message to help the user
        if tree.nil? && !options[:quiet]
          parser.failure_reason =~ /^(Expected .+) (after|at)/m
          @last_error_msg = []
          @last_error_msg << "#{Regexp.last_match(1).gsub("\n", '$NEWLINE')}:" if Regexp.last_match(1)
          if parser.failure_line >= data.lines.to_a.size
            @last_error_msg << 'EOF'
          else
            @last_error_msg << data.lines.to_a[parser.failure_line - 1].gsub("\t", ' ')
          end
          @last_error_msg << "#{'~' * (parser.failure_column - 1)}^"
          Origen.log.error "Failed parsing STIL file: #{file}"
          @last_error_msg.each do |line|
            Origen.log.error line.rstrip
          end
        end
        if tree
          tree.to_ast
        end
      end

      def self.last_error_msg
        @last_error_msg || []
      end

      def self.file
        @file
      end
    end
  end
end
