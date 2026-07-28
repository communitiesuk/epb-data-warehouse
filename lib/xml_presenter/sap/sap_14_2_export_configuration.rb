module XmlPresenter
  module Sap
    class Sap142ExportConfiguration < Sap163Base
      setup additional_bases: %w[SAP05-Data]
    end
  end
end
