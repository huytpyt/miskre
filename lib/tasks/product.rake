require 'roo'

namespace :product do
  task :import_from_file => :environment do
    def convert(st, metric)
      if st
        metric == 'mm' ? st.to_f / 10 : st.to_f
      else
        0.0
      end
    end

    def get_dimension(size)
      length, width, height = 0.0, 0.0, 0.0
      if size
        size = size.to_s
        size_metric = size.include?('mm') ? 'mm' : 'cm'
        l, w, h = size.scan(/[\d\.]+/)

        length = convert(l, size_metric)
        width = convert(w, size_metric)
        height = convert(h, size_metric)
      end

      return [length, width, height]
    end

    def get_cost(v)
      costs = v.match(/([\d\.]+)/).to_a
      costs.empty? ? 0.0 : costs.first.to_f
    rescue
      0.0
    end

    xlsx = Roo::Excelx.new("lib/tasks/product_list.xlsx")
    (xlsx.first_row..xlsx.last_row).each do |i|
      name = xlsx.row(i)[1]

      # cost = /([\d\.]+)/.match(xlsx.row(i)[2]).to_a
      cost = get_cost(xlsx.row(i)[2])

      color =  xlsx.row(i)[3] ? xlsx.row(i)[3].split("\n") : []

      length, width, height = get_dimension(xlsx.row(i)[4])

      Product.create(name: name, cost: cost, length: length, width: width, height: height)

      p '*' * 20
      p 'name', name
      p 'cost', cost
      p 'color', color
      p 'size', length, width, height
      p '*' * 20
    end
  end
end
