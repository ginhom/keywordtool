class HomeController < ApplicationController
  def rankbygoogle
  end

  def rankbybaidu
  end

  def searchbygoogle
  	searchhost = params[:host]
  	keywords=params[:keywords].split
  	search=GoogleKeyWordRange.new(searchhost,keywords)
  	ranges=search.search_range
  	respond_to do |format|
  		format.html{render :text=>ranges}
  	end
  end

  def searchbybaidu
  	searchhost = params[:host]
  	keywords=params[:keywords].split
  	search=BaiDuKeyWordRange.new(searchhost,keywords)
  	ranges=search.search_range
  	respond_to do |format|
  		format.html{render :text=>ranges}
  	end
  end
end
