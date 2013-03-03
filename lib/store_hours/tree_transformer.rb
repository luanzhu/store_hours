require 'parslet'

require 'store_hours/constants'
require 'store_hours/semantic_error'

module StoreHours
  # Convert the intermediary tree resulted from parser to the internal data structure in the format of
  #   [{d1..d2 => [(m1..m2), (m3..m4)]},{d3..d3 => [(m5..m6)]}]
  # where
  #   d is the integer value of week day (i.e, Mon = 1, Tue = 2, ..., Sun = 7),
  #   m is the number of minutes passed from midnight (12AM).
  #
  # For example, "Mon-Fri: 1AM-2AM, 10AM-5PM Sat-Sun: closed" will be converted to
  #   [{1..5 => [(60..120), (600..1020)]}, {6..7 => [(-1..-1)]}].
  #
  # Use the list of single entry hash tables instead of one hash table to preserve order of inputs.
  #
  class TreeTransformer < Parslet::Transform
    rule(:hour => simple(:h), :ampm => simple(:ap)) { |dict|
      convert_time_input_to_minutes(dict[:h].to_i, 0, dict[:ap].to_sym)
    }
    rule(:hour => simple(:h), :minute => simple(:m), :ampm => simple(:ap))  { |dict|
      convert_time_input_to_minutes(dict[:h].to_i, dict[:m].to_i, dict[:ap].to_sym)
    }
    rule(:closed => simple(:x)) { x.to_sym }
    rule(:time_from => simple(:f), :time_to => simple(:t)) { |dict| check_starting_time_not_later_than_ending_time(dict[:f], dict[:t]) }
    rule(:time_range => sequence(:x)) { |dict| check_no_overlap_within_time_periods_for_single_day_range(dict[:x]) }
    rule(:day => simple(:x)) { WEEKDAY_TO_NUM[x.to_sym]}
    rule(:day_single => simple(:x)) { x..x }
    rule(:day_range => {:day_from => simple(:f), :day_to => simple(:t)}) { |dict| check_starting_day_not_later_than_ending_day(dict[:f], dict[:t]) }
    rule(:line_left => simple(:d), :line_right => sequence(:t))  { { d => t} }
    rule(:line_left => simple(:d), :line_right => simple(:c)) { {d => [-1..-1]} }  #for "closed" days
    rule(:lines => subtree(:x)) { |dict| check_no_overlap_within_day_ranges(dict[:x]) }

    private
    # Make sure the starting time is not later than the ending time.
    # @param starting_time [Fixnum] starting time in minutes passed since midnight
    # @param ending_time [Fixnum] ending time in minutes
    # @return [Range, (starting_time..ending_time)] if it is valid
    #
    # Will raise SemanticError if it is invalid.
    #
    def self.check_starting_time_not_later_than_ending_time(starting_time, ending_time)
      if starting_time > ending_time
        raise ::StoreHours::SemanticError.new "incorrect time period specified: ending time has to be later"
      end
      starting_time..ending_time
    end

    # Check to make sure the day range is valid. The integer values of week days are defined in constants.rb.
    # @param starting_day [Fixnum] starting day of the range, mon=1, ..., sun=7
    # @param ending_day [Fixnum] ending day of the range
    # @return [Range, (starting_day..ending_day)]
    #
    # Will raise SemanticError if starting_day is later than ending_day.
    #
    def self.check_starting_day_not_later_than_ending_day(starting_day, ending_day)
      if starting_day > ending_day
        raise ::StoreHours::SemanticError.new "incorrect day range specified: ending day has to be later"
      end
      starting_day..ending_day
    end

    # For a give day or day range, check to make sure there are no overlap within time periods
    # @param periods [Array of Range] time periods for a single day range, i.e., [(60, 120), (540, 1020)]
    # @return [Array of Range] the same as argument periods
    #
    # Will raise SemanticError if there is overlap.
    #
    def self.check_no_overlap_within_time_periods_for_single_day_range(periods)
      if self.ranges_overlap?(periods)
        raise ::StoreHours::SemanticError.new "incorrect time range specified: overlap for a single day range"
      end

      periods
    end

    # For the overall tree, check to make sure that a day integer can only appear once.
    # @param tree [Array of Hashtable] the already transformed internal data presentation.
    # @return [Array of Hashtable] the tree passed in will be untouched
    #
    # Will raise SemanticError if there is overlap
    #
    def self.check_no_overlap_within_day_ranges(tree)
      # make an array of hashtable keys
      ranges = []
      tree.each do |table|
        ranges << table.keys.first
      end

      if self.ranges_overlap?(ranges)
        raise ::StoreHours::SemanticError.new "incorrect day range specified: at last one day appear more than once"
      end

      tree
    end

    # Convert a time point in a day to the number of minutes passed since midnight.
    # @param hour [Fixnum] the hour component of time (not in military format)
    # @param minutes [Fixnum] the minutes component of time
    # @param am_or_pm [Symbol, :am or :pm]  morning or afternoon
    # @return [Fixnum] the number of minutes passed since midnight
    #
    def self.convert_time_input_to_minutes(hour, minutes, am_or_pm)
      hour += 12 if am_or_pm == :pm and hour < 12
      hour = 0 if am_or_pm == :am and hour == 12

      hour * 60 + minutes
    end

    # Check whether two or more ranges contain overlaps.
    # @param periods [Array of Range] list of ranges to be checked against
    # @return [Boolean] return true if ranges overlap
    #
    def self.ranges_overlap?(periods)
      # sort the ranges by range's first item
      sorted_periods = periods.sort {|x, y| x.first <=> y.first }

      # starts from the second item
      last_index = periods.length - 1
      for i in 1..last_index
        if sorted_periods[i].first <= sorted_periods[i-1].last
          return true
        end
      end

      return false
    end
  end
end