require 'test_helper'

class EventTest < ActiveSupport::TestCase

  test "testing events" do
    Event.create kind: 'opening', starts_at: DateTime.parse("2014-08-04 09:30"), ends_at: DateTime.parse("2014-08-04 12:30"), weekly_recurring: true
    Event.create kind: 'appointment', starts_at: DateTime.parse("2014-08-11 10:30"), ends_at: DateTime.parse("2014-08-11 11:30")
    availabilities = Event.availabilities DateTime.parse("2014-08-10")

    assert_equal Date.new(2014, 8, 10), availabilities[0][:date]
    assert_equal [], availabilities[0][:slots]
    assert_equal Date.new(2014, 8, 11), availabilities[1][:date]
    assert_equal ["9:30", "10:00", "11:30", "12:00"], availabilities[1][:slots]
    assert_equal [], availabilities[2][:slots]
    assert_equal Date.new(2014, 8, 16), availabilities[6][:date]
    assert_equal 7, availabilities.length
  end

  test "starts_at should be before ends_at" do
    Event.create kind: 'opening', starts_at: DateTime.parse("2014-08-04 09:30"), ends_at: DateTime.parse("2014-08-04 12:30"), weekly_recurring: true
    Event.create kind: 'appointment', starts_at: DateTime.parse("2014-08-11 10:30"), ends_at: DateTime.parse("2014-08-11 11:30")
    availabilities = Event.availabilities DateTime.parse("2014-08-10")

    assert_operator availabilities[1][:slots].last.to_time, :>, availabilities[1][:slots].first.to_time
  end

  test "events with wrong time format should be invalid" do
    Event.create kind: 'opening', starts_at: DateTime.parse("2012-08-16 13:30"), ends_at: DateTime.parse("2012-08-16 10:00"), weekly_recurring: true
    availabilities = Event.availabilities DateTime.parse("2014-08-10")

    assert_equal [], availabilities[6][:slots]
  end

  # test "recuring openings should work on a recuring basis" do
  #   Event.create kind: 'opening', starts_at: DateTime.parse("2012-08-15 14:30"), ends_at: DateTime.parse("2012-08-15 16:00"), weekly_recurring: true
  #   Event.create kind: 'appointment', starts_at: DateTime.parse("2014-08-13 15:30"), ends_at: DateTime.parse("2014-08-13 16:00")
  #   availabilities = Event.availabilities DateTime.parse("2014-08-10")

  #   assert_equal ["14:30", "15:00"], availabilities[3][:slots]
  # end

  test "recuring openings are only available after their starting date" do
    Event.create kind: 'opening', starts_at: DateTime.parse("2014-08-18 09:30"), ends_at: DateTime.parse("2014-08-18 12:30"), weekly_recurring: true
    availabilities = Event.availabilities DateTime.parse("2014-08-10")

    assert_equal [], availabilities[1][:slots]
  end

  test "slots should be sorted" do
    Event.create kind: 'opening', starts_at: DateTime.parse("2014-08-10 02:30"), ends_at: DateTime.parse("[D2014-08-10 04:30"), weekly_recurring: true
    Event.create kind: 'opening', starts_at: DateTime.parse("2014-08-03 04:30"), ends_at: DateTime.parse("2014-08-03 08:30"), weekly_recurring: true

    availabilities = Event.availabilities DateTime.parse("2014-08-10")

    assert_equal ["2:30", "3:00", "3:30", "4:00", "4:30", "5:00", "5:30", "6:00", "6:30", "7:00", "7:30", "8:00"], availabilities[0][:slots]
  end

end
