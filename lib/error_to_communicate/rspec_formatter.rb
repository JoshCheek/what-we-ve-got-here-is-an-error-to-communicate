require 'error_to_communicate'
require 'rspec/core/formatters/documentation_formatter'

module ErrorToCommunicate
  class Heuristic::RSpecFailure < Heuristic
    attr_accessor :failure, :backtrace_formatter, :backtrace, :failure_number
    attr_accessor :semantic_summary, :semantic_info

    def initialize(attributes)
      self.backtrace_formatter = attributes.fetch :backtrace_formatter
      self.failure_number      = attributes.fetch :failure_number
      self.failure             = attributes.fetch :failure

      # get the exception with the modified backtrace
      exception = failure.exception.dup
      metadata  = failure.example.metadata
      backtrace = backtrace_formatter.format_backtrace(exception.backtrace, metadata)
      self.backtrace = ExceptionInfo.parse_backtrace backtrace

      # initialize the heuristic
      super attributes.merge einfo: ExceptionInfo.parse(exception)

      # format it with our lib
      if assertion?
        self.semantic_summary =
          [:summary, [
            [:columns,
              [:classname, self.failure_number],
              [:classname, self.failure.description]]]]

        # error message
        # -------------
        # first line from backtrace
        self.semantic_info =
          [:heuristic, [ # ":heuristic" is dumb, it's not a heuristic, it's an error message, Maybe we need a :section or something?
            [:message, exception.message],
            [:code, {
              location:  self.backtrace[0],
              context:   (-5..5),
              emphasis:  :code,
            }]
          ]]
      else
        # wrap the heuristic that would otherwise be chosen
        heuristic = Config.default.heuristic_for exception

        # num | description | classname | error message (content of heuristic.semantic_summary... this is not guaranteed to always work, but it currently works with all of our classes)
        self.semantic_summary =
          [:summary, [
            [:columns,
              [:classname, self.failure_number],
              [:classname,      self.failure.description],
              [:classname,      heuristic.classname],
              [:explanation,    heuristic.semantic_explanation]]]]

        self.semantic_info = heuristic.semantic_info
      end
    end

    def assertion?
      classname =~ /RSpec/ # TODO: document why these are assertions
    end
  end


  class RSpecFormatter < RSpec::Core::Formatters::DocumentationFormatter
    # Register for notifications from our parent classes
    #   http://rspec.info/documentation/3.2/rspec-core/RSpec/Core/Formatters.html
    #
    #   Our complete set of notifications can be seen with:
    #     puts RSpecFormatter.ancestors.flat_map { |ancestor|
    #       RSpec::Core::Formatters::Loader.formatters.fetch(ancestor, [])
    #     }
    RSpec::Core::Formatters.register self

    # Use ErrorToCommunicate to print error info
    # rather than default DocumentationFormatter.
    #
    # How did we figure out how to implement it?
    # See "Down the rabbit hole" section in
    # https://github.com/JoshCheek/what-we-ve-got-here-is-an-error-to-communicate/blob/ede6844/lib/error_to_communicate/rspec_formatter.rb#L68
    #
    # FIXME: Needs to respect RSpec.configuration.color_enabled?
    #        but we can't currently turn colour off in our output
    def dump_failures(notification)
      output.puts "\nFailures:\n"
      notification.failure_notifications.each.with_index(1) do |failure, failure_number|
        heuristic = Heuristic::RSpecFailure.new \
          project:             Config.default.project,
          failure:             failure,
          failure_number:      failure_number,
          backtrace_formatter: RSpec.configuration.backtrace_formatter
        formatted = Config.default.format heuristic, Dir.pwd
        output.puts formatted.chomp.gsub(/^/, '  ')
      end
    end
  end
end
