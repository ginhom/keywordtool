class AddUserRefToSites < ActiveRecord::Migration
  def change
  	change_table :sites do |t|
    		t.references :user
    	end
  end
end
