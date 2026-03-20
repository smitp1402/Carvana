class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  # Auto-login demo user in development for easy testing
  if Rails.env.development?
    before_action :auto_login_demo_user

    private

    def auto_login_demo_user
      return if user_signed_in?

      demo_user = User.find_by(email: "demo@carvana.com")
      sign_in(demo_user) if demo_user
    end
  end
end
