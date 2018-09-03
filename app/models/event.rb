class Event < ApplicationRecord
  validates :starts_at, :ends_at, :kind, presence: :true

  def self.availabilities(start_date = DateTime.now)
    availabilities = []
    # 1.fetch all recuring and non-recuring events for the next seven days
    events = Event.where("starts_at >= ? OR weekly_recurring = ?", start_date.beginning_of_day, true)

    7.times do |count|
      day = start_date + count.days

      # 2.select all available slots
      openings = events.select {|e| day.wday == e.starts_at.wday && e.kind == "opening" && e.starts_at <= day.end_of_day }
      available_slots = self.get_slots(openings)

      # 3.select all unavailable slots
      appointments = events.select {|e| day.wday == e.starts_at.wday && e.kind == "appointment" }
      unavailable_slots = self.get_slots(appointments)

      # 4.remove unavailable slots from available slots and sort them by time
      slots = (available_slots - unavailable_slots).uniq.sort_by {|time| time.to_time }

      # 5.add element to array in the right format
      availabilities << { date:  day, slots: slots.map{|e| e[0] == "0" ? e[1, e.length] : e } }
    end

    # 6.return array of available time slots for the next 7 days
    return availabilities
  end

  private

  def self.get_slots(events)
    slots = []
    events.each do |event|
      time = event.starts_at
      (((event.ends_at.to_i - event.starts_at.to_i)/60)/30).times do
        slots << time.strftime('%H:%M')
        time += 30.minutes
      end
    end
    return slots
  end

end
