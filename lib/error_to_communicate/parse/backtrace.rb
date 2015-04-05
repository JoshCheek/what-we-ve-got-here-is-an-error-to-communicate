require 'error_to_communicate/exception_info'

module WhatWeveGotHereIsAnErrorToCommunicate
  module Parse
    module Backtrace
      def self.parse?(exception)
        !!location_extractor(exception)
      end

      def self.parse(exception)
        extractor = location_extractor(exception)
        extractor || raise("Couldn't figure out how to parse the backtrace of #{exception.inspect}")
        locations = extractor.call
        locations.each_cons(2) do |crnt, succ|
          succ.pred = crnt
          crnt.succ = succ
        end
        locations
      end

      private

      def self.location_extractor(exception)
        if exception.respond_to?(:backtrace_locations) # MRI
          lambda { exception.backtrace_locations.map &method(:parse_mri_location) }
        elsif exception.respond_to?(:awesome_backtrace) # RBX
          lambda { exception.awesome_backtrace.map &method(:parse_rbx_location) }
        elsif exception.respond_to?(:backtrace) # FALLBACK
          lambda { exception.backtrace.map &method(:parse_generic_location) }
        end
      end

      # http://www.rubydoc.info/stdlib/core/Thread/Backtrace/Location
      def self.parse_mri_location(loc)
        ExceptionInfo::Location.new(
          filepath:   loc.absolute_path,
          linenum:    loc.lineno,
          methodname: loc.base_label,
        )
      end

      # Definitely not sufficient, but I'll wait until I have better examples of how it fucks up.
      def self.parse_generic_location(line)
        filepath, linenum, label, * = line.split(":")
        ExceptionInfo::Location.new(
          filepath:   filepath,
          linenum:    linenum.to_i,
          methodname: label,
        )
      end

      # https://github.com/rubinius/rubinius/blob/cfccf9dfbff79e0330f176b6e83d260cf57ef663/kernel/common/location.rb
      # looks like they built out equivalent behaviour in later rubies, but it's not there on my current install,
      # and I can't get the newer ones to build :(
      def self.parse_rbx_location(loc)
        ExceptionInfo::Location.new(
          filepath:   loc.file, # can maybe get this to be absolute with Rubinius::KERNEL_PATH
          linenum:    loc.line,
          methodname: loc.describe_method,
        )
      end
    end
  end
end
