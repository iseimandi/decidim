module Devise
  module Models
    module Recoverable

      def send_bootstrap_invitation
        token = set_reset_password_token
        send_bootstrap_invitation_instructions_notification(token)

        token
      end

      protected

      def send_bootstrap_invitation_instructions_notification(token)
        InitialUserMailer.invitation_email(self, token).deliver_now
      end

    end
  end
end