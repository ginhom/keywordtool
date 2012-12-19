class AddLabelToSites < ActiveRecord::Migration
  def change
  	add_column:sites,:label,:string
  end
end
