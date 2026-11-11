module ApplicationCable
  class Connection < ActionCable::Connection::Base
    identified_by :current_user

    def connect
      self.current_user = find_verified_user || reject_unauthorized_connection
    end

    private
      # The websocket handshake carries the same session cookie, so Devise's Warden
      # user is available here.
      def find_verified_user
        user = env["warden"]&.user(:user)
        user if user&.confirmed?
      end
  end
end
