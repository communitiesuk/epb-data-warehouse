module XmlPresenter
  module Cepc
    class Cepc800ExportConfiguration < XmlPresenter::ToWarehouse::BaseConfiguration
      excludes %w[
        Insurance-Details
        EPC-Related-Party-Disclosure
        Energy-Assessor
        Unstructured-Data
        EPC-Rating-Scale
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
        Energy-Assessment
        Energy-Performance-Certificate
      ]
      preferred_keys({
        "Certificate-Number" => "scheme_assessor_id",
      })
      list_nodes %w[
        ReportKeyFields
        AR-Recommendations
        RR-Recommendations
        ACI-Sub-Systems
        ACI-Key-Recommendations
        AC-Sub-Systems
        AR-Questions
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
        "Benchmarks" => "benchmarks",
        "Building-Data" => "building_data",
      })
      pick_root_node(root_node: "Report", sub_node: "RRN")
    end
  end
end
