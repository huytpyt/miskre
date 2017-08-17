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

    def get_weight(w)
      weight = w.match(/([\d\.]+)/).to_a
      result = weight.empty? ? 0.0 : weight.first.to_f
      if w.downcase.include? 'kg'
        return result * 1000
      else
        return result
      end
    rescue 
      0.0
    end

    Product.destroy_all
    xlsx = Roo::Excelx.new("lib/tasks/product_list.xlsx")
    (xlsx.first_row + 1..xlsx.last_row).each do |i|
    # (xlsx.first_row + 1..3).each do |i|
      row = xlsx.row(i)

      length, width, height = get_dimension(row[9])
      color = row[7] ? row[7].split("\n") : []
      params = {
        'name' => row[1],
        'link' =>  row[2],
        'cost' => get_cost(row[5]),
        'length' => length,
        'width' => width,
        'height' => height,
        'weight' => get_weight(row[10])
      }

      # p params
      p = Product.create(params)

      unless color.empty?
        # p params["name"]
        # p color
        option = p.options.create(name: 'color', values: color)
        p.regen_variants
        p.variants.update_all(price: p.price)
      end

      """
      name = xlsx.row(i)[1]

      # cost = /([\d\.]+)/.match(xlsx.row(i)[2]).to_a
      cost = get_cost(xlsx.row(i)[2])

      color =  xlsx.row(i)[3] ? xlsx.row(i)[3].split('\n') : []

      length, width, height = get_dimension(xlsx.row(i)[4])

      weight = 0.0

      p = Product.create(name: name, cost: cost, length: length, width: width, height: height, weight: weight)

      unless color.empty?
        option = p.options.create(name: 'color', values: color)
        p.regen_variants
        p.variants.update_all(price: p.price)
        p 'name', name
      end

      # p '*' * 20
      # p 'name', name
      # p 'cost', cost
      # p 'color', color
      # p 'size', length, width, height
      # p '*' * 20
      """
    end
  end
end
