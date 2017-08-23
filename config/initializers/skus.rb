SKU = []
space = ('A'..'Z').to_a
space.each do |c1|
  space.each do |c2|
    space.each do |c3|
      SKU << c1 + c2 + c3
    end
  end
end
