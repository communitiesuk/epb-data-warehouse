class CreateAssessmentSearch < ActiveRecord::Migration[7.0]
  def self.up
    create_table :assessment_search, id: false, primary_key: :assessment_id do |t|
      t.string    :assessment_id, null: false
      t.string    :address_line_1
      t.string    :address_line_2
      t.string    :address_line_3
      t.string    :address_line_4
      t.string    :post_town, limit: 100
      t.string    :postcode, limit: 10, index: true
      t.integer   :current_energy_efficiency_rating, index: true
      t.string    :current_energy_efficiency_band, limit: 1
      t.string    :council, limit: 40, index: true
      t.string    :constituency, limit: 45, index: true
      t.string    :assessment_address_id, limit: 30, index: true
      t.string    :address, limit: 500
      t.timestamp :registration_date, index: true
      t.string    :assessment_type, limit: 8, index: true
      t.timestamp :created_at, index: true
    end

    execute "ALTER TABLE assessment_search ADD PRIMARY KEY (assessment_id)"

    execute <<-SQL
      CREATE INDEX IF NOT EXISTS index_assessment_search_on_address_trigram
      ON assessment_search
      USING gin (address gin_trgm_ops)
    SQL
  end

  def self.down
    drop_table :assessment_search
  end
end
