class AddConstraintAuditLogs < ActiveRecord::Migration[7.0]
  def self.up
    execute "TRUNCATE TABLE audit_logs"
    execute "ALTER table audit_logs add id bigserial primary key"
    execute "ALTER TABLE audit_logs ADD CONSTRAINT idx_audit_log_rrn_event UNIQUE (assessment_id, event_type);"
  end

  def self.down; end
end
