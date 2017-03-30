require_relative 'application_record'

class Specialty < ApplicationRecord
    has_many :event_specialties
    has_many :events, through: :event_specialties
    has_many :items
    validates :name, :chief, presence: true
    validates :name, uniqueness: { scope: :chief, message: 'Name is unique per chief'}
end
