require 'net/http'
require 'uri'
require 'json'
require 'hashie'
require 'date'

class Ymca
  BASE_URL = 'http://www.activelifeadmin.com/newyork/websearch/public/index/'

  # curl 'http://www.activelifeadmin.com/newyork/websearch/public/index/fillclassesForDate'
  # --data 'sched_type_ids=Group+Exercise+Schedule&branch_ids=26&page_no=0&classSel=VINYASA+YOGA&selectedDate=2015-03-20'
  def fill_classes_for_date(branch_ids = [1], selected_date = Date.today, class_sel = '', sched_type_ids = 'Group Exercise Schedule', page_no = 0)
    post(URI(BASE_URL + 'fillclassesForDate'),
         {sched_type_ids: sched_type_ids,
          branch_ids: branch_ids.join(','),
          selectedDate: selected_date.strftime('%Y-%m-%d'),
          page_no: page_no})
  end

  # curl 'http://www.activelifeadmin.com/newyork/websearch/public/index/fillscheduler'
  # --data 'sched_type_ids=Group+Exercise+Schedule&branch_ids=26&classSel=VINYASA+YOGA&month=3&year=2015&day=16'
  def fill_scheduler(branch_ids = [1], selected_date = Date.today, class_sel = '', sched_type_ids = ['Group Exercise Schedule'], page_no = 0)
    post(URI(BASE_URL + 'fillscheduler'),
         {sched_type_ids: sched_type_ids.join(?,),
          branch_ids: branch_ids.join(?,),
          year: selected_date.year,
          month: selected_date.month,
          day: selected_date.day})
  end

  # curl 'http://www.activelifeadmin.com/newyork/websearch/public/index/getscheduleslist'
  # --data 'branch_ids=1%2C26'
  def get_schedules_list(branch_ids=[1])
    post(URI(BASE_URL + 'getscheduleslist'), {branch_ids: branch_ids.join(?,)})
  end

  # curl 'http://www.activelifeadmin.com/newyork/websearch/public/index/getclasses'
  # --data 'sched_type_ids=Group+Exercise+Schedule&branch_ids=1'
  def get_classes(branch_ids=[1], sched_type_ids = 'Group Exercise Schedule')
    post(URI(BASE_URL + 'getclasses'),
         {sched_type_ids: sched_type_ids,
          branch_ids: branch_ids.join(',')})
  end

  def get_branches
    json(File.read('json/locations.json'))
  end

  private
  def post(uri, params)
    response = Net::HTTP.post_form(uri, params)
    if response.code == '200'
      json(response.body)
    else
      response
    end
  end

  def json(txt)
    mash(JSON.parse(txt))
  end

  def mash(data)
    if data.respond_to?(:each_pair)
      Hashie::Mash.new(data)
    else
      if data.respond_to?(:map) && data.first.respond_to?(:each_pair)
        data.map { |d| Hashie::Mash.new(d) }
      else
        Hashie::Mash.new({data: data})
      end
    end
  end
end
