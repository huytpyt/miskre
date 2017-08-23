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
      if (length == 0 && width == 0 && height == 0)
        length, width, height = get_dimension(row[8])
      end
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
      p = Product.create(params)
      # p params

      unless color.empty?
        # p params["name"]
        # p color
        option = p.options.create(name: 'color', values: color)
        p.regen_variants
        p.variants.update_all(price: p.price)
      end
    end
  end

  task :generate_purchase_list => :environment do
    CSV.open("purchase_list.csv", "wb") do |csv|
      csv << ["ProductName", "SKU", "Quantity", "Link"]

      Product.order(sku: :asc).each do |p|
        if p.variants.count <= 1
          csv << [p.name, p.sku, 5, p.link]
        else
          first = true
          p.variants.each do |v|
            if first
              csv << [p.name, v.sku + " - " + v.option1, 3, p.link]
              first = false
            else
              csv << ["", v.sku + " - " + v.option1, 3, ""]
            end
          end
        end

        csv << []
      end
    end
  end
end
