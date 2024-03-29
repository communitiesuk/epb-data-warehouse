module XmlPresenter
  module Cepc
    class Cepc70Base < XmlPresenter::ToWarehouse::BaseConfiguration
      def self.setup
        excludes %w[
          Insurance-Details
          EPC-Related-Party-Disclosure
          Energy-Assessor
          Unstructured-Data
          EPC-Rating-Scale
          Dec-Related-Party-Disclosure
          AR-Questions
          RRN
        ]
        includes %w[
          Certificate-Number
        ]
        bases %w[
          Property-Details
          Property-Address
          Calculation-Details
          Report-Header
          Report-Data
          EPC-Rating
          Energy-Performance-Certificate
          OR-Operational-Rating
          Display-Certificate
          Recommendations-Report
          RR-Recommendations
          Advisory-Report
          AR-Recommendations
          Air-Conditioning-Inspection-Certificate
        ]
        preferred_keys({
          "Certificate-Number" => "scheme_assessor_id",
        })
        list_nodes %w[
          ReportKeyFields
          Activities
          AR-Recommendations
          RR-Recommendations
          ACI-Sub-Systems
          ACI-Key-Recommendations
          AC-Sub-Systems
          AR-Questions
          Benchmarks
          HVAC-Systems
          Renewable-Energy-Source
        ]
        rootless_list_nodes({
          "Short-Payback" => "short_payback",
          "Medium-Payback" => "medium_payback",
          "Long-Payback" => "long_payback",
          "Other-Payback" => "other_payback",
          "ACI-Cooling-Plant" => "ACI_cooling_plant",
          "ACI-Air-Handling-System" => "ACI_air_handling_system",
          "ACI-Terminal-Unit" => "ACI_terminal_unit",
          "ACI-System-Control" => "ACI_system_control",
          "Sub-System-Efficiency-Capacity-Cooling-Loads" => "sub_system_efficiency_capacity_cooling_loads",
          "Improvement-Options" => "improvement_options",
          "Alternative-Solutions" => "alternative_solutions",
          "Other-Recommendations" => "other_recommendations",
          "Refrigerant-Type" => "refrigerant_types",
          "Guidance" => "guidance",
          "Specials" => "specials",
          "Answer" => "answers",
          "Building-Data" => "building_data",
          "Equipment-Operator" => "equipment_operator",
          "Equipment-Owner" => "equipment_owner",
        })
        pick_root_node(root_node: "Report", sub_node: "RRN")
      end
    end
  end
end
