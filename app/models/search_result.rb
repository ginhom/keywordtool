class SearchResult < ActiveRecord::Base
  belongs_to :site_result
  attr_accessible :keyword, :rank
end
