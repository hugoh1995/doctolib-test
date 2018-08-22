class Event < ApplicationRecord
  validates :starts_at, :ends_at, :kind, presence: :true

  def self.availabilities(start_date = DateTime.now)
    availabilities = []
    # 1.fetch all recuring and non-recuring events for the next seven days
    openings = Event.where("starts_at >= ?", start_date.beginning_of_day).where(weekly_recurring: [nil, false], kind: "opening")
    recuring_openings = Event.where(weekly_recurring: true, kind: "opening")

    appointments = Event.where(kind: "appointment")

    7.times do |count|
      day = start_date + count.days

      # 2.select all available slots
      data1 = openings
        .where("starts_at >= ? AND ends_at <= ?", day.beginning_of_day, day.end_of_day).or(recuring_openings)
        .order(:starts_at)
        .select {|k| day.wday == k.starts_at.wday }
      available_slots = self.get_slots(data1)

      # 3.select all unavailable slots
      data2 = appointments
        .where("starts_at >= ? AND ends_at <= ?", day.beginning_of_day, day.end_of_day)
        .order(:starts_at)
      unavailable_slots = self.get_slots(data2)

      # 4.remove unavailable slots from available slots
      slots = (available_slots - unavailable_slots).uniq.sort_by {|time| ((time.split(':')[0].to_i * 60) + time.split(':')[1].to_i) }

      # 5.add element to array in the right format
      availabilities << { date:  day, slots: slots.map{|e| e[0] == "0" ? e[1, e.length] : e } }
    end

    # 6.return array of available time slots for the next 7 days
    return availabilities
  end

  private

  def self.get_slots(data)
    slots = []
    data.each do |event|
      time = event.starts_at
      (((event.ends_at.to_i - event.starts_at.to_i)/60)/30).times do
        slots << time.strftime('%H:%M')
        time += 30.minutes
      end
    end
    return slots
  end

end
