# == Schema Information
#
# Table name: resource_images
#
#  id                :integer          not null, primary key
#  file_file_name    :string
#  file_content_type :string
#  file_file_size    :integer
#  file_updated_at   :datetime
#  product_id        :integer
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#
# Indexes
#
#  index_resource_images_on_product_id  (product_id)
#
require 'base64'
class ResourceImage < ApplicationRecord
  has_attached_file :file, styles: { medium: "300x300>", thumb: "150x150>" }, default_url: "/images/:style/missing.png"
  validates_attachment_content_type :file, content_type: /\Aimage\/.*|text\/plain\z/
  belongs_to :product

  def file_remote_url=(url_value)
    self.file = URI.parse(url_value)
  end

  def file_url
    file.url(:medium)
  end

  def set_image_base64(base64_str)
    img = Paperclip.io_adapters.for(base64_str)
    self.file = img
   end
end
