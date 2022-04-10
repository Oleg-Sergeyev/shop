class Catalog < ApplicationRecord
  attr_accessor :select_type

  acts_as_nested_set

  before_validation :normalize_numbers, on: :create
  # before_save :check_siblings

  validates :name, presence: true
  validates :element_type, presence: true
  validates :name, length: { maximum: 500, minimum: 2 }

  has_many :products, dependent: :destroy

  enum element_type: {
    product: 0,
    service: 10
  }

  private

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
