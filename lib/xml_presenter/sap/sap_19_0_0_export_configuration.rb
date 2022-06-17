module XmlPresenter
  module Sap
    class Sap1900ExportConfiguration < Sap1900Base
      setup additional_bases: %w[SAP10-Data]
    end
  end
end
