require 'icalendar'
require "icalendar/tzinfo"
require 'active_support/core_ext/date_time'

class YCal
  def initialize(tzid = 'America/New_York')
    @cal = Icalendar::Calendar.new
    tz = TZInfo::Timezone.get(tzid)
    @cal.add_timezone tz.ical_timezone(DateTime.now)
  end

  # {"id"=>"22484",
  #  "pid"=>"0",
  #  "branch_id"=>"1",
  #  "program_id"=>"304",
  #  "class_id"=>"624",
  #  "instructor_id"=>"519",
  #  "room_id"=>"139",
  #  "description"=>"Flowing sequences of yoga poses linked together by an emphasis on breathing technique.",
  #  "start_date"=>"2014-09-12 08:00:00",
  #  "end_date"=>"9999-12-31 23:59:59",
  #  "duration"=>"60",
  #  "rec_type"=>"W",
  #  "rec_sub_type"=>"1,Sat",
  #  "choreography_level"=>"",
  #  "exclusions"=>"",
  #  "created_at"=>"2014-09-12 15:40:47",
  #  "updated_at"=>"2014-09-12 15:40:47",
  #  "class_start_time"=>"08:00:00",
  #  "class_end_time"=>"09:00:00",
  #  "title"=>"Group Exercise",
  #  "class_name"=>"Vinyasa Yoga ",
  #  "branch_name"=>"Bedford-Stuyvesant YMCA",
  #  "room"=>" Aerobics Room (Lower Level)",
  #  "sched_type"=>"Group Exercise Schedule",
  #  "instructor"=>"Miho",
  #  "event_start_date"=>"2014-09-12",
  #  "event_end_date"=>"9999-12-31",
  #  "date"=>"2015-03-21"}

  # Icalendar::Values::Date.new('20050429')
  def event(y)
    @cal.event do |e|
      e.dtstart = start(y)
      e.dtend = start(y) + y.duration.to_i.minutes
      e.summary = summary(y)
      e.description = y.description
    end
  end

  def start(y)
    DateTime.strptime(y.start_date, '%Y-%m-%d %H:%M:%S')
  end

  def summary(y)
    short_title = if y.title.strip =~ /\ayoga\Z/i
                    y.title
                  else
                    y.title.sub(/ *yoga */i, '')
                  end
    "#{short_title} w/#{y.instructor}"
  end

  def publish
    @cal.publish
  end

  def to_ical
    @cal.to_ical
  end
end