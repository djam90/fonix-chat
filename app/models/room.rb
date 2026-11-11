# The brief asks for a single room, but modelling it as a record means more rooms can be
# added later without reworking messages.
class Room < ApplicationRecord
  GENERAL = "general".freeze

  has_many :messages, dependent: :destroy

  normalizes :name, with: ->(name) { name.strip }

  validates :name, presence: true, length: { maximum: 50 }, uniqueness: { case_sensitive: false }

  scope :alphabetical, -> { order(:name) }

  def self.general
    find_or_create_by!(name: GENERAL)
  end
end
