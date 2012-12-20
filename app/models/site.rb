#coding: utf-8
class Site < ActiveRecord::Base
  Page_Size=10
  validates_presence_of :name,:keywords
  validates_length_of :label,:maximum=>15

  has_many:site_results,:dependent => :destroy
  attr_accessible :keywords, :name,:label,:search_engines

  def search_rank
    if search_engines.nil? || search_engines.blank? 
      return
    end
    search_engines.split(',').each do |search_engine|
      #puts "#{search_engine}-------------------------"

      next if search_engine.blank?

      SiteResult.transaction do
        site_result=site_results.find(:first,  \
        :conditions =>["date(created_at)=:today and search_engine=:search_engine", \
        {:search_engine=>search_engine,:today=>Date.today}])
        #puts site_result
        if site_result.nil?   
          #puts  "new==============================="
          site_result=SiteResult.new
          site_result.site=self
          site_result.search_engine=search_engine
          site_result.save
        else
          logger.info "today has searched:#{name}-#{search_engine}"
        end

        keywords.split.each do |keyword|
          result=site_result.search_results.find_by_keyword(keyword)
          if result.nil?
            #puts  "new==============================="
            result=SearchResult.new
            result.site_result=site_result
            result.keyword=keyword
            result.save
            result.search_rank        
          else
            logger.info "today has searched:#{keyword}"
          end
        end

      end
    end
  end

  def all_rank_dates(page=1)
     site_results
        .select("date(created_at) as created_day")
        .order("date(created_at) desc") 
        .uniq.limit(Page_Size).offset((page-1)*Page_Size)
  end

  def has_prev(page=1)
    page>1
  end

  def has_next(page=1)
    total_rank_dates > page*Page_Size
  end

  def last_rank_date(page=1)
      result=site_results
        .select("date(created_at) as created_day")
        .order("date(created_at) desc")
        .uniq
        .offset((page-1)*Page_Size)
        .first
      return result.nil? ? nil: result.created_day 
  end

  def get_rank_result_by_engine_and_day(search_engine,date)
      site_results
      .includes(:search_results)
      .find(:first,:conditions=>["date(site_results.created_at)=? and search_engine=?",date,search_engine])
  end

  def self.query_by_name(name)
    q = "%#{name}%"
    where("name like ?", q).order("name asc")
  end 

  def total_rank_dates
    site_results.order("created_at desc") 
        .select("distinct date(created_at)").size
  end

end
