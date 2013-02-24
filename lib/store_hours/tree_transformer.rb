require 'parslet'

require_relative 'constants'

module StoreHours


  class TreeTransformer < Parslet::Transform
    rule(:hour => simple(:h), :ampm => simple(:ap)) { (Integer(h) + (ap == "pm" ? 12 : 0)) * 60 }
    rule(:hour => simple(:h), :minute => simple(:m), :ampm => simple(:ap))  { (Integer(h) + (ap == "pm" ? 12 : 0))  * 60 + Integer(m) }
    rule(:closed => simple(:x)) { x.to_sym }
    rule(:time_from => simple(:f), :time_to => simple(:t)) { f..t }
    rule(:time_range => sequence(:x)) { x }
    rule(:day => simple(:x)) { WEEKDAY_TO_NUM[x.to_sym]}
    rule(:day_single => simple(:x)) { x..x }
    rule(:day_range => {:day_from => simple(:f), :day_to => simple(:t)}) { f..t }
    rule(:line_left => simple(:d), :line_right => sequence(:t))  { { d => t} }
    rule(:line_left => simple(:d), :line_right => simple(:c)) { {d => [0..0]} }  #for "closed" days
    rule(:lines => subtree(:x)) { x }
  end
end