class Message < ApplicationRecord
  MAX_LENGTH = 1_000

  belongs_to :room
  belongs_to :user

  normalizes :body, with: ->(body) { body.strip }

  validates :body, presence: true, length: { maximum: MAX_LENGTH }

  scope :chronological, -> { order(:created_at, :id) }
  scope :not_from, ->(user) { where.not(user: user) }

  after_create_commit :broadcast

  def self.recent(limit = 100)
    chronological.reverse_order.limit(limit).includes(:user).reverse
  end

  private
    def broadcast
      ChatChannel.broadcast_to room, {
        id: id,
        html: ApplicationController.render(partial: "messages/message", locals: { message: self })
      }
    end
end
