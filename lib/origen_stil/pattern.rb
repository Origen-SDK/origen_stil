module OrigenSTIL
  class Pattern
    # Path to the STIL file on disk
    attr_reader :path

    def initialize(path, options = {})
      unless File.exist?(path)
        fail "STIL source file not found: #{path}"
      end
      @path = path
      @loop = Struct.new(:id, :count, :status, :source_line_number, :number_of_lines, :braces, :lines)
      @n = 0
    end

    def execute(options = {})
      options = {
        set_timesets: false,
        add_pins:     true
      }.merge(options)
      @exec_options = options
      @n = 0
      add_pins if options[:add_pins]
      Processor::Pattern.new.run(ast) do |pattern_name|
        i = 0
        open = false
        File.foreach(path) do |line|
          if open
            # Stop at next pattern or EOF
            break if line =~ /^\s*Pattern/
            consume_line(line, i)
          else
            open = true if line =~ /^\s*Pattern "?'?#{pattern_name}"?'?\s*{/
          end
          i += 1
        end
      end
    end

    # Returns frontmatter as an AST, note that this does not contain any
    # vector-level information from Pattern blocks at the end of the file
    def ast
      @ast ||= Syntax::Parser.parse_file(path)
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

    # Add the pins defined in the STIL file to the DUT, unless it has them already.
    # This will also call the add_pin_groups method automatically unless option
    # :pin_group is set to false
    def add_pins(options = {})
      options = {
        pin_groups: true
      }.merge(options)
      Processor::Pins.new.run(ast, dut, options)
      add_pin_groups(options) unless options[:pin_groups] = false
    end

    def add_pin_groups(options = {})
      Processor::PinGroups.new.run(ast, dut, options)
    end

    # Returns a hash containing all timesets (WaveformTables) defined in the STIL file
    #   { 'Waveset1' => { period_in_ns: 1000 } }
    def timesets(options = {})
      @timesets ||= Processor::Timesets.new.run(ast, options)
    end

    private

    #     vector[:repeat].cycles
    def consume_line(line, source_line_number)
      if @open_loop
        execute_loop(line)
      else
        if line =~ /(.*)(?:^|.*:)\s*Loop\s+(\d+)(.*)/
          #                           :id,                   :count,              :status, :source_line_number, :number_of_lines, :braces, :lines)
          @open_loop = @loop.new(Regexp.last_match(1), Regexp.last_match(2).to_i, :pending, source_line_number,        0,             0,      [])
          execute_loop(Regexp.last_match(3))

        else
          execute_line(line, source_line_number)
        end
      end
    end

    def execute_loop(line)
      # This is the number of lines that the source code spans, not necessarily the number
      # of active lines in the loop
      @open_loop.number_of_lines += 1
      content = ''
      comment = nil
      line.each_char do |c|
        # Stop processing the remainder if the line when a comment is encountered
        if c == '/'
          break if comment == '/'
          comment = '/'
          next
        else
          comment = nil
        end
        if @open_loop.status == :pending
          next if c == ' ' || c == "\t" || c == "\n"
          if c == '{'
            @open_loop.status = :open
            @open_loop.braces += 1
          else
            fail "No start of loop character '{' around line #{@open_loop.source_line_number}"
          end
        elsif @open_loop.status == :open
          if c == '{'
            @open_loop.braces += 1
            content += c
          elsif c == '}'
            @open_loop.braces -= 1
            if @open_loop.braces == 0
              @open_loop.status = :done
              content = content.strip
              unless content.empty?
                @open_loop.lines << content
                content = ''
              end
            else
              content += c
            end
          else
            content += c
          end
        else
          content += c
        end
      end

      if @open_loop.status == :done
        lp = @open_loop
        @open_loop = nil
        # If loop being used like a repeat
        if lp.lines.size == 1 && lp.lines.first =~ /(?:^|.*:)\s*(?:V|Vector)\s+{(.*)}/
          execute_line(lp.lines.first, lp.source_line_number, lp.count)
        else
          tester.loop_vectors "lp#{@n}", lp.count do
            lp.lines.each { |line| consume_line(line, lp.source_line_number) }
          end
        end
        # Consume any remaining content on the line after the loop closed
        unless content.strip.empty?
          consume_line(content, lp.source_line_number + lp.number_of_lines - 1)
        end
      else
        content = content.strip
        @open_loop.lines << content unless content.empty?
      end
    end

    # Sends any understood operations from the given line to the current tester
    def execute_line(line, source_line_number, cycles = 1)
      # These are in order of more likely occurrence for speed, i.e. assume that most
      # pattern lines are vectors...
      if line =~ /(?:^|.*:)\s*(?:V|Vector)\s+{(.*)}/
        Regexp.last_match(1).strip.split(';').each do |assignment|
          assignment = assignment.split(/\s*=\s*/)
          pin = dut.pins(OrigenSTIL.unquote(assignment[0]))
          data = assignment[1].gsub(/\s+/, '')
          pin.vector_formatted_value = data
        end
        cycles.cycles

      # Pattern comments
      elsif line =~ /^\s*Ann\s*{\*\s*(.*)\s*\*}/
        cc Regexp.last_match(1)

      # Source comments
      elsif line =~ /\s*\/\/.*/
      # Just ignore source comments

      # Change of timeset
      elsif line =~ /(?:^|.*:)\s*(?:W|WaveformTable)\s+(.*)\s*;/
        if @exec_options[:set_timesets]
          timeset = OrigenSTIL.unquote(Regexp.last_match(1))
          if timeset != @current_timeset
            tester.set_timeset(timeset, timesets[timeset][:period_in_ns])
            @current_timeset = timeset
          end
        end

      else
        line = line.strip
        unless line.empty? || line == '}'  # End of pattern
          Origen.log.warning "Skipped Pattern line #{source_line_number}: #{line}"
        end
      end
    end
  end
end
