#coding: utf-8
require 'nokogiri'
require 'open-uri'

class GoogleKeyWordRange
	MAX_ATTEMPTS = 10
	ReadTimeOutRetryCount = 5
	UserAgent = "Mozilla/5.0 (Windows NT 6.1; WOW64) AppleWebKit/537.11 (KHTML, like Gecko) Chrome/23.0.1271.91 Safari/537.11"
	PageSize=10
	SearchMaxPage=10
	SearchEngine="http://www.google.com.hk/search?q="

	def initialize(host,keywords)
		@host=host
		@keywords=keywords
	end 

	def search_range()
		ranges=Hash.new
		@keywords.each do |keyword|
			url = SearchEngine + keyword
			for page in 0..PageSize  
				tmpUrl = url + "&start=" + (page * PageSize).to_s;
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

				#puts doc
				lis= doc.css("li.g")
				#puts "lis size:"+lis.size.to_s
				range=0
				index=0
				lis.each do |li|
					index=index+1
					cite=li.css("cite:contains('#{@host}')")	
					if cite.size>0 then
						#onmousedown = li.css("h3.r a").first['onmousedown']	
						#puts onmousedown
						#range = onmousedown.split(",")[4].replace('')
						range=index
						#puts li
						break								
					end	
				end
				if range>0
					ranges[keyword]=page * PageSize+range
					puts keyword+"=>"+ranges[keyword].to_s
					break
				end
			end
		end	
		return ranges	
	end
end