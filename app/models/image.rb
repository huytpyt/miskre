# == Schema Information
#
# Table name: images
#
#  id                :integer          not null, primary key
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  file_file_name    :string
#  file_content_type :string
#  file_file_size    :integer
#  file_updated_at   :datetime
#  imageable_type    :string
#  imageable_id      :integer
#
# Indexes
#
#  index_images_on_imageable_type_and_imageable_id  (imageable_type,imageable_id)
#

require 'base64'

class Image < ApplicationRecord
  audited
  has_attached_file :file, styles: { medium: "300x300>", thumb: "100x100>" }, default_url: "/images/:style/missing.png"
  validates_attachment_content_type :file, content_type: /\Aimage\/.*|text\/plain\z/

  # belongs_to :product
  belongs_to :imageable, polymorphic: true

  def file_remote_url=(url_value)
    self.file = URI.parse(url_value)
  end

  def file_url
    file.url(:medium)
  end

  def set_image_base64(base64_str)
    img = Paperclip.io_adapters.for(base64_str)
    # img.original_filename = image_name
    self.file = img
   end
end
