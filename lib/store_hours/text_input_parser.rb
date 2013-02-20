require 'parslet'

module StoreHours
  class TextInputParser < Parslet::Parser
    rule(:space)    { match('\s').repeat }
    rule(:sep)      { str('-') }
    rule(:colon)    { str(':') }
    rule(:comma)    { str(',') }
    rule(:ampm)     { str('AM') | str('PM') }
    rule(:closed)   { str('closed') }

    rule(:day)      { str('Mon') | str('Tue') | str('Wed') | str('Thu') | str('Fri') | str('Sat') | str('Sun') }

    rule(:range)    { day.as(:day_from) >> space >> sep >> space >> day.as(:day_to) }

    rule(:left)     { range.as(:day_range) | day.as(:day_single) }

    rule(:time)     { match('[0-9]').repeat(1,2) >> colon >> match('[0-9]').repeat(2) >> ampm }
    rule(:trange)   { time.as(:time_from) >> space >> sep >> space >> time.as(:time_to) >> space >> comma.maybe >> space }
    rule(:right)    { trange.repeat(1).as(:time_range) | (closed.as(:closed) >> space) }

    rule(:line)     { left.as(:line_left) >> space >> colon >> space >> right.as(:line_right) }

    rule(:lines)    { line.repeat(1).as(:lines) }

    root(:lines)
  end
end