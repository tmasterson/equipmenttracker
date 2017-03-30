require_relative 'application_record'

class Item < ApplicationRecord
  has_many :subitems, class_name: 'Item', foreign_key: 'subitem_id'
  belongs_to :subitem, class_name: 'Item'
  belongs_to :specialty
  validates :item_no, presence: true
  validates :serial, presence: true, length: { minimum: 4, maximum: 10 }, uniqueness: true
  validates :item_type, presence: true
end
