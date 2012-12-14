#coding: utf-8

class HomeController < ApplicationController

  def searchresult
     @site=Site.find(params[:id])
  end 

  def search_again
     site=Site.find(params[:id])
     search_engines=params[:search_engines] 
     site.search_rank(*search_engines)
     respond_to do |format|
      format.html{render :text=>'processing...'}
    end
  end

  def search
  end

  def searchby
    searchhost = params[:host]
    keywords=params[:keywords]
    search_engines=params[:search_engines] 
    if !search_engines.nil? 
      site=Site.find_by_name(searchhost)
      if site.nil?
        site=Site.new
        site.name=searchhost
        site.keywords=keywords
        site.save
      end
      site.search_rank(*search_engines)
    end
    respond_to do |format|
      format.html{  redirect_to :action => "index",:controller =>'welcome'}
    end
  end

end
