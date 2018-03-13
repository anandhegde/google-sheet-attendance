class HomeController < ApplicationController
	def show
		puts Rails.application.config.cache_store
	end
end
