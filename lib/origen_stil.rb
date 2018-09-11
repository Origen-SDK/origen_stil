require 'origen'

Origen.register_acronym 'STIL'

require_relative '../config/application.rb'

module OrigenSTIL
  # THIS FILE SHOULD ONLY BE USED TO LOAD RUNTIME DEPENDENCIES
  # If this plugin has any development dependencies (e.g. dummy DUT or other models that are only used
  # for testing), then these should be loaded from config/boot.rb

  # Example of how to explicitly require a file
  # require "origen_stil/my_file"

  # Load all files in the lib/origen_stil directory.
  # Note that there is no problem from requiring a file twice (Ruby will ignore
  # the second require), so if you have a file that must be required first, then
  # explicitly require it up above and then let this take care of the rest.
  module Syntax
    autoload :Node,   'origen_stil/syntax/node'
    autoload :Parser, 'origen_stil/syntax/parser'
  end

  module Processor
    autoload :Base,      'origen_stil/processor/base'
    autoload :Pins,      'origen_stil/processor/pins'
    autoload :PinGroups, 'origen_stil/processor/pin_groups'
    autoload :Pattern,   'origen_stil/processor/pattern'
    autoload :Timesets,  'origen_stil/processor/timesets'
  end

  autoload :Pattern, 'origen_stil/pattern'

  # Execute the pattern vectors in the given STIL file, this will also call
  # add_pins to ensure the pins are available so there is no need to call that
  # separately
  def self.execute(path, options = {})
    options = {
      # When true, any timeset changes from the STIL will be translated to tester.set_timeset
      # calls, otherwise they will be ignored
      set_timesets: false
    }.merge(options)
    # Bit of a hack, this is to lock in the current set of pins so that any added
    # by the STIL are not included, the Origen model is in charge of pattern formatting
    tester.current_pin_vals if tester
    add_pins(path, options)
    pattern(path).execute(options)
  end

  # Add pins (and pin groups) from the given STIL file to the current DUT
  # unless they already exist
  def self.add_pins(path, options = {})
    pattern(path).add_pins(options)
  end

  # Returns an OrigenSTIL::Pattern instance for the given STIL file
  def self.pattern(path_to_stil_file)
    path = Pathname.new(path_to_stil_file).realpath.cleanpath.to_s
    patterns[path] ||= OrigenSTIL::Pattern.new(path)
  end

  # @api private
  def self.patterns
    @patterns ||= {}
  end
end

STIL = OrigenSTIL unless defined?(STIL)
