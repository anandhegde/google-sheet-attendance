require 'bundler'
class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception
  helper_method :current_user

  def authenticate
  	redirect_to :login unless user_signed_in?
  end

  def current_user
  	@current_user ||= User.find(session[:user_id]) if session[:user_id]
  end

  def user_signed_in?
  	# converts current_user to a boolean by negating the negation
  	!!current_user
  end

  def getSpreadsheet
    Bundler.require
    client_secret = "/home/#{Etc.getlogin}/secrets/client_secret.json"
    # Authenticate a session with your Service Account
    session = GoogleDrive::Session.from_service_account_key(client_secret)
    # Get the spreadsheet by its title
    @spreadsheet = session.spreadsheet_by_title("CrucibleAttendance")
  end

end