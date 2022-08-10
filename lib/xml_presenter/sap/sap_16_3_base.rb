module XmlPresenter
  module Sap
    class Sap163Base < XmlPresenter::ToWarehouse::BaseConfiguration
      def self.setup(additional_bases: [])
        # excludes is a list of all sections and nodes you do not wish to include.
        excludes %w[
          Identification
          Configuration
          ExternalDefinitions-Revision-Number
          PCDF-Revision-Number
          Related-Party-Disclosure
          Insurance-Details
          Green-Deal-Package
          Home-Inspector
          Green-Deal-Category
          RRN
          PDF
        ]
        # includes is a list of nodes you wish to include which might be located inside an excluded section
        includes %w[
          Certificate-Number
        ]
        # bases is a list of higher level nodes in which other data is nested. These unnecessary layers of nesting will be removed to bring the nested data closer to the root of the object.
        bases(%w[
          EPC-Data
          SAP-EPC-Data
          SAP09-Data
          SAP-Data
          Content
          Report-Header
          Energy-Assessment
          Property-Summary
          Energy-Use
          SAP-Property-Details
          Identification-Number
          Property
          Address
        ].concat(additional_bases))
        # preferred keys is a hash containing the original name of a data node as the key and the new name you have chosen for the node as the value.
        preferred_keys({
          "Certificate-Number" => "scheme_assessor_id",
        })
        # list nodes are data node which contain and array. This helps ensure they are correctly formatted.
        list_nodes %w[
          SAP-Floor-Dimensions
          LZC-Energy-Sources
          Suggested-Improvements
          ImprovementTexts
          SAP-Building-Parts
          SAP-Windows
          SAP-Deselected-Improvements
          Main-Heating-Details
          Storage-Heaters
          SAP-Special-Features
          SAP-Special-Feature?
          Air-Change-Rates
          PV-Arrays
          SAP-Opening-Types
          SAP-Openings
          SAP-Roofs
          SAP-Walls
          SAP-Community-Heating-Systems
          Community-Heat-Sources
          SAP-Floor-Dimensions
          ReportList
        ]
        # rootless lists is a hash containing the names of data nodes which can appear multiple times but are not given a parent node (for example wall in the property summary). These node are listed as the keys and the name of the parent node we wish to give their list is added as the value.
        rootless_list_nodes({
          "Wall" => "walls",
          "Walls" => "walls",
          "Roof" => "roofs",
          "Floor" => { parents: %w[Property-Summary], key: "floors" },
          "Window" => { parents: %w[Property-Summary], key: "windows" },
          "Main-Heating" => { parents: %w[Property-Summary], key: "main_heating" },
          "Main-Heating-Controls" => "main_heating_controls",
          "Addendum-Number" => "addendum_numbers",
          "SAP-Thermal-Bridge" => "thermal_bridges",
        })
        # ignored attributes are XML node attributes that are ignored in the parse and therefore are not written into value objects
        ignored_attributes %w[language xmlns:HIP xmlns:SAP]
      end
    end
  end
end
