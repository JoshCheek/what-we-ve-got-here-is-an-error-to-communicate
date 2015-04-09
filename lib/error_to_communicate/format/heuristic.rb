# Temporary extraction so I can see what's going on and do some refactorings.
module WhatWeveGotHereIsAnErrorToCommunicate
  class Format
    module Heuristic
      # FIXME: Some sort of polymorphism or normalization would be way better here, too
      # And, at the very least, not switching on classname, but some more abstract piece of info,
      # b/c classnames are not completely consistent across the implementations
      # (eg: https://github.com/JoshCheek/seeing_is_believing/blob/cc93b4ee3a83145509c235f64d9454dc3e12d8c9/lib/seeing_is_believing/event_stream/producer.rb#L54-55)
      def heuristic(info, cwd)
        if info.classname == 'ArgumentError'
          display_location(location:   info.backtrace[0],
                           highlight:  info.backtrace[0].label,
                           context:    0..5,
                           message:    "EXPECTED #{info.num_expected}",
                           emphasisis: :code,
                           cwd:        cwd) <<
          "\n" <<
          display_location(location:   info.backtrace[1],
                           highlight:  info.backtrace[0].label,
                           context:    -5..5,
                           message:    "SENT #{info.num_received}",
                           emphasisis: :code,
                           cwd:        cwd)
        elsif info.classname == 'NoMethodError'
          display_location(location:   info.backtrace[0],
                           highlight:  info.backtrace[0].label,
                           context:    -5..5,
                           message:    "#{info.undefined_method_name} is undefined",
                           emphasisis: :code,
                           cwd:        cwd)
        else
          display_location(location:   info.backtrace[0],
                           highlight:  info.backtrace[0].label,
                           context:    -5..5,
                           emphasisis: :code,
                           cwd:        cwd)
        end
      end
    end
  end
end
