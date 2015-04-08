# RSpec.configuration.color_enabled?

# from http://rspec.info/documentation/3.2/rspec-core/RSpec/Core/Formatters.html
# To start
#   start(StartNotification)
# Once per example group
#   example_group_started(GroupNotification)
# Once per example
#   example_started(ExampleNotification)
# One of these per example, depending on outcome
#   example_passed(ExampleNotification)
#   example_failed(FailedExampleNotification)
#   example_pending(ExampleNotification)
# Optionally at any time
#   message(MessageNotification)
# At the end of the suite
#   stop(ExamplesNotification)
#   start_dump(NullNotification)
#   dump_pending(ExamplesNotification)
#   dump_failures(ExamplesNotification)
#   dump_summary(SummaryNotification)
#   seed(SeedNotification)
#   close(NullNotification)

# Registration:
#   BaseFormatter
#     :start, :example_group_started, :close
#
#   BaseTextFormatter < BaseFormatter
#     :message, :dump_summary, :dump_failures,
#     :dump_pending, :seed
#
#   DocumentationFormatter < BaseTextFormatter
#     :example_group_started, :example_group_finished,
#     :example_passed, :example_pending, :example_failed

require 'error_to_communicate'
require 'error_to_communicate/format'
require 'rspec/core/formatters/documentation_formatter'

module WhatWeveGotHereIsAnErrorToCommunicate
  class RSpecFormatter < RSpec::Core::Formatters::DocumentationFormatter
    RSpec::Core::Formatters.register self

    attr_writer :backtrace_formatter
    def backtrace_formatter
      @backtrace_formatter || RSpec.configuration.backtrace_formatter
    end

    def dump_failures(notification)
      formatted = "\nFailures:\n"
      notification.failure_notifications.each_with_index do |failure, failure_number|
        exception = failure.exception.dup
        metadata  = failure.example.metadata
        backtrace = backtrace_formatter.format_backtrace(exception.backtrace, metadata)
        exception.set_backtrace backtrace
        exception_info      = ErrorToCommunicate::CONFIG.parse(exception)
        formatted_exception = ErrorToCommunicate.format(exception_info)

        formatted << "\n  #{failure_number+1}) #{failure.description}\n"
        formatted << formatted_exception.chomp.gsub(/^/, '    ')
      end
      output.puts formatted
    end
  end
end

# Down the rabbit hole:
#
#    44: def dump_failures(notification)
#    45:   return if notification.failure_notifications.empty?
#    46:   require "pry"
# => 47:   binding.pry
#    48:   output.puts notification.fully_formatted_failed_examples
#    49: end
#
# def fully_formatted_failed_examples(colorizer=::RSpec::Core::Formatters::ConsoleCodes)
#   formatted = "\nFailures:\n"
#
#   failure_notifications.each_with_index do |failure, index|
#     formatted << failure.fully_formatted(index.next, colorizer)
#   end
#
#   formatted
# end
#
# def fully_formatted(failure_number, colorizer=::RSpec::Core::Formatters::ConsoleCodes)
#   "\n  #{failure_number}) #{description}\n#{formatted_message_and_backtrace(colorizer)}"
# end
#
# def formatted_message_and_backtrace(colorizer)
#   formatted = ""
#   colorized_message_lines(colorizer).each do |line|
#     formatted << RSpec::Support::EncodedString.new("     #{line}\n", encoding_of(formatted))
#   end
#   colorized_formatted_backtrace(colorizer).each do |line|
#     formatted << RSpec::Support::EncodedString.new("     #{line}\n", encoding_of(formatted))
#   end
#   formatted
# end
#
# def colorized_formatted_backtrace(colorizer=::RSpec::Core::Formatters::ConsoleCodes)
#   formatted_backtrace.map do |backtrace_info|
#     colorizer.wrap "# #{backtrace_info}", RSpec.configuration.detail_color
#   end
# end
#
# def formatted_backtrace
#   backtrace_formatter.format_backtrace(exception.backtrace, example.metadata)
# end
