class LookupSeed
  def initialize
    @assessment_attribute = Gateway::AssessmentAttributesGateway.new
    @assessment_lookup_gateway = Gateway::AssessmentLookUpsGateway.new
  end

  def run!
    ActiveRecord::Base.transaction do
      built_form
      construction_age_band
      energy_tariff
      ratings
      glazed_area_rdsap
      glazed_type_rdsap
      heat_loss_corridor
      main_fuel
      mechanical_ventilation
      property_type
      tenure
      transaction_type
      cepc_transaction_type
    end
  end

  def add_lookup(attribute_name, enum, schema, schema_version: nil)
    attribute_id = @assessment_attribute.add_attribute(attribute_name: attribute_name)
    enum.each do |key, value|
      @assessment_lookup_gateway.add_lookup(Domain::AssessmentLookup.new(
        lookup_key: key,
        lookup_value: value,
        attribute_id: attribute_id,
        schema: schema,
        schema_version: schema_version
      )
      )
    end
  end

  def built_form
    enum = {
      "1" => "Detached",
      "2" => "Semi-Detached",
      "3" => "End-Terrace",
      "4" => "Mid-Terrace",
      "5" => "Enclosed End-Terrace",
      "6" => "Enclosed Mid-Terrace",
      "NR" => "Not Recorded",
    }.freeze
    add_lookup("built_form", enum, "RdSAP")
  end

  def construction_age_band
  end

  def energy_tariff
    rdsap_enum = {
      "1" => "dual",
      "2" => "Single",
      "3" => "Unknown",
      "4" => "dual (24 hour)",
      "5" => "off-peak 18 hour",
    }.freeze
    add_lookup("energy_tariff", rdsap_enum, "RdSAP")

    sap_enum = {
      "1" => "standard tariff",
      "2" => "off-peak 7 hour",
      "3" => "off-peak 10 hour",
      "4" => "24 hour",
      "ND" => "not applicable",
    }.freeze
    add_lookup("energy_tariff", sap_enum, "SAP")
  end

  def ratings
    enum = {
      "0" => "N/A",
      "1" => "Very Poor",
      "2" => "Poor",
      "3" => "Average",
      "4" => "Good",
      "5" => "Very Good",
    }.freeze
    add_lookup("ratings", enum, "RdSAP")
  end

  def glazed_area_rdsap
    rdsap_enum = {
      "1" => "Normal",
      "2" => "More Than Typical",
      "3" => "Less Than Typical",
      "4" => "Much More Than Typical",
      "5" => "Much Less Than Typical",
      "ND" => "Not Defined",
    }.freeze
    add_lookup("glazed_area_rdsap", rdsap_enum, "RdSAP")
  end

  def glazed_type_rdsap
    rdsap_enum = {
      "1" => "double glazing installed before 2002",
      "2" => "double glazing installed during or after 2002",
      "3" => "double glazing, unknown install date",
      "4" => "secondary glazing",
      "5" => "single glazing",
      "6" => "triple glazing",
      "7" => "double, known data",
      "8" => "triple, known data",
      "ND" => "not defined",
    }.freeze
    add_lookup("glazed_type_rdsap", rdsap_enum, "RdSAP")
  end

  def heat_loss_corridor
    enum = {
      "0" => "no corridor",
      "1" => "heated corridor",
      "2" => "unheated corridor",
    }.freeze
    add_lookup("heat_loss_corridor", enum, "RdSAP")
  end

  def main_fuel
    rdsap_enum = {
      "0" =>
        "To be used only when there is no heating/hot-water system or data is from a community network",
      "1" =>
        "mains gas - this is for backwards compatibility only and should not be used",
      "2" =>
        "LPG - this is for backwards compatibility only and should not be used",
      "3" => "bottled LPG",
      "4" =>
        "oil - this is for backwards compatibility only and should not be used",
      "5" => "anthracite",
      "6" => "wood logs",
      "7" => "bulk wood pellets",
      "8" => "wood chips",
      "9" => "dual fuel - mineral + wood",
      "10" =>
        "electricity - this is for backwards compatibility only and should not be used",
      "11" =>
        "waste combustion - this is for backwards compatibility only and should not be used",
      "12" =>
        "biomass - this is for backwards compatibility only and should not be used",
      "13" =>
        "biogas - landfill - this is for backwards compatibility only and should not be used",
      "14" =>
        "house coal - this is for backwards compatibility only and should not be used",
      "15" => "smokeless coal",
      "16" => "wood pellets in bags for secondary heating",
      "17" => "LPG special condition",
      "18" => "B30K (not community)",
      "19" => "bioethanol",
      "20" => "mains gas (community)",
      "21" => "LPG (community)",
      "22" => "oil (community)",
      "23" => "B30D (community)",
      "24" => "coal (community)",
      "25" => "electricity (community)",
      "26" => "mains gas (not community)",
      "27" => "LPG (not community)",
      "28" => "oil (not community)",
      "29" => "electricity (not community)",
      "30" => "waste combustion (community)",
      "31" => "biomass (community)",
      "32" => "biogas (community)",
      "33" => "house coal (not community)",
      "34" => "biodiesel from any biomass source",
      "35" => "biodiesel from used cooking oil only",
      "36" => "biodiesel from vegetable oil only (not community)",
      "37" => "appliances able to use mineral oil or liquid biofuel",
      "51" => "biogas (not community)",
      "56" =>
        "heat from boilers that can use mineral oil or biodiesel (community)",
      "57" =>
        "heat from boilers using biodiesel from any biomass source (community)",
      "58" => "biodiesel from vegetable oil only (community)",
      "99" => "from heat network data (community)",
    }.freeze
    add_lookup("rdsap_main_fuel", rdsap_enum, "RdSAP")

    sap_enum = {
      "1" => "Gas: mains gas",
      "2" => "Gas: bulk LPG",
      "3" => "Gas: bottled LPG",
      "4" => "Oil: heating oil",
      "7" => "Gas: biogas",
      "8" => "LNG",
      "9" => "LPG subject to Special Condition 18",
      "10" => "Solid fuel: dual fuel appliance (mineral and wood)",
      "11" => "Solid fuel: house coal",
      "12" => "Solid fuel: manufactured smokeless fuel",
      "15" => "Solid fuel: anthracite",
      "20" => "Solid fuel: wood logs",
      "21" => "Solid fuel: wood chips",
      "22" => "Solid fuel: wood pellets (in bags, for secondary heating)",
      "23" =>
        "Solid fuel: wood pellets (bulk supply in bags, for main heating)",
      "36" => "Electricity: electricity sold to grid",
      "37" => "Electricity: electricity displaced from grid",
      "39" => "Electricity: electricity, unspecified tariff",
      "41" => "Community heating schemes: heat from electric heat pump",
      "42" => "Community heating schemes: heat from boilers - waste combustion",
      "43" => "Community heating schemes: heat from boilers - biomass",
      "44" => "Community heating schemes: heat from boilers - biogas",
      "45" => "Community heating schemes: waste heat from power stations",
      "46" => "Community heating schemes: geothermal heat source",
      "48" => "Community heating schemes: heat from CHP",
      "49" => "Community heating schemes: electricity generated by CHP",
      "50" =>
        "Community heating schemes: electricity for pumping in distribution network",
      "51" => "Community heating schemes: heat from mains gas",
      "52" => "Community heating schemes: heat from LPG",
      "53" => "Community heating schemes: heat from oil",
      "54" => "Community heating schemes: heat from coal",
      "55" => "Community heating schemes: heat from B30D",
      "56" =>
        "Community heating schemes: heat from boilers that can use mineral oil or biodiesel",
      "57" =>
        "Community heating schemes: heat from boilers using biodiesel from any biomass source",
      "58" => "Community heating schemes: biodiesel from vegetable oil only",
      "72" => "biodiesel from used cooking oil only",
      "73" => "biodiesel from vegetable oil only",
      "74" => "appliances able to use mineral oil or liquid biofuel",
      "75" => "B30K",
      "76" => "bioethanol from any biomass source",
      "99" => "Community heating schemes: special fuel",
    }.freeze
    add_lookup("sap_main_fuel", sap_enum, "SAP")
  end

  def mechanical_ventilation
    mechanical_ventilation_enum = {
      "0" => "natural",
      "1" => "mechanical, supply and extract",
      "2" => "mechanical, extract only",
    }.freeze
    add_lookup("mechanical_ventilation", mechanical_ventilation_enum, "RdSAP")

    mechanical_ventilation_pre12_enum = {
      "0-pre12.0" => "none",
      "1-pre12.0" => "mechanical - heat recovering",
      "2-pre12.0" => "mechanical - non recovering",
    }.freeze
    types_of_sap_pre12 = %w[
        SAP-Schema-11.2
        SAP-Schema-11.0
        SAP-Schema-10.2
      ].freeze

    types_of_sap_pre12.each do |schema_version|
      add_lookup("mechanical_ventilation", mechanical_ventilation_pre12_enum, "RdSAP", schema_version: schema_version)
    end
  end

  def property_type
    enum = {
      "0" => "House",
      "1" => "Bungalow",
      "2" => "Flat",
      "3" => "Maisonette",
      "4" => "Park home",
    }.freeze
    add_lookup("property_type", enum, "RdSAP")
  end

  def tenure
    enum = {
      "1" => "Owner-occupied",
      "2" => "Rented (social)",
      "3" => "Rented (private)",
      "ND" =>
        "Not defined - use in the case of a new dwelling for which the intended tenure in not known. It is not to be used for an existing dwelling",
    }.freeze
    add_lookup("tenure", enum, "RdSAP")
  end

  def transaction_type
  end

  def cepc_transaction_type
  end

