require 'bundler'
require 'date'

class MeController < ApplicationController
	before_action :authenticate, only: [:show]
	before_action :getSpreadsheet, only: [:show, :updateWorkSheet]
	def show
		@employeeNames = []
		date = Date.today
		month = date.strftime("%B")
		year = date.strftime("%Y")
		worksheetName = month.downcase + "-" +year
		attendanceTaken = AttendanceDate.find_by(date: date.strftime("%d-%m-%Y"))
		if attendanceTaken.nil?
			@type = "save"
		else
			@type = "update"
		end
		worksheet = @spreadsheet.worksheet_by_title(worksheetName)
		worksheet.rows.each_with_index do |row, index|
		  #first row contains the date
		  if(index != 0)
		  	json = {}
		  	json["name"] = row[1]
		  	#always the last column is the latest one,
		  	#only the last column can be updated 
		  	if @type == "update"
		  		json["value"] = row[row.length - 1]
		  	end
		    @employeeNames.push(json)
		  end
		end
	end

	def getSpreadsheet
		Bundler.require
		client_secret = "/home/#{Etc.getlogin}/secrets/client_secret.json"
		# Authenticate a session with your Service Account
		session = GoogleDrive::Session.from_service_account_key(client_secret)
		# Get the spreadsheet by its title
		@spreadsheet = session.spreadsheet_by_title("CrucibleAttendance")
	end

	def updateWorkSheet

		attedanceInfo = []		
		params["data"].each do |key, value|
			if(value == "1")
				attedanceInfo.push("P")
			else
				attedanceInfo.push("A")
			end
		end
		date = Date.today
		month = date.strftime("%B")
		year = date.strftime("%Y")
		worksheetName = month.downcase + "-" +year
		previousDate = date - 1.month
		oldWorkSheetName = previousDate.strftime("%B").downcase + "-" + previousDate.strftime("%Y")
		worksheet = @spreadsheet.worksheet_by_title(worksheetName)
		if worksheet.nil?
		  worksheet = spreadsheet.add_worksheet(spreadsheetName)
		  oldWorksheet = spreadsheet.worksheet_by_title(oldSpreadSheetName)
		  oldWorksheet.rows.each_with_index { |row, index| 
		    worksheet.insert_rows( (index+1), [[row[0], row[1]]])
		  }
		  worksheet.save
		end

		if(params[:type] == "save")
			columnNumber = worksheet.rows[0].length + 1
			AttendanceDate.create(date: date.strftime("%d-%m-%Y"), taken: "true")
		else
			columnNumber = worksheet.rows[0].length
		end
		worksheet.rows.each_with_index do |row, index|
			#first row contains the date
			if(index === 0)
				worksheet[(index+1), columnNumber] = date.strftime("%d-%m-%Y")
			else
				worksheet[(index+1), columnNumber] = attedanceInfo[index-1]
			end
		end
		worksheet.save
		# Print out the first 6 columns of each row
		respond_to do |format|
			format.json { render json: params }
		end
	end

end
