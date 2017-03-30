require_relative 'application_record'

class EventSpecialty < ApplicationRecord
  belongs_to :event
  belongs_to :specialty
  validates :specialty_id, :event_id, presence: true
end
