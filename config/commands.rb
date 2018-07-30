# This file should be used to extend the origen with application specific commands

# Map any command aliases here, for example to allow 'origen ex' to refer to a 
# command called execute you would add a reference as shown below: 
aliases ={
#  "ex" => "execute",
}

# The requested command is passed in here as @command, this checks it against
# the above alias table and should not be removed.
@command = aliases[@command] || @command

# Now branch to the specific task code
case @command

when "build"
  Dir.chdir Origen.root do
    system 'lbin/tt --force grammars/stil.treetop'
  end
  exit 0

# (Working) example of how to create an application specific comment, here to generate
# a tags file for you application to enable method definition lookup and similar within
# editors/IDEs
when "tags"  
  # Here the logic is just written in-line, alternatively it could be written in a
  # dedicated file and required here, e.g.
  #require "origen_stil/commands/my_command"    # Would load file lib/origen_stil/commands/my_command.rb
  Dir.chdir Origen.root do
    system("ripper-tags -R")
  end
  # You must always exit upon successfully capturing and executing a command to prevent 
  # control flowing back to Origen
  exit 0

## Example of how to make a command to run unit tests, this simply invokes RSpec on
## the spec directory
#when "specs"
#  require "rspec"
#  exit RSpec::Core::Runner.run(['spec'])

## Example of how to make a command to run diff-based tests
#when "examples", "test"
#  Origen.load_application
#  status = 0
#
#  # Compiler tests
#  ARGV = %w(templates/example.txt.erb -t debug -r approved)
#  load "origen/commands/compile.rb"
#  # Pattern generator tests
#  #ARGV = %w(some_pattern -t debug -r approved)
#  #load "#{Origen.top}/lib/origen/commands/generate.rb"
#
#  if Origen.app.stats.changed_files == 0 &&
#     Origen.app.stats.new_files == 0 &&
#     Origen.app.stats.changed_patterns == 0 &&
#     Origen.app.stats.new_patterns == 0
#
#    Origen.app.stats.report_pass
#  else
#    Origen.app.stats.report_fail
#    status = 1
#  end
#  puts
#  if @command == "test"
#    Origen.app.unload_target!
#    require "rspec"
#    result = RSpec::Core::Runner.run(['spec'])
#    status = status == 1 ? 1 : result
#  end
#  exit status  # Exit with a 1 on the event of a failure per std unix result codes

# Always leave an else clause to allow control to fall back through to the
# Origen command handler.
else
  # You probably want to also add the your commands to the help shown via
  # origen -h, you can do this by assigning the required text to @application_commands
  # before handing control back to Origen.
  @application_commands = <<-EOT
 tags         Build a tags file for this app
 build        Build/compile the latest grammar file(s)
  EOT
# specs        Run the specs (tests), -c will enable coverage
# examples     Run the examples (tests), -c will enable coverage
# test         Run both specs and examples, -c will enable coverage
end 
