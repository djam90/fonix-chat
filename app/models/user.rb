class User < ApplicationRecord
  # Email format (URI::MailTo::EMAIL_REGEXP), uniqueness and password length (8+) are
  # configured in config/initializers/devise.rb.
  devise :database_authenticatable, :registerable, :recoverable, :rememberable,
    :validatable, :confirmable

  has_many :messages, dependent: :destroy

  scope :confirmed, -> { where.not(confirmed_at: nil) }

  private
    # Send Devise emails (confirmation, password reset) in the background.
    def send_devise_notification(notification, *args)
      devise_mailer.send(notification, self, *args).deliver_later
    end
end
