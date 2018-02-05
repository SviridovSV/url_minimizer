class CreateStatistics < ActiveRecord::Migration[5.1]
  def change
    create_table :statistics do |t|
      t.datetime :date
      t.text :gadget
      t.text :browser
      t.references :url, index: true, foreign_key: true

      t.timestamps
    end
  end
end
