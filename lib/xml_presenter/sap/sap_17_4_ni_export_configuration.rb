module XmlPresenter
  module Sap
    class Sap174NiExportConfiguration < Sap171Base
      setup additional_bases: %w[SAP09-Data]
    end
  end
end
