require 'csv'
require 'json'
require 'pp'

# ePUB price
rows = CSV.read('ePUB.csv')
rates = {}
rows[1..-1].each do |row|
  rates[row[1]] ||= []
  # rates[row[1]][row[0].to_i] = row[2].gsub('$', '').to_f
  rates[row[1]] << [row[0].to_i, row[2].gsub('$', '').to_f]
end

pp rates      
File.open('ePUB.rb', 'w') {|f| f.write(rates)}
 
"""
# DHL price
rows = CSV.read('DHL.csv')
rates = {}

rows[1..-1].each do |row|
  row[1..-1].each_with_index do |value, index|
    rates[rows[0][index + 1]] ||= []
    # rates[rows[0][index + 1]][(row[0].to_f * 1000).to_i] = value.gsub('$', '').to_f
    rates[rows[0][index + 1]] << [(row[0].to_f * 1000).to_i, value.gsub('$', '').to_f]
  end
end

File.open('DHL.rb', 'w') {|f| f.write(rates)}
"""
# pp rates
# File.open("DHL.rb","w") do |f|
#   PP.pp(rates,f)
# end
