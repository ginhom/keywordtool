#coding: utf-8
require 'nokogiri'
require 'open-uri'
require 'json'
require 'date'

class GoogleKeyWordRange
	MAX_ATTEMPTS = 10
	ReadTimeOutRetryCount = 5
	UserAgent = "Mozilla/5.0 (Windows; U; MSIE 7.0; Windows NT 6.0; en-US)"
	PageSize=10
	SearchMaxPage=10
	KEYS=["AIzaSyAZo9kusP7VoL09o7Lg9gyr7-tG1HERcxg","AIzaSyDwhg1aZS3BmaH0xHrUJdxb1bJ4pIAm8RM"]
	CXS=["008527612785483940020:wm71hfpfklg","012286710452622445991:amdykezd3ka"]

	SearchEngineUrl="https://www.googleapis.com/customsearch/v1?lt=json"

	def initialize(site)
		@site=site
	end  

	def search
		site_result=@site.site_results.find(:first,  \
			:conditions =>["created_at>:today and search_engine=:search_engine", \
			{:search_engine=>SearchEngine::GOOGLE,:today=>Date.today}])
		if site_result.nil?
			site_result||=SiteResult.new
			site_result.site=@site
			site_result.search_engine=SearchEngine::GOOGLE
			site_result.save
		else
			puts "today has searched:#{@site.name}-#{SearchEngine::GOOGLE}"
		end
		@site.keywords.split.each do |keyword|
			result=site_result.search_results.find(:first,:conditions=>{:keyword=>keyword})
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
		current_key_index=0
		for page in 0..SearchMaxPage  
			current_key=KEYS[current_key_index]
			current_cx=CXS[current_key_index]
			url = "#{SearchEngineUrl}&key=#{current_key}&cx=#{current_cx}&num=#{PageSize}&a&q=#{result.keyword}&start=#{(page * PageSize+1)}";
			puts url
			attempts=0
			begin
				doc=open(URI.encode(url)).read	
			rescue OpenURI::HTTPError => the_error		
				the_status = the_error.io.status[0]
				puts "error:#{the_error.message}"		
				if current_key_index<KEYS.length
					current_key_index+=1
				else
					break
				end		
			rescue 					
				attempts=attempts+1
				puts "attempts:"+attempts.to_s
				retry if(attempts<MAX_ATTEMPTS)
			end

			if doc.nil? 
				next
			end
			#puts doc
			json = JSON.parse(doc)
			#puts json
			
			#puts json["items"].size
			rank=0
			json["items"].each_with_index do |item,index|
				puts "#{index+1},#{item["link"]}"
				if item["link"].include? @site.name
					rank=index+1
					break
				end
			end
			if rank>0
				result.rank=page * PageSize+rank
				puts "#{result.keyword}=>#{result.rank}"
				break
			end
		end	
		result.save
	end
end