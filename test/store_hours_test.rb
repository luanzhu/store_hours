require 'minitest/spec'
require 'minitest/autorun'

require "minitest/reporters"
MiniTest::Reporters.use!

require 'store_hours'


describe StoreHours::StoreHours do
  it "parse store hours text" do
    text = "Mon     -    Fri  : 9:00AM    -        5:00PM
            Sun: closed"
    h = StoreHours::StoreHours.new
    h.from_text(text)

    puts h.to_text
  end


end