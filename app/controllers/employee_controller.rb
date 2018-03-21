class EmployeeController < ApplicationController
	before_action :authenticate
	before_action :set_privilege
	before_action :has_permission?, except: [:getWorksheetName]

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
			spreadsheet = getSpreadsheet
			worksheet = spreadsheet.worksheet_by_title(worksheetName)
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
			Rails.cache.write(date.strftime("%d-%m-%Y"), @employeeNames, :timeToLive => 600.seconds)
		end
	end

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

	def updateWorkSheet
		#get the spreadsheet instance
		spreadsheet = getSpreadsheet

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
		Rails.cache.write(date.strftime("%d-%m-%Y"), cacheInfo, :timeToLive => 600.seconds)
		worksheet = spreadsheet.worksheet_by_title(worksheetName)
		
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
		spreadsheet = getSpreadsheet
		worksheet = spreadsheet.worksheet_by_title(getWorksheetName)
		worksheet.delete_rows(params[:rowNumber].to_i, 1)
		worksheet.save
		Rails.cache.delete Date.today.strftime("%d-%m-%Y")

		respond_to do |format|
			format.json { render json: {status: "done"} }
		end
	end
end
