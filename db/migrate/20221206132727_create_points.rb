class CreatePoints < ActiveRecord::Migration[7.0]
  def change
    create_table :points do |t|
      t.float :x
      t.float :y
      t.integer :n
      t.string :d_type

      t.timestamps
    end
  end
end
