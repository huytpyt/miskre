class RequestProduct < ApplicationRecord
  belongs_to :user
  has_many :image_requests
end
