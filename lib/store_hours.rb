require 'parslet'

require "store_hours/version"
require "store_hours/text_input_parser"

module StoreHours
  class StoreHours

    def parse(text)
      throw ArgumentError.new('Input text cannot be nil') if text == nil
      parser = TextInputParser.new
      tree = parser.parse(text.strip.downcase)
      format(tree)
    rescue Parslet::ParseFailed => failure
      puts failure.cause.ascii_tree
      nil
    end

    private
    def format(tree)
      s = ''
      tree[:lines].each do |line|
        left = line[:line_left]
        if left.key?(:day_single)
          s += left[:day_single].to_s.capitalize
        elsif left.key?(:day_range)
          s += "#{left[:day_range][:day_from].to_s.capitalize}-#{left[:day_range][:day_to].to_s.capitalize}"
        end
        s += ': '
        right = line[:line_right]
        if right.key?(:closed)
          s += 'closed'
        else
          right[:time_range].each_with_index do |trange, index|
            s += ', ' if index > 0
            s += "#{ trange[:time_from].to_s.upcase } - #{ trange[:time_to].to_s.upcase }"
          end
        end
        s += "\n"
      end

      s.strip
    end

  end
end
