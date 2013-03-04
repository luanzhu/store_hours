module StoreHours

  # Convert a time point in a day to the number of minutes passed since midnight.
  # @param hour [Fixnum] the hour component of time (not in military format)
  # @param minutes [Fixnum] the minutes component of time
  # @param am_or_pm [Symbol, :am or :pm]  morning or afternoon
  # @return [Fixnum] the number of minutes passed since midnight
  #
  def self.convert_time_input_to_minutes(hour, minutes, am_or_pm)
    hour += 12 if am_or_pm == :pm and hour < 12
    hour = 0 if am_or_pm == :am and hour == 12

    hour * 60 + minutes
  end

  # This is the reverse function of convert_time_input_to_minutes(hour, minutes,
  # am_or_pm).
  #
  # This function coverts the number of minutes passed since midnight to a
  # standard time string like 10:00AM.
  # @param t [Fixnum] the number of minutes passed since midnight
  # @return [String] the standard time string
  #
  def self.from_minutes_to_time_str(t)
    hour_part = t / 60
    minute_part = t % 60

    am_or_pm = (hour_part >= 12 ? 'PM' : 'AM')
    hour_part = hour_part - 12 if hour_part >= 13

    "#{ hour_part }:#{ format('%02d', minute_part) }#{ am_or_pm }"
  end
end