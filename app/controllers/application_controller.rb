require 'bundler'
class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception
  helper_method :current_user
  @@spreadsheet = nil

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

  def set_privilege
    admin_emails = ["shridharindia@gmail.com", "shridharhegde.121@gmail.com", "hegde.anand7@gmail.com"]
    privilege_user = PrivilegeUser.find_by(email: current_user.email)
    if admin_emails.include?(current_user.email)
      @privilege = "admin"
    elsif privilege_user
      @privilege = privilege_user.role
    else
      @privilege = nil
    end
  end

  def has_permission?
    #normal user actions
    normal_user_privilege = [
      "EmployeeController::show",
      "EmployeeController::new",
      "EmployeeController::addEmployee",
      "EmployeeController::updateWorkSheet"
    ]
    if @privilege.nil? || (@privilege == "normal" && !normal_user_privilege.include?("#{self.class.to_s}::#{self.action_name}"))
      redirect_to '/401'
    end
  end

  def getSpreadsheet
    Bundler.require
    client_secret = "/home/#{Etc.getlogin}/secrets/client_secret.json"
    # Authenticate a session with your Service Account
    session = GoogleDrive::Session.from_service_account_key(client_secret)
    # Get the spreadsheet by its title
    if @@spreadsheet.nil?
      @@spreadsheet = session.spreadsheet_by_title("CrucibleAttendance")
    end
    @@spreadsheet
  end

end