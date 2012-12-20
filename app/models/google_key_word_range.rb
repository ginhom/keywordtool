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

	class << self
		def search_rank(result)
			name=result.site_result.site.name
			Rails.logger.info name
			current_key_index=0
			for page in 0..SearchMaxPage  
				current_key=KEYS[current_key_index]
				current_cx=CXS[current_key_index]
				url = "#{SearchEngineUrl}&key=#{current_key}&cx=#{current_cx}&num=#{PageSize}&a&q=#{result.keyword}&start=#{(page * PageSize+1)}";
				Rails.logger.info url
				attempts=0
				begin
					doc=open(URI.encode(url)).read	
				rescue OpenURI::HTTPError => the_error		
					the_status = the_error.io.status[0]
					Rails.logger.error "error:#{the_error.message}"		
					if current_key_index<KEYS.length
						current_key_index+=1
					else
						result.status=RankStatus::FAIL
						break
					end		
				rescue 					
					attempts=attempts+1
					Rails.logger.info "attempts:"+attempts.to_s
					retry if(attempts<MAX_ATTEMPTS)
				end

				if doc.nil? 
					result.status=RankStatus::FAIL
					next
				end
				#Rails.logger.info doc
				json = JSON.parse(doc)
				#Rails.logger.info json
				
				#Rails.logger.info json["items"].size
				rank=0
				json["items"].each_with_index do |item,index|
					Rails.logger.info "#{index+1},#{item["link"]}"
					if item["link"].include? name
						rank=index+1
						break
					end
				end
				if rank>0
					result.rank=page * PageSize+rank
					result.status=RankStatus::SUCCESS
					Rails.logger.info "#{result.keyword}=>#{result.rank}"
					break
				end
			end	
			result.status=RankStatus::SUCCESS if result.status==RankStatus::NEW
			result.save		
		end

		handle_asynchronously :search_rank
	end
end