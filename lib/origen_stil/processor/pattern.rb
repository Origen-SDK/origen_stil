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

      def on_pattern_burst(node)
        name, pat_list = *node
        if pat_list
          @bursts[name] = []
          @current_burst = @bursts[name]
          process(pat_list)
        end
      end

      def on_pat_list_item(node)
        @current_burst << node.to_a[0]
      end
    end
  end
end
