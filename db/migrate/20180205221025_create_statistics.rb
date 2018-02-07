class CreateStatistics < ActiveRecord::Migration[5.1]
  def change
    create_table :statistics do |t|
      t.datetime :stat_date
      t.text :gadget
      t.text :browser
      t.references :url, index: true, foreign_key: true
    end
  end
end
