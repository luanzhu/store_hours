# StoreHours

A very simple parser to parse text like

    Mon-Fri:  9AM-5PM
    Sat:      10AM-7PM
    Sun:      closed

and build an internal data structure to enable possible formatting and queries.

This class is designed for situations where (1) you like to use a single text field in database to store open hours, and (2) you would like to be able to check whether the store opens for a certain time, or to make sure inputs are valid, or to display the hours in a format different from user input (for example, format the input in html to display on website).

Here is an example about how to use this class in rails. Suppose you have a model
called "Store" with a text filed named normal_business_hours, you can add this validation
method:

    validate :normal_business_hours_must_be_in_valid_format
    def normal_business_hours_must_be_in_valid_format
        hours_parser = ::StoreHours::StoreHours.new
        #check whether input is valid?
        success, error_message  = hours_parser.from_text(self.normal_business_hours)
        if !success
            #input is not valid
            errors.add(:normal_business_hours, error_message)
        end
    end

Examples of valid input:

    Mon: 8AM-12PM 2PM-6PM
    Tue: 8:30AM-5:30PM
    Wed-Fri: 9:00AM - 4:50PM 6:00PM-10:30PM
    Sat: 10AM-1PM 1:30PM - 6PM
    Sun: closed
    mon: 10:00am - 5:00PM           #case insensitive
    mon: 8:00am-12:00pm, 1pm-5pm    #time periods can be separated by comma(,) or space
    mon: 8:00am-12:00pm 1pm-5pm
    mon-fri : 10am-5pm
    sat - sun: closed
    sun : closed
    
Examples of invalid entries:

    mon  10am - 5pm           # colon(:) after week day(s) is required
    mon fri: 10am - 5pm       # dash(-) between two days is required
    mon-fri: 10:am - 5pm      # minute component for time is required when the colon(:) is present
    mon-fri: 10 am - 5 pm     # no space is allowed between time digits and am/pm
    mon : 10am - 17           # standard time format (with am or pm) is required
    sat-sun: 10am-1pm closed  # closed cannot be used with other time periods

## Usage

```
#!ruby
1.9.3-p194 :001 > require 'store_hours'
 => true 
1.9.3-p194 :002 > hours_parser = ::StoreHours::StoreHours.new
 => #<StoreHours::StoreHours:0x007fb5dc1bead8 @hours=[]> 
1.9.3-p194 :003 > hours_parser.from_text('mon:10:40am-5pm tue:8am-')
 => [false, "syntax error: input is not in correct format"] 
1.9.3-p194 :004 > hours_parser.from_text('mon:10:40am-5pm tue:8am-6pm')
 => [true, ""] 
1.9.3-p194 :006 > puts hours_parser.to_text
Mon: 10:40AM - 5:00PM
Tue: 8:00AM - 6:00PM
1.9.3-p194 :007 > puts hours_parser.to_text.gsub("\n","<br/>")
Mon: 10:40AM - 5:00PM<br/>Tue: 8:00AM - 6:00PM
 => nil 
1.9.3-p194 :008 > hours_parser
 => #<StoreHours::StoreHours:0x007fb5dc1bead8 @hours=[{1..1=>[640..1020]}, {2..2=>[480..1080]}]> 
```

## Limitations

Time periods can only be within 0AM-11:59PM.  In other words, time periods like 11:30PM-6:00AM are not supported.

## Installation

Add this line to your application's Gemfile:

    gem 'store_hours'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install store_hours

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
