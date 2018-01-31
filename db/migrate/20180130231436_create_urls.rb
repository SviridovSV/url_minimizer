class CreateUrls < ActiveRecord::Migration[5.1]
  def change
    create_table :urls do |t|
      t.text   :long_url
      t.text  :short_url, index: true
      t.integer  :life_term
      t.integer :delay_time
      t.references :user, index: true, foreign_key: true

      t.timestamps
    end
  end
end
