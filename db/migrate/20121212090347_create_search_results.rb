class CreateSearchResults < ActiveRecord::Migration
  def change
    create_table :search_results do |t|
      t.string :keyword
      t.integer :rank
      t.references :site_result

      t.timestamps
    end
    add_index :search_results, :site_result_id
    add_index :search_results, :keyword
  end
end
