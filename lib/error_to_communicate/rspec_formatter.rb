require 'error_to_communicate'
require 'rspec/core/formatters/documentation_formatter'

module ErrorToCommunicate
  class Heuristic::RSpecFailure < Heuristic
    def self.fix_whitespace(str)
      str = str.dup
      str.sub! /\A\n*/, "" # remove leading newlines
      str.sub! /\n*\Z/, "" # remove trailing newlines
      str << "\n"          # one newline on the end
    end

    attr_accessor :failure, :failure_number, :config
    attr_accessor :semantic_summary, :semantic_info

    def initialize(attributes)
      self.failure_number = attributes.fetch :failure_number
      self.failure        = attributes.fetch :failure
      self.config         = attributes.fetch :config

      # initialize the heuristic
      ExceptionInfo.parse(failure.exception).tap do |einfo|
        einfo.backtrace = ExceptionInfo.parse_backtrace failure.formatted_backtrace
        super einfo: einfo, project: config.project
      end

      if assertion?
        # format it with our lib
        self.semantic_info =
          [:heuristic, [ # ":heuristic" is dumb, it's not a heuristic, it's an error message, Maybe we need a :section or something?
            [:message, self.class.fix_whitespace(message)],
            *backtrace.take(1).map { |loc|
              [:code, {location: loc, context: (-5..5), emphasis: :code}]
            }
          ]]

        self.semantic_summary =
          [:summary, [
            [:columns,
              [:classname, failure_number],        # TODO: not classname
              [:classname, failure.description]]]] # TODO: not classname
      else
        # wrap the heuristic that would otherwise be chosen
        heuristic             = config.heuristic_for einfo
        self.semantic_info    = heuristic.semantic_info
        self.semantic_summary =
          [:summary, [
            [:columns,
              [:classname,   failure_number],      # TODO: not classname
              [:classname,   failure.description], # TODO: not classname
              [:classname,   heuristic.classname], # TODO: not classname
              [:explanation, heuristic.semantic_explanation]]]]
      end
    end

    def assertion?
      # RSpec differentiates failures from assertions by whether RSpec is in the name:
      # https://github.com/JoshCheek/mrspec/blob/2761ba2180eb5f71a9262f6d59ce20d7cc8a47c3/lib/mrspec/minitest_assertion_for_rspec.rb
      classname =~ /RSpec/
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
          config:         Config.default,
          failure:        failure,
          failure_number: failure_number
        formatted = Config.default.format heuristic, Dir.pwd
        output.puts formatted.chomp.gsub(/^/, '  ')
      end
    end
  end
end
