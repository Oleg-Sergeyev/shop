class Product < ApplicationRecord
  before_save :convert_price_string
  attr_accessor :price_string

  validates :name, presence: true
  validates :element_type, presence: true
  validates :article, length: { maximum: 150, minimum: 2 }
  validates :name, length: { maximum: 800, minimum: 5 }
  validates :price, presence: true, numericality: { only_float: true }

  belongs_to :catalog, touch: true

  enum type: {
    product: 0,
    service: 10
  }

  def convert_price_string
    return unless price_string

    begin
      self.price = Kernel.Float(price_string)
    rescue ArgumentError, TypeError
      errors.add(ActiveRecord::Errors.default_error_messages[:not_a_number])
    end
  end
end
