class CreateDeltas < ActiveRecord::Migration[6.0]
  def change
    create_table :deltas do |t|
      t.timestamps null: false

      t.string :type, null: false
      t.jsonb :arguments, null: false
      t.boolean :applied, null: false, default: false
    end
  end
end
