class AddSearchEnginesToSites < ActiveRecord::Migration
  def change
  	add_column:sites,:search_engines,:string
  end
end
