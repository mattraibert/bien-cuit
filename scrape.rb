require 'ymca'

y = Ymca.new
my_ys = [1,26,28,31]

y.get_branches.each do |branch|
  File.write("#{branch.name}.json",y.fill_scheduler([branch.id]))
end
