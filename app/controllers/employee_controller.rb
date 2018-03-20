class EmployeeController < ApplicationController
	def new
	end

	def addEmployee
		spreadsheet = getSpreadsheet
		date = Date.today
		month = date.strftime("%B")
		year = date.strftime("%Y")
		worksheetName = month.downcase + "-" + year
		worksheet = spreadsheet.worksheet_by_title(worksheetName)
		dataToInsert = [ params[:remuneration], params[:name] ]
		worksheet.insert_rows( worksheet.num_rows + 1, [dataToInsert])
		worksheet.save
		Rails.cache.delete Date.today.strftime("%d-%m-%Y")
		respond_to do |format|
			format.json {render json: {"status-message" => "success"}}
		end
	end

	def updateEmployee
		spreadsheet = getSpreadsheet
		date = Date.today
		month = date.strftime("%B")
		year = date.strftime("%Y")
		worksheetName = month.downcase + "-" + year
		worksheet = spreadsheet.worksheet_by_title(worksheetName)
		worksheet[ params[:row_number].to_i, 1 ] = params[:remuneration]
		worksheet[ params[:row_number].to_i, 2 ] = params[:name]
		worksheet.save
		Rails.cache.delete Date.today.strftime("%d-%m-%Y")
		respond_to do |format|
			format.json {render json: {"status-message" => "success"}}
		end
	end

	def getEmployee
		spreadsheet = getSpreadsheet
		date = Date.today
		month = date.strftime("%B")
		year = date.strftime("%Y")
		worksheetName = month.downcase + "-" + year
		worksheet = spreadsheet.worksheet_by_title(worksheetName)
		@rowData = worksheet.rows[params[:row_number].to_i - 1]
		@rowNumber = params[:row_number]
	end
end
