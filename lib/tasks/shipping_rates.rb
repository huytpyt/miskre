require 'csv'
require 'json'
require 'pp'

# CSV.foreach("ePUB.csv") do |row|
#   p row
# end
rows = CSV.read("ePUB.csv")
rates = {}
rows[1..-1].each do |row|
  rates[row[1]] ||= {}
  rates[row[1]][row[0].to_i] = row[2].gsub('$', '').to_f
end

pp rates
File.open("ePUB.rb", "w") {|f| f.write(rates)}
