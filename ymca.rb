require 'net/http'
require 'uri'
require 'json'
require 'hashie'
require 'date'

class Ymca
  def initialize(my_ys = [1, 26, 28, 31])
    @my_ys = my_ys
  end

  BASE_URL = 'http://www.activelifeadmin.com/newyork/websearch/public/index/'

  # curl 'http://www.activelifeadmin.com/newyork/websearch/public/index/fillclassesForDate'
  # --data 'sched_type_ids=Group+Exercise+Schedule&branch_ids=26&page_no=0&classSel=VINYASA+YOGA&selectedDate=2015-03-20'
  def fill_classes_for_date(branch_ids = @my_ys, selected_date = Date.today, class_sel = 'VINYASA YOGA', sched_type_ids = 'Group Exercise Schedule', page_no = 0)
    post(URI(BASE_URL + 'fillclassesForDate'),
         {sched_type_ids: sched_type_ids,
          branch_ids: branch_ids.join(','),
          selectedDate: selected_date.strftime('%Y-%m-%d'),
          classSel: class_sel,
          page_no: page_no})
  end

  # curl 'http://www.activelifeadmin.com/newyork/websearch/public/index/fillscheduler'
  # --data 'sched_type_ids=Group+Exercise+Schedule&branch_ids=26&classSel=VINYASA+YOGA&month=3&year=2015&day=16'
  def week_starting(selected_date = Date.today, branch_ids = @my_ys, class_sel = 'VINYASA YOGA',
                    sched_type_ids = ['Group Exercise Schedule'], page_no = 0)

    branch_ids.map do |branch_id|
      if class_sel.is_a? Array
        class_sel.map do |c|
          post(URI(BASE_URL + 'fillscheduler'),
               {sched_type_ids: sched_type_ids.join(?,),
                branch_ids: branch_id,
                year: selected_date.year,
                month: selected_date.month,
                classSel: c,
                day: selected_date.day})
        end.flatten
      else
        post(URI(BASE_URL + 'fillscheduler'),
             {sched_type_ids: sched_type_ids.join(?,),
              branch_ids: branch_id,
              year: selected_date.year,
              month: selected_date.month,
              classSel: class_sel,
              day: selected_date.day})
      end
    end
  end

  # curl 'http://www.activelifeadmin.com/newyork/websearch/public/index/getscheduleslist'
  # --data 'branch_ids=1%2C26'
  def get_schedules_list(branch_ids=@my_ys)
    post(URI(BASE_URL + 'getscheduleslist'), {branch_ids: branch_ids.join(?,)})
  end

  # curl 'http://www.activelifeadmin.com/newyork/websearch/public/index/getclasses'
  # --data 'sched_type_ids=Group+Exercise+Schedule&branch_ids=1'
  def get_classes(branch_ids=@my_ys, sched_type_ids = 'Group Exercise Schedule')
    post(URI(BASE_URL + 'getclasses'),
         {sched_type_ids: sched_type_ids,
          branch_ids: branch_ids.join(',')})
  end

  def get_branches
    json(File.read('json/locations.json'))
  end

  def yoga_classes(week_of = Date.today, branch_ids=@my_ys)
    names = yoga_class_list.map &:class_name
    self.week_starting(week_of, branch_ids, names)
  end

  private
  def yoga_class_list
    classes = self.get_classes
    classes.select { |x| x.class_name =~ /yoga/i }.reject { |x| x.class_name =~ /kid|baby|teen|AOA|tot|chair|natal|lates|fit|silver|mommy|toddler|family/i }
  end

  def post(uri, params)
    puts "#{uri} #{params}"
    response = Net::HTTP.post_form(uri, params)
    if response.code == '200'
      json(response.body)
    else
      response
    end
  end

  # def get()
  #   http://maps.googleapis.com/maps/api
  # end

  def json(txt)
    mash(JSON.parse(txt))
  end

  def mash(data)
    data = Hashie::Mash.new({data: data})
    while data.respond_to? :data
      data = data.data
    end
    data
  end
end
