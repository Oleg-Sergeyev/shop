class Product < ApplicationRecord
  #before_save :convert_price
  #attr_accessor :price_field

  before_save :clear_cache

  validates :name, presence: true
  validates :article, length: { maximum: 150, minimum: 2 }
  validates :name, length: { maximum: 800, minimum: 5 }
  validates :price, numericality: { only_float: true }

  belongs_to :catalog, touch: true

  def clear_cache
    Rails.cache.clear
  end
  # def convert_price
  #   return unless price_field

  #   begin
  #     self.price = price_field.to_float #Kernel.Float(price_field)
  #   rescue ArgumentError, TypeError
  #     errors.add(ActiveRecord::Errors.default_error_messages[:not_a_number])
  #   end
  # end
end
