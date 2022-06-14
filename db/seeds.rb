class LookupSeed
  SAP_TYPE = "SAP".freeze
  RDSAP_TYPE = "RdSAP".freeze
  CEPC_TYPE = "CEPC".freeze
  private_constant :SAP_TYPE
  private_constant :RDSAP_TYPE
  private_constant :CEPC_TYPE

  def initialize
    @assessment_attribute = Gateway::AssessmentAttributesGateway.new
    @assessment_lookup_gateway = Gateway::AssessmentLookupsGateway.new
  end

  def load_seed
    ActiveRecord::Base.transaction do
      energy_ratings
      built_form
      energy_tariff
      main_fuel
      glazed_type
      glazed_area
      tenure
      transaction_type
      construction_age_band
      property_type
      heat_loss_corridor
      mechanical_ventilation
      ventilation_type
      cylinder_insulation_thickness
      water_heating_fuel
    end
  end

  # Note that "SAP-Schema-XX.X" schema versions can be an "RdSAP" schema
  # From SAP-Schema-11.0 to SAP-Schema-16.3 (included)
  # From SAP-Schema-NI-11.2 to SAP-Schema-NI-17.2 (included)
  def add_lookup(attribute_id, key, value, type_of_assessment, schema_version)
    @assessment_lookup_gateway.add_lookup(
      Domain::AssessmentLookup.new(
        lookup_key: key,
        lookup_value: value,
        attribute_id:,
        type_of_assessment:,
        schema_version:,
      ),
    )
  end

  def save_lookup_value(attribute_name, key, value, type_of_assessment, schema_version = nil)
    attribute_id = @assessment_attribute.add_attribute(attribute_name:)
    add_lookup(attribute_id, key, value, type_of_assessment, schema_version)
  end

  def save_lookup_values(attribute_name, enum, type_of_assessment, schema_version = nil)
    attribute_id = @assessment_attribute.add_attribute(attribute_name:)
    enum.each do |key, value|
      add_lookup(attribute_id, key, value, type_of_assessment, schema_version)
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
    save_lookup_values("built_form", enum, RDSAP_TYPE)
    save_lookup_values("built_form", enum, SAP_TYPE)
  end

  def construction_age_band
    # K-12.0 (RdSAP Only)
    save_lookup_value("construction_age_band", "K", "Post-2006", RDSAP_TYPE, "SAP-Schema-12.0")

    # K-pre-17.0
    types_of_sap_pre17 = %w[
      SAP-Schema-16.3
      SAP-Schema-16.2
      SAP-Schema-16.1
      SAP-Schema-16.0
      SAP-Schema-15.0
      SAP-Schema-14.2
      SAP-Schema-14.1
      SAP-Schema-14.0
      SAP-Schema-13.0
      SAP-Schema-12.0
      SAP-Schema-11.2
      SAP-Schema-11.0
    ].freeze
    types_of_sap_pre17.each do |schema_version|
      save_lookup_value("construction_age_band", "K", "England and Wales: 2007 onwards", RDSAP_TYPE, schema_version)
      save_lookup_value("construction_age_band", "K", "England and Wales: 2007 onwards", SAP_TYPE, schema_version)
    end

    # NR - RdSAP Only
    schemes_that_use_not_recorded = %w[
      SAP-Schema-16.3
      SAP-Schema-16.2
      SAP-Schema-16.1
      RdSAP-Schema-20.0.0
      RdSAP-Schema-19.0
      RdSAP-Schema-18.0
      RdSAP-Schema-17.1
      RdSAP-Schema-17.0
      RdSAP-Schema-NI-20.0.0
      RdSAP-Schema-NI-19.0
      RdSAP-Schema-NI-18.0
      RdSAP-Schema-NI-17.4
      RdSAP-Schema-NI-17.3
    ]
    schemes_that_use_not_recorded.each do |schema_version|
      save_lookup_value("construction_age_band", "NR", "Not recorded", RDSAP_TYPE, schema_version)
    end

    # L - SAP and RdSAP
    schemes_that_use_l = %w[
      SAP-Schema-18.0.0
      SAP-Schema-17.1
      SAP-Schema-17.0
      RdSAP-Schema-20.0.0
      RdSAP-Schema-19.0
      RdSAP-Schema-18.0
      RdSAP-Schema-17.1
      RdSAP-Schema-17.0
      RdSAP-Schema-NI-20.0.0
      RdSAP-Schema-NI-19.0
      RdSAP-Schema-NI-18.0
      RdSAP-Schema-NI-17.4
      RdSAP-Schema-NI-17.3
    ]
    schemes_that_use_l.each do |schema_version|
      save_lookup_value("construction_age_band", "L", "England and Wales: 2012 onwards", RDSAP_TYPE, schema_version)
      save_lookup_value("construction_age_band", "L", "England and Wales: 2012 onwards", SAP_TYPE, schema_version)
    end

    # 0 - RdSAP Only
    schemes_that_use_0 = %w[
      SAP-Schema-16.3
      SAP-Schema-16.2
      SAP-Schema-16.1
      SAP-Schema-16.0
      SAP-Schema-15.0
      SAP-Schema-14.2
      SAP-Schema-14.1
      SAP-Schema-14.0
      SAP-Schema-13.0
      SAP-Schema-12.0
      RdSAP-Schema-20.0.0
      RdSAP-Schema-19.0
      RdSAP-Schema-18.0
      RdSAP-Schema-17.1
      RdSAP-Schema-17.0
      RdSAP-Schema-NI-20.0.0
      RdSAP-Schema-NI-19.0
      RdSAP-Schema-NI-18.0
      RdSAP-Schema-NI-17.4
      RdSAP-Schema-NI-17.3
    ]
    schemes_that_use_0.each do |schema_version|
      save_lookup_value("construction_age_band", "0", "Not applicable", RDSAP_TYPE, schema_version)
    end

    construction_age_band = {
      "A" => "England and Wales: before 1900",
      "B" => "England and Wales: 1900-1929",
      "C" => "England and Wales: 1930-1949",
      "D" => "England and Wales: 1950-1966",
      "E" => "England and Wales: 1967-1975",
      "F" => "England and Wales: 1976-1982",
      "G" => "England and Wales: 1983-1990",
      "H" => "England and Wales: 1991-1995",
      "I" => "England and Wales: 1996-2002",
      "J" => "England and Wales: 2003-2006",
      "K" => "England and Wales: 2007-2011",
    }.freeze
    save_lookup_values("construction_age_band", construction_age_band, RDSAP_TYPE)
    save_lookup_values("construction_age_band", construction_age_band, SAP_TYPE)
  end

  def energy_tariff
    rdsap_enum = {
      "1" => "dual",
      "2" => "Single",
      "3" => "Unknown",
      "4" => "dual (24 hour)",
      "5" => "off-peak 18 hour",
    }.freeze
    save_lookup_values("energy_tariff", rdsap_enum, RDSAP_TYPE)

    sap_enum = {
      "1" => "standard tariff",
      "2" => "off-peak 7 hour",
      "3" => "off-peak 10 hour",
      "4" => "24 hour",
      "ND" => "not applicable",
    }.freeze
    save_lookup_values("energy_tariff", sap_enum, SAP_TYPE)
  end

  def energy_ratings
    enum = {
      "0" => "N/A",
      "1" => "Very Poor",
      "2" => "Poor",
      "3" => "Average",
      "4" => "Good",
      "5" => "Very Good",
    }.freeze
    save_lookup_values("ratings", enum, RDSAP_TYPE)
    save_lookup_values("ratings", enum, SAP_TYPE)
  end

  def glazed_area
    glazed_area_enum = {
      "1" => "Normal",
      "2" => "More Than Typical",
      "3" => "Less Than Typical",
      "4" => "Much More Than Typical",
      "5" => "Much Less Than Typical",
      "ND" => "Not Defined",
    }.freeze
    save_lookup_values("glazed_area", glazed_area_enum, RDSAP_TYPE)
    save_lookup_values("glazed_area", glazed_area_enum, SAP_TYPE)
  end

  def glazed_type
    glazed_type_enum = {
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
    save_lookup_values("glazed_type_rdsap", glazed_type_enum, RDSAP_TYPE)
    save_lookup_values("glazed_type_rdsap", glazed_type_enum, SAP_TYPE)
  end

  def heat_loss_corridor
    enum = {
      "0" => "no corridor",
      "1" => "heated corridor",
      "2" => "unheated corridor",
    }.freeze
    save_lookup_values("heat_loss_corridor", enum, RDSAP_TYPE)
    save_lookup_values("heat_loss_corridor", enum, SAP_TYPE)
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
    save_lookup_values("rdsap_main_fuel", rdsap_enum, RDSAP_TYPE)

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
    save_lookup_values("sap_main_fuel", sap_enum, SAP_TYPE)
  end

  def mechanical_ventilation
    mechanical_ventilation_enum = {
      "0" => "natural",
      "1" => "mechanical, supply and extract",
      "2" => "mechanical, extract only",
    }.freeze
    save_lookup_values("mechanical_ventilation", mechanical_ventilation_enum, RDSAP_TYPE)

    mechanical_ventilation_pre12_enum = {
      "0" => "none",
      "1" => "mechanical - heat recovering",
      "2" => "mechanical - non recovering",
    }.freeze
    types_of_sap_pre12 = %w[
      SAP-Schema-11.2
      SAP-Schema-11.0
      SAP-Schema-10.2
      SAP-Schema-NI-11.2
    ].freeze
    types_of_sap_pre12.each do |schema_version|
      save_lookup_values("mechanical_ventilation", mechanical_ventilation_pre12_enum, RDSAP_TYPE, schema_version)
    end
    save_lookup_values("mechanical_ventilation", mechanical_ventilation_enum, RDSAP_TYPE)
    save_lookup_values("mechanical_ventilation", mechanical_ventilation_enum, SAP_TYPE)
  end

  def property_type
    enum = {
      "0" => "House",
      "1" => "Bungalow",
      "2" => "Flat",
      "3" => "Maisonette",
      "4" => "Park home",
    }.freeze
    save_lookup_values("property_type", enum, RDSAP_TYPE)
    save_lookup_values("property_type", enum, SAP_TYPE)
  end

  def tenure
    enum = {
      "1" => "Owner-occupied",
      "2" => "Rented (social)",
      "3" => "Rented (private)",
      "ND" =>
        "Not defined - use in the case of a new dwelling for which the intended tenure in not known. It is not to be used for an existing dwelling",
    }.freeze
    save_lookup_values("tenure", enum, RDSAP_TYPE)
    save_lookup_values("tenure", enum, SAP_TYPE)
  end

  def transaction_type
    shared_transaction_type = {
      "1" => "marketed sale",
      "2" => "non marketed sale",
      "3" =>
        "rental (social) - this is for backwards compatibility only and should not be used",
      "4" =>
        "rental (private) - this is for backwards compatibility only and should not be used",
      "5" => "not sale or rental",
      "6" => "new dwelling",
      "7" =>
        "not recorded - this is for backwards compatibility only and should not be used",
      "8" => "rental",
      "9" => "assessment for green deal",
      "10" => "following green deal",
      "11" => "FiT application",
    }
    sap_transaction_type = {
      "12" => "Stock condition survey",
    }
    rdsap_transaction_type = {
      "12" => "RHI application",
      "13" => "ECO assessment",
      "14" => "Stock condition survey",
    }
    cepc_transaction_type = {
      "1" => "Mandatory issue (Marketed sale)",
      "2" => "Mandatory issue (Non-marketed sale)",
      "3" => "Mandatory issue (Property on construction).",
      "4" => "Mandatory issue (Property to let).",
      "5" => "Voluntary re-issue (A valid EPC is already lodged).",
      "6" => "Voluntary (No legal requirement for an EPC).",
      "7" => "Not recorded.",
    }.freeze
    save_lookup_values("transaction_type", shared_transaction_type, SAP_TYPE)
    save_lookup_values("transaction_type", sap_transaction_type, SAP_TYPE)
    save_lookup_values("transaction_type", shared_transaction_type, RDSAP_TYPE)
    save_lookup_values("transaction_type", rdsap_transaction_type, RDSAP_TYPE)
    save_lookup_values("transaction_type", cepc_transaction_type, CEPC_TYPE)
  end

  def ventilation_type
    ventilation_enum = {
      "1" => "natural with intermittent extract fans",
      "2" => "natural with passive vents",
      "3" => "positive input from loft",
      "4" => "positive input from outside",
      "5" => "mechanical extract, centralised (MEV c)",
      "6" => "mechanical extract, decentralised (MEV dc)",
      "7" => "balanced without heat recovery (MV)",
      "8" => "balanced with heat recovery (MVHR)",
      "9" => "natural with intermittent extract fans and/or passive vents.  For backwards compatibility only, do not use.",
      "10" => "natural with intermittent extract fans and passive vents",
    }.freeze
    ni_sap_schemas = %w[
      SAP-Schema-NI-16.1
      SAP-Schema-NI-16.0
      SAP-Schema-NI-15.0
      SAP-Schema-NI-14.2
      SAP-Schema-NI-14.1
      SAP-Schema-NI-14.0
      SAP-Schema-NI-13.0
    ].freeze
    ni_sap_schemas.each do |schema|
      save_lookup_value("ventilation_type", "9", ventilation_enum["9"].split(".").first, SAP_TYPE, schema)
    end
    save_lookup_values("ventilation_type", ventilation_enum, SAP_TYPE)
  end

  def cylinder_insulation_thickness
    cylinder_insulation_thickness_enum = {
      "12" => "12 mm",
      "25" => "25 mm",
      "38" => "38 mm",
      "50" => "50 mm",
      "80" => "80 mm",
      "120" => "120 mm",
      "160" => "160 mm",
    }.freeze
    save_lookup_values("cylinder_insulation_thickness", cylinder_insulation_thickness_enum, RDSAP_TYPE)
  end

  def water_heating_fuel
    rdsap_water_heating_fuel = {
      "0" => "To be used only when there is no heating/hot-water system or data is from a community network",
      "1" => "mains gas - this is for backwards compatibility only and should not be used",
      "2" => "LPG - this is for backwards compatibility only and should not be used",
      "3" => "bottled LPG",
      "4" => "oil - this is for backwards compatibility only and should not be used",
      "5" => "anthracite",
      "6" => "wood logs",
      "7" => "bulk wood pellets",
      "8" => "wood chips",
      "9" => "dual fuel - mineral + wood",
      "10" => "electricity - this is for backwards compatibility only and should not be used",
      "11" => "waste combustion - this is for backwards compatibility only and should not be used",
      "12" => "biomass - this is for backwards compatibility only and should not be used",
      "13" => "biogas - landfill - this is for backwards compatibility only and should not be used",
      "14" => "house coal - this is for backwards compatibility only and should not be used",
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
      "56" => "heat from boilers that can use mineral oil or biodiesel (community)",
      "57" => "heat from boilers using biodiesel from any biomass source (community)",
      "58" => "biodiesel from vegetable oil only (community)",
      "99" => "from heat network data (community)",
    }.freeze
    rdsap_water_heating_fuel_pre142 = {
      "1" => "mains gas",
      "2" => "LPG",
      "4" => "oil",
      "10" => "electricity",
      "11" => "waste combustion",
      "12" => "biomass",
      "13" => "biogas - landfill",
      "14" => "house coal",
    }
    pre143_sap = %i[
      SAP-Schema-14.2
      SAP-Schema-14.1
      SAP-Schema-14.0
      SAP-Schema-13.0
      SAP-Schema-12.0
      SAP-Schema-11.2
      SAP-Schema-11.0
      SAP-Schema-10.2
      SAP-Schema-NI-14.2
      SAP-Schema-NI-14.1
      SAP-Schema-NI-14.0
      SAP-Schema-NI-13.0
      SAP-Schema-NI-12.0
      SAP-Schema-NI-11.2
    ]
    pre143_sap.each do |schema|
      save_lookup_values("water_heating_fuel", rdsap_water_heating_fuel_pre142, RDSAP_TYPE, schema)
    end
    save_lookup_values("water_heating_fuel", rdsap_water_heating_fuel, RDSAP_TYPE)

    sap_water_heating_fuel = {
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
      "23" => "Solid fuel: wood pellets (bulk supply in bags, for main heating)",
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
      "50" => "Community heating schemes: electricity for pumping in distribution network",
      "51" => "Community heating schemes: heat from mains gas",
      "52" => "Community heating schemes: heat from LPG",
      "53" => "Community heating schemes: heat from oil",
      "54" => "Community heating schemes: heat from coal",
      "55" => "Community heating schemes: heat from B30D",
      "56" => "Community heating schemes: heat from boilers that can use mineral oil or biodiesel",
      "57" => "Community heating schemes: heat from boilers using biodiesel from any biomass source",
      "58" => "Community heating schemes: biodiesel from vegetable oil only",
      "71" => "biodiesel from any biomass source",
      "72" => "biodiesel from used cooking oil only",
      "73" => "biodiesel from vegetable oil only",
      "74" => "appliances able to use mineral oil or liquid biofuel",
      "75" => "B30K",
      "76" => "bioethanol from any biomass source",
      "99" => "Community heating schemes: special fuel",
    }.freeze
    save_lookup_values("water_heating_fuel", sap_water_heating_fuel, SAP_TYPE)
  end
end
