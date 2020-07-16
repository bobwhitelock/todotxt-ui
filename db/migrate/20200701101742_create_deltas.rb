class CreateDeltas < ActiveRecord::Migration[6.0]
  def change
    create_table :deltas do |t|
      t.timestamps null: false

      t.string :type, null: false
      t.string :status, null: false, default: 'unapplied'
      t.jsonb :arguments, null: false
    end
  end
end
