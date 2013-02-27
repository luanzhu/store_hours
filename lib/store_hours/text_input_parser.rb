require 'parslet'

module StoreHours
  # Parser definition for store hours.
  #
  # A valid input includes one or more entries of durations separated by one or more white spaces.
  #
  # This parser will only takes lower cases.  However,
  #
  # Each entry has two parts: (1)week day or week days, and (2) one or more time periods when the
  # store is open, or closed for the days the store closes.
  #
  # Examples of valid entries:
  #   mon: 10:00am - 5:00pm
  #   mon: 8:00am-12:00pm, 1pm-5pm
  #   mon: 8:00am-12:00pm 1pm-5pm
  #   mon-fri : 10am-5pm
  #   sat - sun: closed
  #   sun : closed
  #
  # Examples of invalid entries:
  #   mon  10am - 5pm           # colon(:) after week day(s) is required
  #   mon fri: 10am - 5pm       # dash(-) between two days is required
  #   mon-fri: 10:am - 5pm      # minute component for time is required when the colon(:) is present
  #   mon-fri: 10 am - 5 pm     # no space is allowed between time digits and am/pm
  #   mon : 10am - 17           # standard time format (with am or pm) is required
  #   sat-sun: 10am-1pm closed  # closed can only be used with other time periods
  class TextInputParser < Parslet::Parser
    rule(:space)    { match('\s').repeat }
    rule(:sep)      { str('-') }
    rule(:colon)    { str(':') }
    rule(:comma)    { str(',') }
    rule(:ampm)     { str('am') | str('pm') }
    rule(:closed)   { str('closed') }

    rule(:day)      { (str('mon') | str('tue') | str('wed') | str('thu') | str('fri') | str('sat') | str('sun')).as(:day) }

    rule(:range)    { day.as(:day_from) >> space >> sep >> space >> day.as(:day_to) }

    rule(:left)     { range.as(:day_range) | day.as(:day_single) }

    rule(:minutes)  { colon >> match('[0-9]').repeat(1,2).as(:minute) }
    rule(:time)     { match('[0-9]').repeat(1,2).as(:hour) >> minutes.maybe >> ampm.as(:ampm) }
    rule(:trange)   { time.as(:time_from) >> space >> sep >> space >> time.as(:time_to) >> space >> comma.maybe >> space }
    rule(:right)    { trange.repeat(1).as(:time_range) | (closed.as(:closed) >> space) }

    rule(:line)     { left.as(:line_left) >> space >> colon >> space >> right.as(:line_right) }

    rule(:lines)    { line.repeat(1).as(:lines) }

    root(:lines)
  end
end