require 'parslet'

require "store_hours/version"
require "store_hours/text_input_parser"
require "store_hours/tree_transformer"
require "store_hours/semantic_error"
require "store_hours/common_methods"

require "json"

module StoreHours
  # A very simple parser to parse text like
  #       Mon-Fri:  9AM-5PM
  #       Sat:      10AM-7PM
  #       Sun:      closed
  # and build an internal data structure to enable possible formatting and queries.
  #
  # This class is designed to use when (1) you like to use a single text field in
  # database to store open hours, and (2) you would like to be able to check whether
  # the store opens for a certain time, or to make sure inputs are valid, or to
  # display the hours in a format different from user input (for example, take plain
  # text from users, but to format the input in html to display).
  #
  # Here is an example about how to use this class in rails. Suppose you have a model
  # called "Store" with a text filed named normal_business_hours, you can add this validation
  # method:
  # 
  #   validate :normal_business_hours_must_be_in_valid_format
  #   def normal_business_hours_must_be_in_valid_format
  #     hours_parser = ::StoreHours::StoreHours.new
  #     #check whether input is valid?
  #     success, error_message  = hours_parser.from_text(self.normal_business_hours)
  #     if !success
  #       #input is not valid
  #       errors.add(:normal_business_hours, error_message)
  #     end
  #   end
  #
  # Please refer to text_input_parser.rb and tree_transformer.rb to get some idea
  # of what kinds of inputs are valid.
  #
  class StoreHours
    def initialize
      @hours = []
    end

    # Try to parse the input text.
    # @param text [String] store hours text input, case-insensitive
    # @return [Boolean, String] returns [true, ''] if the text is valid, otherwise,
    # the return value will be [false, "error message"]
    #
    # This method will build the internal data structure for valid text argument.
    #
    # Please don't ignore the return value from this method as it is the only way to
    # know whether input is valid.
    #
    def from_text(text)
      text = '' if text == nil
      result = true
      error_message = ''

      begin
        # parse the text into an intermediary tree
        # this call may raise Parslet::ParseFailed exception
        tree = TextInputParser.new.parse(text.strip.downcase)

        # convert the tree into internal data structure
        # please refer to tree_transformer.rb for the details of this structure
        # this call may raise StoreHours::SemanticError exception
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

      return [result, error_message]
    end

    # This is the method you can use to display store hours.
    def to_text
      text = ''
      @hours.each do |days_table|
        days = days_table.keys.first  #days is the day range, for example, (1..5)
        if block_given?
          text += yield NUM_TO_WEEKDAY[days.first], NUM_TO_WEEKDAY[days.last], days_table[days]
        else
          text += NUM_TO_WEEKDAY[days.first].to_s
          text += "-" + NUM_TO_WEEKDAY[days.last].to_s if days.first != days.last
          text += ": "

          days_table[days].each_with_index do |minutes, index|
            text += ', ' if index > 0
            if minutes.first == -1  #closed days
              text += "closed"
            elsif
              text += ::StoreHours::from_minutes_to_time_str(minutes.first) + " - " + ::StoreHours::from_minutes_to_time_str(minutes.last)
            end
          end
          text += "\n"
        end
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


  end



end
