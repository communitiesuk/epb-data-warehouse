module XmlPresenter
  module Sap
    class Sap1800ExportConfiguration < Sap1800Base
      setup additional_bases: %w[SAP2012-Data]
    end
  end
end
