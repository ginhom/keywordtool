class WelcomeController < ApplicationController
  def index
  	if current_user
  		@sites=Site.joins(:user).where(:user_id=>current_user).order("created_at DESC")
  	else
  		@sites=Site.where(:user_id=>nil).order("created_at DESC")
  	end
  end 


  def group_by_site_name_hash(sites)
    Hash[sites.map { |e| [e.name,e] }]
  end
end
