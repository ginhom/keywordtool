class CreateSiteResults < ActiveRecord::Migration
  def change
    create_table :site_results do |t|
      t.string :search_engine
      t.references :site

      t.timestamps
    end

    add_index :site_results, :site_id
  end
end
