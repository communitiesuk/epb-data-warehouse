module XmlPresenter
  module Rdsap
    class Rdsap20ExportConfiguration < XmlPresenter::ToWarehouse::BaseConfiguration
      excludes %w[
        ExternalDefinitions-Revision-Number
        User-Interface-Name
        User-Interface-Version
        PCDF-Revision-Number
        Related-Party-Disclosure
        Insurance-Details
        Previous-EPC-Check
        Green-Deal-Package
        Energy-Assessor
        Green-Deal-Category
        RRN
      ]
      includes %w[
        Certificate-Number
      ]
      bases %w[
        Report-Header
        Energy-Assessment
        Property-Summary
        Energy-Use
        SAP-Data
        SAP-Property-Details
        Identification-Number
        Property
        Address
      ]
      preferred_keys({
        "Certificate-Number" => "scheme_assessor_id",
      })
      list_nodes %w[
        SAP-Floor-Dimensions
        LZC-Energy-Source
        ImprovementTexts
        SAP-Building-Parts
        SAP-Windows
        SAP-Deselected-Improvements
        Main-Heating-Details
        Storage-Heaters
        SAP-Special-Features
        Air-Change-Rates
        PV-Arrays
      ]
      rootless_list_nodes({
        "Wall" => "walls",
        "Roof" => "roofs",
        "Floor" => { parents: %w[Property-Summary], key: "floors" },
        "Main-Heating" => { parents: %w[Property-Summary], key: "main-heating" },
        "Main-Heating-Controls" => "main_heating_controls",
        "Addendum-Number" => "addendum_numbers",
      })
    end
  end
end
