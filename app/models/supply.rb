# == Schema Information
#
# Table name: supplies
#
#  id                   :integer          not null, primary key
#  product_id           :integer
#  shop_id              :integer
#  shopify_product_id   :string
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#  desc                 :text
#  price                :float
#  name                 :string
#  original             :boolean          default(TRUE)
#  fulfillable_quantity :integer
#  epub                 :float
#  dhl                  :float
#  cost_epub            :float
#  cost_dhl             :float
#  compare_at_price     :float
#  cost                 :float
#  keep_custom          :boolean          default(FALSE)
#  is_deleted           :boolean          default(FALSE)
#  user_id              :integer
#
# Indexes
#
#  index_supplies_on_product_id  (product_id)
#  index_supplies_on_shop_id     (shop_id)
#

class Supply < ApplicationRecord
  # include Elasticsearch::Model
  # include Elasticsearch::Model::Callbacks
  # Supply.import(force: true)
  belongs_to :shop
  belongs_to :product

  has_many :images, as: :imageable, dependent: :destroy
  has_many :supply_variants, dependent: :destroy

  validates :price, presence: true, numericality: { greater_than_or_equal_to: 0}
  validates :compare_at_price, presence: true, numericality: { greater_than_or_equal_to: 0}

  def self.search(search)
    if search
      where(['lower(name) LIKE ?', "%#{search.downcase}%"])
    else
      scoped
    end
  end

  def copy_product_attr_add_product
    product = self.product
    shop = self.shop
    self.name = product&.name
    self.cost = product.cus_cost
    self.cost_epub = product.cus_epub

    if shop.global_setting_enable == true
      self.price = (self.cost * shop.cost_rate + self.cost_epub * shop.shipping_rate).round(2)
    else
      self.price = product&.suggest_price
    end

    self.desc = product&.desc
    random = rand(shop.random_from .. shop.random_to)
    self.compare_at_price = (self.price * random/ 5).round(0) * 5
    self.epub = (1 - shop.shipping_rate)*product.cus_epub
  end

  def copy_product_attr
    product = self.product
    shop = self.shop
    if shop.present?
      self.name = product&.name
      self.cost = product.cus_cost
      self.cost_epub = product.cus_epub
      
      if shop.global_setting_enable == true
        self.price = (self.cost * shop.cost_rate + self.cost_epub * shop.shipping_rate).round(2)
      else
        self.price = product&.suggest_price
      end

      self.desc = product&.desc
      random = rand(shop.random_from .. shop.random_to)
      self.compare_at_price = (self.price * random/ 5).round(0) * 5
      self.epub = (1 - shop.shipping_rate)*product.cus_epub
      
      self.supply_variants.destroy_all
      random_for_variant = rand(shop.random_from .. shop.random_to)
      product.variants.each do |variant|
        compare_at_price = (variant.price * random_for_variant/ 5).round(0) * 5
        variant_image = variant.images&.first
        supply_variant = self.supply_variants.new(option1: variant.option1, option2: variant.option2, option3: variant.option3, price: variant.price, sku: variant.sku, compare_at_price: compare_at_price)
        if supply_variant.save
          if variant_image
            supply_variant_image = supply_variant.images.new
            supply_variant_image.file_remote_url = Settings.original_url + variant_image.file.url
            supply_variant_image.save
            sleep 0.5
          end
        end
      end
    end
  end
end
