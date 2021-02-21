class CreatePendingNotifications < ActiveRecord::Migration[6.0]
  def change
    create_table :pending_notifications do |t|
      t.references :member, foreign_key: true, null: false
      t.text :kind, null: false
      t.integer :loan_ids, array: true, default: [], null: false
      t.integer :hold_ids, array: true, default: [], null: false
      t.integer :renewal_request_ids, array: true, default: [], null: false
      t.timestamps

      t.index [:member_id, :kind], unique: true
    end
  end
end
