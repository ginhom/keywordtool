class SiteResult < ActiveRecord::Base
	belongs_to :site
	has_many:search_results
	attr_accessible :search_engine
end
