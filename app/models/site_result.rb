class SiteResult < ActiveRecord::Base
	belongs_to :site
	has_many:search_results,:dependent => :destroy
	attr_accessible :search_engine

	def get_rank_by_keyword(attr_name)
		search_results.find_by_keyword(attr_name.to_s)
	end

  def self.all_rank_dates_by_name(name,page=1,page_size)
    q = "%#{name}%"
    joins(:site).where("sites.name like ?", q).order("site_results.created_at desc").select("date(site_results.created_at) as created_day").uniq.limit(page_size).offset((page-1)*page_size)
  end

  def self.size_by_name(name)
  	  q = "%#{name}%"
    	  joins(:site).where("sites.name like ?", q).order("site_results.created_at desc").select("distinct date(site_results.created_at)").size
  end
end
