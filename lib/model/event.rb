require_relative 'application_record'

class Event < ApplicationRecord
    has_many :event_specialties
    has_many :specialties, through: :event_specialties
    validates :name, :location, :group, :start_date, :end_date, presence: true
    validates :name, uniqueness: { scope: :location, message: 'Name should be unique per location' }
    validate :end_greater_than_start

    def end_greater_than_start
        errors.add(:end_date, 'End date must be greater than start date.') unless start_date && end_date && end_date > start_date
    end
end
