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
      # Will false if text cannot be parsed
      #
      #
      text = '' if text == nil
      result = true

      begin
        tree = TextInputParser.new.parse(text.strip.downcase)

        @hours = TreeTransformer.new.apply(tree)

        result = true
      rescue Exception => e
        puts e.message
        result = false
      end

      result
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
            if h.first == -1 and h.last == -1
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

    def is_open?(t)
      @hours.each do |days|
        # days in the format of range(wday..wday) => [range(minutes..minutes),...]
        # only one key in each days hashtable
        k_days = days.keys.first
        if k_days.include?(t.wday == 0 ? 7 : t.wday)
          days[k_days].each do |min_range|
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
