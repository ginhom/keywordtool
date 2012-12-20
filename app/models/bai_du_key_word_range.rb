#coding: utf-8
require 'nokogiri'
require 'open-uri'

class BaiDuKeyWordRange
	ReadTimeOutRetryCount = 5
	UserAgent = "Mozilla/5.0 (Windows NT 6.1; WOW64) AppleWebKit/537.11 (KHTML, like Gecko) Chrome/23.0.1271.91 Safari/537.11"
	PageSize=10
	SearchMaxPage=10
	SearchEngineUrl="http://www.baidu.com/s?wd="

	class << self
		def search_rank(result)
			name=result.site_result.site.name
			Rails.logger.info name
			url = SearchEngineUrl + result.keyword
			for page in 0..PageSize  
				tmpUrl = url + "&pn=" + (page * PageSize).to_s;
				Rails.logger.info tmpUrl
				attempts=0
				begin
					doc=Nokogiri::HTML(open(URI.encode(tmpUrl),"User-Agent" =>UserAgent))
				rescue 					
					attempts=attempts+1
					Rails.logger.warn "attempts:"+attempts.to_s
					retry if(attempts<MAX_ATTEMPTS)
				end
				
				if doc.nil? 
					result.status=RankStatus::FAIL
					next
				end

				table=doc.css("table:contains('#{name}')")
				if table.size>0
					span=table.css("span.g:contains('#{name}')")	
					if span.size>0
						rank = table.first['id']	
						result.rank=rank	.to_i	
						result.status=RankStatus::SUCCESS	
						Rails.logger.info "#{result.keyword}=>#{result.rank}"	
						break					
					end				
				end
			end
			result.status=RankStatus::SUCCESS if result.status==RankStatus::NEW
			result.save
		end
		handle_asynchronously :search_rank
	end
end