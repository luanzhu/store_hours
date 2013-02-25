require 'parslet'

require_relative 'constants'

module StoreHours


  class TreeTransformer < Parslet::Transform
    rule(:hour => simple(:h), :ampm => simple(:ap)) { |dic|
      convert_time_input_to_minutes(dic[:h].to_i, 0, dic[:ap].to_sym)
    }
    rule(:hour => simple(:h), :minute => simple(:m), :ampm => simple(:ap))  { |dic|
      convert_time_input_to_minutes(dic[:h].to_i, dic[:m].to_i, dic[:ap].to_sym)
    }
    rule(:closed => simple(:x)) { x.to_sym }
    rule(:time_from => simple(:f), :time_to => simple(:t)) { f..t }
    rule(:time_range => sequence(:x)) { x }
    rule(:day => simple(:x)) { WEEKDAY_TO_NUM[x.to_sym]}
    rule(:day_single => simple(:x)) { x..x }
    rule(:day_range => {:day_from => simple(:f), :day_to => simple(:t)}) { f..t }
    rule(:line_left => simple(:d), :line_right => sequence(:t))  { { d => t} }
    rule(:line_left => simple(:d), :line_right => simple(:c)) { {d => [-1..-1]} }  #for "closed" days
    rule(:lines => subtree(:x)) { x }

    private
    def self.convert_time_input_to_minutes(hour, minutes, am_or_pm)
      hour += 12 if am_or_pm == :pm and hour < 12
      hour = 0 if am_or_pm == :am and hour == 12

      hour * 60 + minutes
    end
  end
end