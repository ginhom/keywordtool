class SearchResult < ActiveRecord::Base
  belongs_to :site_result
  attr_accessible :keyword, :rank,:status

  after_initialize :init
  
  scope :fails,where(:status=>RankStatus::FAIL).order("created_at asc")

  def search_rank
    case site_result.search_engine
      when SearchEngine::GOOGLE
        GoogleKeyWordRange.search_rank(self)               
      when SearchEngine::BAIDU
        BaiDuKeyWordRange.search_rank(self)                                  
    end    
  end

  def self.rerank_failed_keywords
  	SearchResult.fails.find_each do |result|
  		result.search_rank
  	end
  end

 private

  def init
    self.status ||= RankStatus::NEW
  end

end
