class WelcomeController < ApplicationController
  def index
  	@sites=Site.order("created_at DESC")
  end 
end
