class DropAssessmentsAddressIdTable < ActiveRecord::Migration[7.0]
  def self.up
    drop_table :assessments_address_id
  end

  def self.down
    create_table :assessments_address_id, primary_key: :assessment_id, id: :string do |t|
      t.string :address_id
      t.bigint :matched_uprn
    end

    add_index :assessments_address_id, :address_id
  end
end
