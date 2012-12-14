class CreateSites < ActiveRecord::Migration
  def change
    create_table :sites do |t|
      t.string :name
      t.text :keywords

      t.timestamps
    end

    add_index :sites,:name,:name=>"by_name"
  end
end
