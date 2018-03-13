require 'bundler'
require 'date'

class MeController < ApplicationController
	#before_action :authenticate, only: [:show]
	def show
		date = Date.today
		month = date.strftime("%B")
		year = date.strftime("%Y")
		#getting worksheet name
		worksheetName = month.downcase + "-" +year
		#get the cache
		@employeeNames = Rails.cache.read date.strftime("%d-%m-%Y")
		#check if already attendance taken or not
		attendanceTaken = AttendanceDate.find_by(date: date.strftime("%d-%m-%Y"))
		if attendanceTaken.nil?
			@type = "save"
		else
			@type = "update"
		end

		#if cache is empty, get it from spreadsheet
		if @employeeNames.nil?
			@employeeNames = []
			getSpreadsheet
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
					else
						json["value"] = " "
					end
					@employeeNames.push(json)
				end
			end
			#set the cache for faster access
			Rails.cache.write date.strftime("%d-%m-%Y"), @employeeNames
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
		#get the spreadsheet instance
		getSpreadsheet

		date = Date.today
		month = date.strftime("%B")
		year = date.strftime("%Y")
		worksheetName = month.downcase + "-" +year
		previousDate = date - 1.month
		oldWorkSheetName = previousDate.strftime("%B").downcase + "-" + previousDate.strftime("%Y")
		attedanceInfo = [] #data to update the spreadsheet
		cacheInfo = [] # data to update the cache
		params["data"].each do |key, value|
			json = {}
			if(value == "1")
				json["name"] = key
				json["value"] = "P"
				attedanceInfo.push("P")
			else
				json["name"] = key
				json["value"] = " "
				attedanceInfo.push(" ")
			end
			cacheInfo.push json
		end
		

		Rails.cache.delete date.strftime("%d-%m-%Y")
		Rails.cache.write(date.strftime("%d-%m-%Y"), cacheInfo, :timeToLive => 86400.seconds)
		worksheet = @spreadsheet.worksheet_by_title(worksheetName)
		
		columnNumber = worksheet.num_cols
		if(params[:type] == "save")
			columnNumber = columnNumber + 1
			AttendanceDate.create(date: date.strftime("%d-%m-%Y"), taken: "true")
		end
		worksheet.rows.each_with_index do |row, index|
			#first cell of column contains the date
			if(index === 0)
				worksheet[(index+1), columnNumber] = date.strftime("%d-%m-%Y")
			else
				worksheet[(index+1), columnNumber] = attedanceInfo[index-1]
			end
		end
		worksheet.save

		respond_to do |format|
			format.json { render json: params }
		end
	end

	def getWorksheetName
		date = Date.today
		month = date.strftime("%B")
		year = date.strftime("%Y")
		#getting worksheet name
		worksheetName = month.downcase + "-" +year
		return worksheetName
	end

	def deleteEmployee
		getSpreadsheet
		worksheet = @spreadsheet.worksheet_by_title(getWorksheetName)
		worksheet.delete_rows(params[:rowNumber].to_i, 1)
		worksheet.save
		Rails.cache.delete Date.today.strftime("%d-%m-%Y")

		respond_to do |format|
			format.json { render json: {status: "done"} }
		end
	end

end
