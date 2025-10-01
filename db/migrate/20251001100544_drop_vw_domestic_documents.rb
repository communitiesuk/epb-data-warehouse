class DropVwDomesticDocuments < ActiveRecord::Migration[7.0]
  def self.sql(year)
    <<~SQL
      DROP VIEW IF EXISTS vw_domestic_documents_#{year}
    SQL
  end

  def self.up
    years = (2012..2025).to_a
    years.each do |year|
      sql = sql(year)
      execute(sql)
    end
  end
end
