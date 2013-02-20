require 'minitest/spec'
require 'minitest/autorun'

require 'store_hours'

describe StoreHours do
  it "parse standard store hours text" do
    text = <<ENDOFTEXT
Tue: 10:00AM-5:00PM, 10:00PM-11:00PM Mon     -    Fri  : 9:00PM    -        5:00PM    Sun:
 closed

 Tue: 10:00AM-5:00PM, 10:00PM-11:00PM Mon     -    Fri  : 9:00PM    -
      5:00PM    Sun: closed
ENDOFTEXT
    h = StoreHours.new
    puts h.methods.sort
    h.parse(text)
  end
end