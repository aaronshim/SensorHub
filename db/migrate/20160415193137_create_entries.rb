class CreateEntries < ActiveRecord::Migration[5.0]
  def change
    create_table :entries do |t|
      t.integer :data
      t.string :sensor_name

      t.timestamps
    end
  end
end
