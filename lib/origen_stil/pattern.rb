module OrigenSTIL
  class Pattern
    # Path to the STIL file on disk
    attr_reader :path

    def initialize(path, options = {})
      unless File.exist?(path)
        fail "STIL source file not found: #{path}"
      end
      @path = path
    end

    # Returns the contents of the file before the first Pattern block
    # as a string
    def frontmatter
      @frontmatter ||= begin
        fm = ''
        File.foreach(path) do |line|
          break if line =~ /^\s*Pattern /
          fm << line
        end
        fm
      end
    end

    # Yields each vector in the given pattern to the caller as a Hash with the
    # structure shown in these examples:
    #
    #     { timeset: "wave1",
    #       comments: ["blah, blah", "blah blah blah"],
    #       pindata: { "ALL" => "10011011101" },
    #       repeat: 1,
    #     }
    #
    #     { timeset: nil,
    #       comments: [],
    #       pindata: { "portA" => "10011011101", "portB" => "10010" },
    #       repeat: 1000
    #     }
    #
    def each_vector(pattern_name, options = {})
      open = false
      vector = { timeset: nil, comments: [], pindata: {}, repeat: 1 }
      File.foreach(path) do |line|
        if open
          # Stop at next pattern or EOF
          break if line =~ /^\s*Pattern/
          if line =~ /^\s*Ann\s*{\*\s*(.*)\s*\*}/
            vector[:comments] << Regexp.last_match(1)
          elsif line =~ /(?:^|.*:)\s*(?:W|WaveformTable)\s+(.*)\s*;/
            vector[:timeset] = Regexp.last_match(1)
          elsif line =~ /(?:^|.*:)\s*Loop\s+(\d+)(\s|{)/
            vector[:repeat] = Regexp.last_match(1).to_i
          elsif line =~ /(?:^|.*:)\s*(?:V|Vector)\s+{(.*)}/
            Regexp.last_match(1).strip.split(';').each do |assignment|
              assignment = assignment.split(/\s*=\s*/)
              vector[:pindata][assignment[0]] = assignment[1]
            end
            yield vector
            vector = { timeset: nil, comments: [], pindata: {}, repeat: 1 }
          end
        else
          open = true if line =~ /^\s*Pattern #{pattern_name}\s*{/
        end
      end
    end

    def each_vector_with_index(pattern_name, options = {})
      i = 0
      each_vector(pattern_name, options) do |vec|
        yield vec, i
        i += 1
      end
    end
  end
end
