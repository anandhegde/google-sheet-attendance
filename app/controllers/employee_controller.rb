class EmployeeController < ApplicationController
	def new
	end

	def addEmployee
		getSpreadsheet
		date = Date.today
		month = date.strftime("%B")
		year = date.strftime("%Y")
		worksheetName = month.downcase + "-" + year
		worksheet = @spreadsheet.worksheet_by_title(worksheetName)
		dataToInsert = [ params[:remuneration], params[:name] ]
		worksheet.insert_rows( worksheet.num_rows + 1, [dataToInsert])
		worksheet.save
		Rails.cache.delete Date.today.strftime("%d-%m-%Y")
		respond_to do |format|
			format.json {render json: {"status-message" => "success"}}
		end
	end
end
