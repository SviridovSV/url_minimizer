class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception
  before_action :require_login

  def index
  end

  private
  def not_authenticated
    redirect_to login_path, alert: "Please login first"
  end
end
