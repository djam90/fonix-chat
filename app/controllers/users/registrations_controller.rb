module Users
  class RegistrationsController < Devise::RegistrationsController
    private
      # New accounts must confirm their email first, so send them to the sign in page
      # (with the "check your email" notice) rather than the root, which needs a session.
      def after_inactive_sign_up_path_for(_resource)
        new_user_session_path
      end
  end
end