end

LookupSeed.new.run!



# ActiveRecord::Base.transaction do
#
#   attribute_id = assessment_attribute.add_attribute(attribute_name: "built_form")
#   next_enum = {
#     "1" => "Detached",
#     "2" => "Semi-Detached",
#     "3" => "End-Terrace",
#     "4" => "Mid-Terrace",
#     "5" => "Enclosed End-Terrace",
#     "6" => "Enclosed Mid-Terrace",
#     "NR" => "Not Recorded",
#   }.freeze
#   next_enum.each do |key, value|
#     assessment_lookup_gateway.add_lookup(Domain::AssessmentLookup.new(
#       lookup_key: key,
#       lookup_value: value,
#       attribute_id: attribute_id,
#       schema: "RdSAP",
#       schema_version: nil
#     )
#     )
#   end

  # attribute_id = assessment_attribute.add_attribute(attribute_name: "construction_age_band")
  # next_enum = {
  #   "1" => "Detached",
  #   "2" => "Semi-Detached",
  #   "3" => "End-Terrace",
  #   "4" => "Mid-Terrace",
  #   "5" => "Enclosed End-Terrace",
  #   "6" => "Enclosed Mid-Terrace",
  #   "NR" => "Not Recorded",
  # }.freeze
  # next_enum.each do |key, value|
  #   assessment_lookup_gateway.add_lookup(Domain::AssessmentLookup.new(
  #     lookup_key: key,
  #     lookup_value: value,
  #     attribute_id: attribute_id,
  #     schema: "RdSAP",
  #     schema_version: nil
  #   )
  #   )
  # end



