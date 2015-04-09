require 'error_to_communicate'
require 'error_to_communicate/format'
require 'rspec/core/formatters/documentation_formatter'

module WhatWeveGotHereIsAnErrorToCommunicate
  class RSpecFormatter < RSpec::Core::Formatters::DocumentationFormatter
    # Register for notifications from our parent classes
    #   http://rspec.info/documentation/3.2/rspec-core/RSpec/Core/Formatters.html
    #
    #   Our complete set of notifications can be seen with:
    #     puts RSpecFormatter.ancestors.flat_map { |ancestor|
    #       RSpec::Core::Formatters::Loader.formatters.fetch(ancestor, [])
    #     }
    RSpec::Core::Formatters.register self

    # Use WhatWeveGotHereIsAnErrorToCommunicate to print error info
    # rather than default DocumentationFormatter.
    #
    # How did we figure out how to implement it?
    # See "Down the rabbit hole" section in
    # https://github.com/JoshCheek/what-we-ve-got-here-is-an-error-to-communicate/blob/ede6844/lib/error_to_communicate/rspec_formatter.rb#L68
    #
    # FIXME: Needs to respect RSpec.configuration.color_enabled?
    #        but we can't currently turn colour off in our output
    def dump_failures(notification)
      result = "\nFailures:\n"
      notification.failure_notifications.each_with_index do |failure, failure_number|
        # get the exception with the modified backtrace
        exception = failure.exception.dup
        metadata  = failure.example.metadata
        exception.set_backtrace RSpec.configuration
                                     .backtrace_formatter
                                     .format_backtrace(exception.backtrace, metadata)

        # format it with our lib
        heuristic = ErrorToCommunicate::CONFIG.heuristic_for exception
        formatted = ErrorToCommunicate::CONFIG.format heuristic, Dir.pwd

        # fit it into the larger failure summary
        result << "\n  #{failure_number+1}) #{failure.description}\n"
        result << formatted.chomp.gsub(/^/, '    ')
      end
      output.puts result
    end
  end
end
