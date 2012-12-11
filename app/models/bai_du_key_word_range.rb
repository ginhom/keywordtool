#coding: utf-8
require 'nokogiri'
require 'open-uri'

class BaiDuKeyWordRange
	ReadTimeOutRetryCount = 5
	UserAgent = "Mozilla/5.0 (Windows NT 6.1; WOW64) AppleWebKit/537.11 (KHTML, like Gecko) Chrome/23.0.1271.91 Safari/537.11"
	PageSize=10
	SearchMaxPage=10
	SearchEngine="http://www.baidu.com/s?wd="

	def initialize(host,keywords)
		@host=host
		@keywords=keywords
	end 

	def search_range()
		ranges=Hash.new
		@keywords.each do |keyword|
			url = SearchEngine + keyword
			for page in 0..PageSize  
				tmpUrl = url + "&pn=" + (page * PageSize).to_s;
				puts tmpUrl
				begin
					doc=Nokogiri::HTML(open(URI.encode(tmpUrl)))
				rescue 					
					attempts=attempts+1
					puts "attempts:"+attempts.to_s
					retry if(attempts<MAX_ATTEMPTS)
				end
				
				if doc.nil? 
					next
				end

				table=doc.css("table:contains('#{@host}')")
				if table.size>0
					span=table.css("span.g:contains('#{@host}')")	
					if span.size>0
						range = table.first['id']	
						ranges[keyword]=range									
					end				
				end
			end
		end	
		return ranges	
	end
end