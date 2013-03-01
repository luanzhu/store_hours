require 'minitest/spec'
require 'minitest/autorun'

require 'store_hours'


describe StoreHours::StoreHours do
  before { @h = StoreHours::StoreHours.new }

  it "should return empty string for to_text() without loading from text" do
    @h.to_text.must_equal ''
  end

  it "should parse store hours text and format text" do
    text = "Mon     -    Thu  : 9:00AM    -        5:00PM, 6PM-9PM        Fri: 9AM - 10PM
            Sun: closed"
    r, msg = @h.from_text(text)

    r.must_equal true
    @h.to_text.must_equal "Mon-Thu: 9:00AM - 5:00PM, 6:00PM - 9:00PM\nFri: 9:00AM - 10:00PM\nSun: closed"
  end

  it "should return true for valid text" do
    text = "mon: 10:00am - 5:00pm mon-fri : 10am-5pm sat - sun: closed sun : closed Sat: 10am - 3:30pm 5pm-11pm"

    @h.from_text(text)[0].must_equal true
  end

  it "should return false for invalid text" do
    texts = ["M-T 9:00am-5pm", "mon  10am - 5pm", "mon-fri: 10:am - 5pm", "mon-fri: 10 am - 5 pm",  "mon : 10am - 17",
             "sat-sun: 10am-1pm closed", "sat-sun:  closed  10am-1pm", "mon fri: 10am - 5pm"
    ]

    texts.each do |t|
      @h.from_text(t)[0].must_equal false
    end
  end

  it "should check whether the store is open for a time object" do
    text = "Mon-Fri: 8AM - 12PM, 1pm-5pm\nSat-Sun: closed"

    r, msg = @h.from_text(text)

    r.must_equal true

    t = Time.new(2013, 2, 24, 11, 0) #2013 Feb 24, 11:00AM, Sunday
    @h.is_open?(t).must_equal false

    t = Time.new(2013, 2, 23, 17, 0) #2013 Feb 23, 5:00PM, Saturday
    @h.is_open?(t).must_equal false

    t = Time.new(2013, 2, 21, 8, 0) #2013 Feb 21, 8:00AM Thursday
    @h.is_open?(t).must_equal true

    t = Time.new(2013, 2, 20, 16, 59) #2013 Feb 20, 4:59PM Wednesday
    @h.is_open?(t).must_equal true

    t = Time.new(2013, 2, 20, 17, 1) #2013 Feb 20, 5:01PM Wednesday
    @h.is_open?(t).must_equal false

    t = Time.new(2013, 2, 19, 7, 59) #2013 Feb 19, 7:59AM Tuesday
    @h.is_open?(t).must_equal false

    t = Time.new(2013, 2, 18, 12, 30) #2013 Feb 18, 12:30PM Monday
    @h.is_open?(t).must_equal false
  end

  it "should work with stores what open after the midnight" do
    text = "Mon-Sun: 12:30AM-10PM"

    r, msg = @h.from_text(text)

    r.must_equal true

    t = Time.new(2013, 2, 24, 0, 0) #2013 Feb 24 12:00AM
    @h.is_open?(t).must_equal false
    t = Time.new(2013, 2, 24, 0, 15) # 2013 Feb 24, 12:15AM
    @h.is_open?(t).must_equal false
    t = Time.new(2013, 2, 24, 0, 30) #2013 Feb 24, 12:30AM
    @h.is_open?(t).must_equal true
    t = Time.new(2013, 2, 24, 22, 0) #2013 Feb 24, 10:00PM
    @h.is_open?(t).must_equal true
    t = Time.new(2013, 2, 24, 22, 1) #2013 Feb 24, 10:01PM
    @h.is_open?(t).must_equal false
  end

  it "should return false for invalid time periods" do
    texts = ["Mon-Fri: 9pm - 5am", "Sat: 5:30pm - 1:00pm"]

    texts.each do |t|
      r, msg = @h.from_text(t)

      r.must_equal false
    end
  end

  it "should return false for invalid day periods" do
    texts = ["Fri-Mon: 10:00pm - 11pm", "sun-mon: 1am-3pm"]
    texts.each do |t|
      r, msg = @h.from_text(t)
      r.must_equal false
    end
  end

  it "should return false for overlap in time periods for a single day range" do
    texts = ["mon-fri: 10am-5pm 4pm-10pm", "mon: 10am-5pm 5pm-9pm"]
    texts.each do |t|
      r, msg = @h.from_text(t)
      r.must_equal false
    end
  end

end