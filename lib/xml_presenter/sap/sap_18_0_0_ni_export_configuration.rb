module XmlPresenter
  module Sap
    class Sap1800NiExportConfiguration < Sap1800Base
      setup additional_bases: %w[SAP09-Data]
    end
  end
end
