require "time"

module Helper
  module DateTime
    def self.convert_atom_to_db_datetime(atom_format_time)
      Time.xmlschema(atom_format_time).strftime("%F %T")
    end
  end
end
