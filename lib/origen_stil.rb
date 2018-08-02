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
  end

  autoload :Pattern, 'origen_stil/pattern'

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
