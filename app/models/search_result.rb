class SearchResult < ActiveRecord::Base
  belongs_to :site_result
  attr_accessible :keyword, :rank,:status
  before_save :default_values

 private
  def default_values
    self.status ||= RankStatus::NEW
  end

end
