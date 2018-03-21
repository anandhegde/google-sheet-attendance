class AdminController < ApplicationController
	before_action	:authenticate
	before_action 	:set_privilege
	before_action 	:has_permission?
	
	def add_privilege_users
		emails = params[:emails].split(",")
		PrivilegeUser.delete_all
		emails.each do |email|
			p = PrivilegeUser.new(email: email, role: "normal")
			p.save!
		end
		respond_to do |format|
			format.json {render json: {"status-message" => "success"}}
		end
	end

	def new_privilege_users
		@emails = []
		PrivilegeUser.all.each do |user|
			@emails.push user.email
		end
		@emails = @emails.join(",")
	end
end
