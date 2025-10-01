class AddCommercialReportsTable < ActiveRecord::Migration[7.0]
  def self.up
    create_table :commercial_reports, primary_key: :assessment_id, id: :string do |t|
      t.string :related_rrn, index: true, null: false
    end
  end

  def self.down
    drop_table :commercial_reports
  end
end
