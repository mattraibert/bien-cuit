require 'ymca'

y = Ymca.new

y.get_branches.each do |branch|
  File.write("#{branch.name}.json",y.fill_scheduler([branch.id]))
end
