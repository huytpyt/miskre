module BuildQuery
  extend ActiveSupport::Concern

  def build_single_query model, record
    json_data = model.new.attributes
    json_data.each do |key, value|
      json_data["#{key}"] = record.send(key)
    end
  end
end
