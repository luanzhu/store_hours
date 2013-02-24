require 'parslet'

require "store_hours/version"
require "store_hours/text_input_parser"
require "store_hours/tree_transformer"

require "json"

module StoreHours
  class StoreHours
    def initialize
      @hours = []
    end

    def from_text(text)
      # Will raise Parslet::ParseFailed error if text cannot be parsed
      #
      #
      throw ArgumentError.new('Input text cannot be nil') if text == nil

      tree = TextInputParser.new.parse(text.strip.downcase)

      @hours = TreeTransformer.new.apply(tree)
    end

    def to_text
      text = ''
      @hours.each do |line|
        line.keys.each do |k|
          text += NUM_TO_WEEKDAY[k.first].to_s
          text += "-" + NUM_TO_WEEKDAY[k.last].to_s if k.first != k.last
          text += ": "

          line[k].each_with_index do |h, index|
            text += ', ' if index > 0
            if h.first == 0 and h.last == 0
              text += "closed"
            elsif
              text += to_time_str(h.first) + " - " + to_time_str(h.last)
            end
          end
          text += "\n"
        end
      end

      text.strip
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
