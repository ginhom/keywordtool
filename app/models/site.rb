class Site < ActiveRecord::Base
  include SearchEngine
  has_many:site_results
  attr_accessible :keywords, :name

  def search_rank(*search_engines)
  	search_engines.each do |search_engine|
	  	case search_engine
	  		when SearchEngine::GOOGLE
				GoogleKeyWordRange.new(self).search		    				
	  		when SearchEngine::BAIDU
	  			BaiDuKeyWordRange.new(self).search 					  			  				  		
	  	end
	end
  end

end
