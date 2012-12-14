#coding: utf-8
require 'nokogiri'
require 'open-uri'

class BaiDuKeyWordRange
	ReadTimeOutRetryCount = 5
	UserAgent = "Mozilla/5.0 (Windows NT 6.1; WOW64) AppleWebKit/537.11 (KHTML, like Gecko) Chrome/23.0.1271.91 Safari/537.11"
	PageSize=10
	SearchMaxPage=10
	SearchEngineUrl="http://www.baidu.com/s?wd="

	def initialize(site)
		@site=site
	end 

	def search		
		site_result=@site.site_results.find(:first,  \
			:conditions =>["created_at>:today and search_engine=:search_engine", \
			{:search_engine=>SearchEngine::BAIDU,:today=>Date.today}])
		if site_result.nil?		
			site_result=SiteResult.new
			site_result.site=@site
			site_result.search_engine=SearchEngine::BAIDU
			site_result.save
		else
			puts "today has searched:#{@site.name}-#{SearchEngine::BAIDU}"
		end
		@site.keywords.split.each do |keyword|
			result=site_result.search_results.find_by_keyword(keyword)
			if result.nil?
				result=SearchResult.new
				result.site_result=site_result
				result.keyword=keyword
				result.save
				delay.search_rank(result)
			else
				puts "today has searched:#{keyword}"
			end
		end			
	end

private
	def search_rank(result)
		url = SearchEngineUrl + result.keyword
		for page in 0..PageSize  
			tmpUrl = url + "&pn=" + (page * PageSize).to_s;
			puts tmpUrl
			attempts=0
			begin
				doc=Nokogiri::HTML(open(URI.encode(tmpUrl),"User-Agent" =>UserAgent))
			rescue 					
				attempts=attempts+1
				puts "attempts:"+attempts.to_s
				retry if(attempts<MAX_ATTEMPTS)
			end
			
			if doc.nil? 
				next
			end

			table=doc.css("table:contains('#{@site.name}')")
			if table.size>0
				span=table.css("span.g:contains('#{@site.name}')")	
				if span.size>0
					rank = table.first['id']	
					result.rank=rank	.to_i								
				end				
			end
		end
		result.save
	end
end