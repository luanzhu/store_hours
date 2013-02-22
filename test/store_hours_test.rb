require 'minitest/spec'
require 'minitest/autorun'

require "minitest/reporters"
MiniTest::Reporters.use!

require 'store_hours'


describe StoreHours::StoreHours do
  it "parse standard store hours text" do
    text = "Tue: 10:00AM-5:00PM, 10:00PM-11:00PM Mon     -    Fri  : 9:00PM    -        5:00PM    Sun:
        closed

      Tue: 10:00AM-5:00PM, 10:00PM-11:00PM Mon     -    Fri  : 9:00PM    -
      5:00PM    Sun: closed
"
    h = StoreHours::StoreHours.new
    h.parse(text)

    text = "
      Tue: 10:00AM-5:00PM, 10:00PM-11:00PM Mon     -    Fri  : 9:00PM    -        5:00PM    Sun:
        closed

        Tue: 10:00AM-5:00PM, 10:00PM-11:00PM Mon     -    Fri  : 9:00PM    -
            5:00PM    Sun: closed
    "
    h.parse(text)
  end

  it "format valid store hours text" do
    text = "
      Tue: 10:00AM-5:00PM, 10:00PM-11:00PM Mon     -    Fri  : 9:00PM    -        5:00PM    Sun:
     closed

      "

    h = StoreHours::StoreHours.new
    s = h.parse(text)
    s.must_equal "Tue: 10:00AM - 5:00PM, 10:00PM - 11:00PM
Mon-Fri: 9:00PM - 5:00PM
Sun: closed"
  end

  it "should return nil for empty string, raise exception for nil input" do
    h = StoreHours::StoreHours.new
    s = h.parse('')
    s.must_be_nil

    proc { h.parse(nil) }.must_raise ArgumentError
  end

  it "should take time with or without time components" do
    h = StoreHours::StoreHours.new
    s = h.parse("Tue: 10:00AM-5PM, 10:00PM-11:00PM Mon     -    Fri  : 9:1PM    -        5:00PM ")
    s.wont_be_nil

    puts s
  end
end