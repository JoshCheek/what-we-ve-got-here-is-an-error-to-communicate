require 'pathname'
require 'error_to_communicate/heuristic'

module ErrorToCommunicate
  class Heuristic
    class LoadError < Heuristic
      def self.for?(einfo)
        einfo.classname == 'LoadError' &&
          einfo.message.include?(' -- ')
      end

      def path
        @path ||= Pathname.new einfo.message.split(' -- ', 2).last
      end

      def semantic_info
        heuristic = if relevant_locations.any?
          relevant_locations.map { |location|
            [:code, {
              location:  location,
              highlight: location.label,
              context:   -5..5,
              message:   "Couldn't find #{path.to_s.inspect}",
              emphasis:  :code,
            }]
          }
        else
          # The newline here implies the semantic analysis needs to get better,
          # it only does this b/c it should be a block-element, but isn't being sectioned like that, correctly
          [:context, "Couldn\'t find anything interesting ¯\_(ツ)_/¯\n"]
        end

        [:heuristic, heuristic]
      end

      def relevant_locations
        @relevant_locations ||= [first_nongem_line, first_line_within_lib].compact.uniq
      end

      def first_nongem_line
        relevant_backtrace.first
      end

      def first_line_within_lib
        @first_line_within_lib ||= relevant_backtrace.find { |loc| loc.path.to_s.start_with? project.root }
      end

      private

      def relevant_backtrace
        @relevant_backtrace ||= relevant_backtrace = project.rubygems? ?
          backtrace :
          backtrace.drop_while { |loc| loc.path.to_s.start_with? project.rubygems_dir }
      end
    end
  end
end
