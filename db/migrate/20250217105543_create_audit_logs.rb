class CreateAuditLogs < ActiveRecord::Migration[7.0]
  def self.up
    create_table :audit_logs, id: false, primary_key: :assessment_id do |t|
      t.string :assessment_id
      t.string :event_type, null: false
      t.datetime :timestamp, null: false, default: Time.now
    end
  end

  def self.down
    drop_table :audit_logs
  end
end
