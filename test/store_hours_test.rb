require 'minitest/spec'
require 'minitest/autorun'

require "minitest/reporters"
MiniTest::Reporters.use!

require 'store_hours'


describe StoreHours::StoreHours do
  it "should return empty string for to_text() without loading from text" do
    h = StoreHours::StoreHours.new

    h.to_text.must_equal ''
  end

  it "should parse store hours text and format text" do
    text = "Mon     -    Thu  : 9:00AM    -        5:00PM, 6PM-9PM        Fri: 9AM - 10PM
            Sun: closed"
    h = StoreHours::StoreHours.new
    h.from_text(text)

    h.to_text.must_equal "Mon-Thu: 9:00AM - 5:00PM, 6:00PM - 9:00PM\nFri: 9:00AM - 10:00PM\nSun: closed"
  end



end