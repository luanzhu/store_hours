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
    r = h.from_text(text)

    r.must_equal true
    h.to_text.must_equal "Mon-Thu: 9:00AM - 5:00PM, 6:00PM - 9:00PM\nFri: 9:00AM - 10:00PM\nSun: closed"
  end

  it "should return false for invalid text" do
    text = "M-T 9:00am-5pm"
    h = StoreHours::StoreHours.new
    r = h.from_text(text)

    r.must_equal false
  end

  it "should check whether the store is open for a time object" do
    text = "Mon-Fri: 8AM - 12PM, 1pm-5pm\nSat-Sun: closed"
    h = StoreHours::StoreHours.new
    r = h.from_text(text)

    r.must_equal true

    t = Time.new(2013, 2, 24, 11, 0) #2013 Feb 24, 11:00AM, Sunday
    h.is_open?(t).must_equal false

    t = Time.new(2013, 2, 23, 17, 0) #2013 Feb 23, 5:00PM, Saturday
    h.is_open?(t).must_equal false

    t = Time.new(2013, 2, 21, 8, 0) #2013 Feb 21, 8:00AM Thursday
    h.is_open?(t).must_equal true

    t = Time.new(2013, 2, 20, 16, 59) #2013 Feb 20, 4:59PM Wednesday
    h.is_open?(t).must_equal true

    t = Time.new(2013, 2, 20, 17, 1) #2013 Feb 20, 5:01PM Wednesday
    h.is_open?(t).must_equal false

    t = Time.new(2013, 2, 19, 7, 59) #2013 Feb 19, 7:59AM Tuesday
    h.is_open?(t).must_equal false

    t = Time.new(2013, 2, 18, 12, 30) #2013 Feb 18, 12:30PM Monday
    h.is_open?(t).must_equal false
  end

end