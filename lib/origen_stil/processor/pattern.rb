module OrigenSTIL
  module Processor
    class Pattern < Base
      # Yields back the names of pattern blocks to be run as defined
      # in the PatternExec and PatternBurst blocks within the given node
      def run(node, options = {})
        @bursts = {}
        process(node)
        if e = node.find(:pattern_exec)
          e.find_all(:pattern_burst).each do |pb|
            @bursts[pb.to_a[0]].each do |pattern|
              yield pattern
            end
          end
        else
          fail 'No PatternExec block in the given AST!'
        end
      end

      def on_include(node)
        name, file_name = *node
        name = name.value if name.try(:type) == :name
        file = name.gsub('"', '')
        path = Pathname.new("#{Origen.root}/#{file}")
        @include_ast = OrigenSTIL::Pattern.new(path).ast
      end

      def on_pattern_burst(node)
        name, pat_list = *node
        name = name.value if name.try(:type) == :name
        if pat_list
          @bursts[name] = []
          @current_burst = @bursts[name]
          process(pat_list)
        end
      end

      def on_pat_list_item(node)
        name = node.to_a[0]
        name = name.value if name.try(:type) == :name
        @current_burst << name
      end
    end
  end
end
