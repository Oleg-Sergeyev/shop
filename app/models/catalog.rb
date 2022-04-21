class Catalog < ApplicationRecord
  attr_accessor :select_type

  acts_as_nested_set #order_column: :name  before_add: :do_before_add_stuff 

  has_many :products, dependent: :delete_all #dependent: :destroy
  accepts_nested_attributes_for :products #, reject_if: :all_blank

  before_validation :normalize_numbers, on: :create

  # before_save :check_siblings
  after_commit :clear_cache #check_name_on_level

  validates :name, presence: true
  validates :element_type, presence: true
  validates :name, length: { maximum: 500, minimum: 2 }

  enum element_type: {
    product: 0,
    service: 10
  }

  private

  def clear_cache
    Rails.cache.clear
  end

  def normalize_numbers
    self.element_type = Integer(select_type)
  end

  scope :scope_sort, ->(sort) { includes(:products).where(depth: 0).order(name: sort).order(:lft) }
end
