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
        [:heuristic,
          relevant_locations.map { |location|
            [:code, {
              location:  location,
              highlight: location.label,
              context:   -5..5,
              message:   "Couldn't find file",
              emphasis:  :code,
            }]
          }
        ]
      end

      def relevant_locations
        rubygems_dir = $LOADED_FEATURES.grep(/\/rubygems\/specification.rb/).first
        rubygems_dir &&= File.dirname rubygems_dir
        project_root = File.expand_path Dir.pwd # iffy
        relevant_backtrace = if rubygems_dir
          backtrace.drop_while { |loc| loc.path.to_s.start_with? rubygems_dir }
        else
          0
        end

        first_nongem_line = relevant_backtrace.first
        first_line_within_lib = relevant_backtrace.find { |loc| loc.path.to_s.start_with? project_root }
        [first_nongem_line, first_line_within_lib].compact
      end
    end
  end
end
