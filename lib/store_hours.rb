require 'parslet'

require "store_hours/version"
require "store_hours/text_input_parser"
require "store_hours/tree_transformer"
require "store_hours/semantic_error"

require "json"

# A very simple parser to parse store hours text. The

module StoreHours
  #
  #
  class StoreHours
    def initialize
      @hours = []
    end

    def from_text(text)
      # Will false if text cannot be parsed
      #
      #
      text = '' if text == nil
      result = true
      error_message = ''

      begin
        tree = TextInputParser.new.parse(text.strip.downcase)

        @hours = TreeTransformer.new.apply(tree)

        result = true
      rescue Parslet::ParseFailed => e
        puts e.cause.ascii_tree
        puts e.cause.message
        puts text[0..e.cause.source.chars_left]

        result = false
        error_message = "syntax error: input is not in correct format"
      rescue ::StoreHours::SemanticError => e
        puts e.message

        result = false
        error_message = e.message
      end

      return result, error_message
    end

    # return value is gauratted to be parseablefdfdfdf
    def to_text
      text = ''
      @hours.each do |days_table|
        days = days_table.keys.first  #days is the day range, for example, (1..5)
        text += NUM_TO_WEEKDAY[days.first].to_s
        text += "-" + NUM_TO_WEEKDAY[days.last].to_s if days.first != days.last
        text += ": "

        days_table[days].each_with_index do |minutes, index|
          text += ', ' if index > 0
          if minutes.first == -1  #closed days
            text += "closed"
          elsif
            text += to_time_str(minutes.first) + " - " + to_time_str(minutes.last)
          end
        end

        text += "\n"
      end

      text.strip
    end

    def is_open?(t)
      @hours.each do |days_table|
        # days_table in the format of range(wday..wday) => [range(minutes..minutes),...]
        # only one key in the hash table
        days = days_table.keys.first
        if days.include?(t.wday == 0 ? 7 : t.wday)
          days_table[days].each do |min_range|
            minutes = t.hour * 60 + t.min

            if min_range.include?(minutes)
              return true
            end
          end
        end
      end

      return false
    end

    private
    def to_time_str(t)
      hour_part = t / 60
      minute_part = t % 60

      am_or_pm = (hour_part >= 12 ? 'PM' : 'AM')
      hour_part = hour_part - 12 if hour_part >= 13

      "#{ hour_part }:#{ format('%02d', minute_part) }#{ am_or_pm }"
    end

  end
end
