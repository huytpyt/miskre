class Product < ApplicationRecord
  include ShopifyApp::SessionStorage

  # after_create :shopify_create
  # after_update :shopify_update
  # after_destroy :shopify_destroy

  has_many :images, dependent: :destroy
  has_many :supplies
  has_many :shops, through: :supplies
  has_many :options
  has_many :variants

  validates :name, presence: true

  def shopify_create
    new_product = ShopifyAPI::Product.new
    new_product.title = self.name
    new_product.save
    self.update(shopify_id: new_product.id)
  end

  def shopify_update
    product = ShopifyAPI::Product.find(self.shopify_id)
    product.title = self.name
    product.save
  end

  def shopify_destroy
    product = ShopifyAPI::Product.find(self.shopify_id)
    product.destroy
  end

  def regen_variants
    self.variants.clear
    case self.options.count
    when 1
      option1 = self.options.first
      option1.values.each do |v|
        self.variants.create(option1: v)
      end
    when 2
      option1, option2 = self.options[0..1]
      option1.values.each do |v1|
        option2.values.each do |v2|
          self.variants.create(option1: v1, option2: v2)
        end
      end
    when 3
      option1, option2, option3 = self.options[0..2]
      option1.values.each do |v1|
        option2.values.each do |v2|
          option3.values.each do |v3|
            self.variants.create(option1: v1, option2: v2, option3: v3)
          end
        end
      end
    end
  end
end
