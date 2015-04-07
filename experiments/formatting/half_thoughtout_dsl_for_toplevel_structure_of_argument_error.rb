SemanticStructure
  .dsl
  .partition
    .header
      .title!(@info.classname)
      .subtext(:error)
        .text!(@info.explanation)
        .deemphasize
          .text!(:context,    '(expected ')
          .text!(:stands_out, @info.num_expected)
          .text!(:context,    ', sent ')
          .text!(:stands_out, @info.num_received)
          .text!(:context,    ')')
        .end
      .end
    .end
  }
  .partition { |heuristic|
    heuristic = display_location formatter:  heuristic,
                                 annotation: "expected #{@info.num_expected}",
                                 location:   @info.backtrace[0],
                                 highlight:  @info.backtrace[0].label,
                                 context:    0..5,
                                 emphasisis: :code

    heuristic = display_location formatter:  heuristic
                                 annotation: "SENT #{info.num_received}",
                                 location:   info.backtrace[1],
                                 highlight:  info.backtrace[0].label,
                                 context:    -5..5,
                                 emphasisis: :code
    heuristic
  }
  .partition { |fmt|
    info.backtrace.reduce(fmt) do |formatter, location|
      display_location formatter:  formatter,
                       location:   location,
                       highlight:  location.succ.label,
                       context:    0..0,
                       emphasisis: :path
    end
  }
end
