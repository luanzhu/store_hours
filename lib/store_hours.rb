require 'parslet'

require "store_hours/version"
require "store_hours/text_input_parser"

module StoreHours
  class StoreHours
    def parse(s)
      parser = TextInputParser.new
      parser.parse(s)
    end
  end
end
