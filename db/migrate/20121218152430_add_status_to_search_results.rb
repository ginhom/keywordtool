class AddStatusToSearchResults < ActiveRecord::Migration
  def change
  	add_column :search_results,:status,:string
  end
end
