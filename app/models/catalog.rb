class Catalog < ApplicationRecord
  attr_accessor :select_type

  acts_as_nested_set #order_column: :name

  has_many :products, dependent: :destroy
  accepts_nested_attributes_for :products #, reject_if: :all_blank

  before_validation :normalize_numbers, on: :create

  # before_save :check_siblings
  before_save :clear_cache

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
    self.element_type = Kernel.Integer(select_type)
  end

  # def check_siblings
  #   return unless siblings.count.positive?

  #   #flash[:notice] = 'В одном разделе каталога допускаются только уникальные названия!'
  #   flash[:notice] = self.errors.full_messages.to_sentence
  #   raise ActiveRecord::Rollback
  # end
end
