#coding: utf-8
class SitesController < ApplicationController
	Page_Size=10
	expose(:site)
	before_filter :set_search_engines,:only=>[:create,:update]
	before_filter :authenticate_user!,:only=>[:destroy]
	
	def create				
		logger.debug site.search_engines
		site.user=current_user
		if site.save
		  redirect_to :action=>"rank",:id=>site
		else
		  render :new
		end
  	end

	def update
		if site.save
		  redirect_to(site)
		else
		  render :edit
		end
	end

	def show
		params[:page]||=1
		@page=params[:page].to_i
		@date=params[:date].nil? ? site.last_rank_date(@page) : params[:date]
		respond_to do |format|
			format.html
			format.xls {   
				send_data(site.xls_by_date(@date),  
				        :type => "text/excel;charset=utf-8; header=present",  
				        :filename => "Report_Rank_#{Time.now.to_date}.xls")  
			}  
		end
	end

	def rank
		site.search_rank
		flash[:waiting_for_ranking]=true
		redirect_to site
	end

	def query
		@q=params[:q]
		if @q.nil? || @q.blank?
			redirect_to root_path
		end
		params[:page]||=1
		@page=params[:page].to_i
		@sites=Site.query_by_name @q
		@dates=SiteResult.all_rank_dates_by_name @q,@page,Page_Size
		total=SiteResult.size_by_name @q

		@has_prev=(@page>1)
		@has_next=(total>(@page*Page_Size))
		if !@dates.nil?
			@date=(params[:date].nil? and !@dates.first.nil?) ? @dates.first.created_day : params[:date]
		end 
	end

	def destroy
		@site=Site.find(params[:id])
		@site.destroy
		redirect_to root_path
	end
private
	def set_search_engines
		site.search_engines=params[:search_engines].nil? ? nil:params[:search_engines].join(',')
	end

end
