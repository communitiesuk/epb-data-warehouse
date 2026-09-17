require_relative "../../shared_context/shared_lodgement"
require_relative "../../shared_context/shared_ons_data"
require_relative "../../shared_context/shared_data_export"
require_relative "../../shared_context/shared_recommendations"

describe "Domestic NI Recommendations Report" do
  include_context "when fetching recommendations report"
  include_context "when lodging XML"
  include_context "when saving ons data"
  include_context "when exporting data"

  let(:expected_columns) do
    %w[certificate_number improvement_item improvement_id indicative_cost improvement_summary_text improvement_descr_text]
  end

  let(:query_result) do
    ActiveRecord::Base.connection.exec_query("SELECT * FROM mvw_domestic_ni_rr_search ORDER BY certificate_number, improvement_item", "SQL").map { |result| result }
  end

  let(:certificate_numbers) { query_result.map { |row| row["certificate_number"] }.uniq }
  let(:england_assessment_id) { "0000-0000-0000-0000-0010" }
  let(:wales_assessment_id) { "0000-0000-0000-0000-0011" }
  let(:ni_120_sap_assessment_id) { "1000-0000-0000-0000-0120" }
  let(:ni_130_rdsap_assessment_id) { "1000-0000-0000-0000-1130" }
  let(:ni_130_sap_assessment_id) { "1000-0000-0000-0000-0130" }
  let(:ni_140_rdsap_assessment_id) { "1000-0000-0000-0000-1140" }
  let(:ni_142_rdsap_assessment_id) { "1000-0000-0000-0000-1142" }
  let(:ni_142_sap_assessment_id) { "1000-0000-0000-0000-0142" }
  let(:ni_150_sap_assessment_id) { "1000-0000-0000-0000-0150" }
  let(:ni_150_rdsap_assessment_id) { "1000-0000-0000-0000-1150" }
  let(:ni_161_sap_assessment_id) { "1000-0000-0000-0000-0161" }
  let(:ni_172_sap_assessment_id) { "1000-0000-0000-0000-0172" }
  let(:ni_173_rdsap_assessment_id) { "1000-0000-0000-0000-1173" }
  let(:ni_173_sap_assessment_id) { "1000-0000-0000-0000-0173" }
  let(:ni_180_sap_assessment_id) { "1000-0000-0000-0000-0180" }
  let(:ni_2101_rdsap_assessment_id) { "0000-0000-0000-0000-1211" }

  let(:expected_ni_120_sap_data) do
    [{ "certificate_number" => ni_120_sap_assessment_id,
       "improvement_item" => 1,
       "improvement_id" => nil,
       "indicative_cost" => nil,
       "improvement_summary_text" => "Water heating",
       "improvement_descr_text" => "This is an improvement description" },
     { "certificate_number" => ni_120_sap_assessment_id,
       "improvement_item" => 2,
       "improvement_id" => nil,
       "indicative_cost" => nil,
       "improvement_summary_text" => "Solar Panels",
       "improvement_descr_text" => "Improvement desc" }]
  end

  let(:expected_ni_130_rdsap_data) do
    [{ "certificate_number" => ni_130_rdsap_assessment_id,
       "improvement_item" => 1,
       "improvement_id" => nil,
       "indicative_cost" => nil,
       "improvement_summary_text" => "This is the summary",
       "improvement_descr_text" => "This is the description" },
     { "certificate_number" => ni_130_rdsap_assessment_id,
       "improvement_item" => 2,
       "improvement_id" => nil,
       "indicative_cost" => nil,
       "improvement_summary_text" => "This is another summary",
       "improvement_descr_text" => "Improvement desc" }]
  end

  let(:expected_ni_130_sap_data) do
    [{ "certificate_number" => ni_130_sap_assessment_id,
       "improvement_descr_text" => "Loft insulation laid in the loft space or between roof rafters to a depth of at least 270 mm will significantly reduce heat loss through the roof; this will improve levels of comfort, reduce energy use and lower fuel bills. Insulation should not be placed below any cold water storage tank, any such tank should also be insulated on its sides and top, and there should be boarding on battens over the insulation to provide safe access between the loft hatch and the cold water tank. The insulation can be installed by professional contractors but also by a capable DIY enthusiast. Loose granules may be used instead of insulation quilt; this form of loft insulation can be blown into place and can be useful where access is difficult. The loft space must have adequate ventilation to prevent dampness; seek advice about this if unsure. Further information about loft insulation and details of local contractors can be obtained from the National Insulation Association (www.nationalinsulationassociation.org.uk).",
       "improvement_id" => "5",
       "improvement_item" => 1,
       "improvement_summary_text" => "Increase loft insulation to 270 mm",
       "indicative_cost" => nil },
     { "certificate_number" => ni_130_sap_assessment_id,
       "improvement_descr_text" => "Installing a 160 mm thick cylinder jacket around the hot water cylinder will help to maintain the water at the required temperature; this will reduce the amount of energy used and lower fuel bills. A cylinder jacket is a layer of insulation that is fitted around the hot water cylinder. A jacket 160 mm thick (or two 80 mm jackets) would be best dependent upon space limitations but an 80 mm jacket, would be a significant improvement if there are space limitations. The jacket should be fitted over any thermostat clamped to the cylinder. Hot water pipes from the hot water cylinder should also be insulated, using pre-formed pipe insulation of up to 50 mm thickness, or to suit the space available, for as far as they can be accessed to reduce losses in summer. All these materials can be purchased from DIY stores and installed by a competent DIY enthusiast.",
       "improvement_id" => "1",
       "improvement_item" => 2,
       "improvement_summary_text" => "Insulate hot water cylinder with 160 mm jacket",
       "indicative_cost" => nil }]
  end

  let(:expected_ni_140_rdsap_data) do
    [{ "certificate_number" => ni_140_rdsap_assessment_id,
       "improvement_descr_text" => "Loft insulation laid in the loft space or between roof rafters to a depth of at least 270 mm will significantly reduce heat loss through the roof; this will improve levels of comfort, reduce energy use and lower fuel bills. Insulation should not be placed below any cold water storage tank, any such tank should also be insulated on its sides and top, and there should be boarding on battens over the insulation to provide safe access between the loft hatch and the cold water tank. The insulation can be installed by professional contractors but also by a capable DIY enthusiast. Loose granules may be used instead of insulation quilt; this form of loft insulation can be blown into place and can be useful where access is difficult. The loft space must have adequate ventilation to prevent dampness; seek advice about this if unsure. Further information about loft insulation and details of local contractors can be obtained from the National Insulation Association (www.nationalinsulationassociation.org.uk).",
       "improvement_id" => "5",
       "improvement_item" => 1,
       "improvement_summary_text" => "Increase loft insulation to 270 mm",
       "indicative_cost" => nil },
     { "certificate_number" => ni_140_rdsap_assessment_id,
       "improvement_descr_text" => "Installing an 80 mm thick cylinder jacket around the hot water cylinder will help to maintain the water at the required temperature; this will reduce the amount of energy used and lower fuel bills. A cylinder jacket is a layer of insulation that is fitted around the hot water cylinder. The jacket should be fitted over any thermostat clamped to the cylinder. Hot water pipes from the hot water cylinder should also be insulated, using pre-formed pipe insulation of up to 50 mm thickness, or to suit the space available, for as far as they can be accessed to reduce losses in summer. All these materials can be purchased from DIY stores and installed by a competent DIY enthusiast.",
       "improvement_id" => "1",
       "improvement_item" => 2,
       "improvement_summary_text" => "Insulate hot water cylinder with 80 mm jacket",
       "indicative_cost" => nil }]
  end

  let(:expected_ni_142_rdsap_data) do
    [{ "certificate_number" => "1000-0000-0000-0000-1142",
       "improvement_descr_text" => "Loft insulation laid in the loft space or between roof rafters to a depth of at least 270 mm will significantly reduce heat loss through the roof; this will improve levels of comfort, reduce energy use and lower fuel bills. Insulation should not be placed below any cold water storage tank; any such tank should also be insulated on its sides and top, and there should be boarding on battens over the insulation to provide safe access between the loft hatch and the cold water tank. The insulation can be installed by professional contractors but also by a capable DIY enthusiast. Loose granules may be used instead of insulation quilt; this form of loft insulation can be blown into place and can be useful where access is difficult. The loft space must have adequate ventilation to prevent dampness; seek advice about this if unsure (particularly if installing insulation between rafters because a vapour control layer and ventilation above the insulation are required). Further information about loft insulation and details of local contractors can be obtained from the National Insulation Association (www.nationalinsulationassociation.org.uk).",
       "improvement_id" => "5",
       "improvement_item" => 1,
       "improvement_summary_text" => "Increase loft insulation to 270 mm",
       "indicative_cost" => nil },
     { "certificate_number" => "1000-0000-0000-0000-1142",
       "improvement_descr_text" => "Installing an 80 mm thick cylinder jacket around the hot water cylinder will help to maintain the water at the required temperature; this will reduce the amount of energy used and lower fuel bills. A cylinder jacket is a layer of insulation that is fitted around the hot water cylinder. The jacket should be fitted over any thermostat clamped to the cylinder. Hot water pipes from the hot water cylinder should also be insulated, using pre-formed pipe insulation of up to 50 mm thickness (or to suit the space available) for as far as they can be accessed to reduce losses in summer. All these materials can be purchased from DIY stores and installed by a competent DIY enthusiast.",
       "improvement_id" => "1",
       "improvement_item" => 2,
       "improvement_summary_text" => "Insulate hot water cylinder with 80 mm jacket",
       "indicative_cost" => nil }]
  end

  let(:expected_ni_142_sap_data) do
    [{ "certificate_number" => "1000-0000-0000-0000-0142",
       "improvement_descr_text" => "Loft insulation laid in the loft space or between roof rafters to a depth of at least 270 mm will significantly reduce heat loss through the roof; this will improve levels of comfort, reduce energy use and lower fuel bills. Insulation should not be placed below any cold water storage tank; any such tank should also be insulated on its sides and top, and there should be boarding on battens over the insulation to provide safe access between the loft hatch and the cold water tank. The insulation can be installed by professional contractors but also by a capable DIY enthusiast. Loose granules may be used instead of insulation quilt; this form of loft insulation can be blown into place and can be useful where access is difficult. The loft space must have adequate ventilation to prevent dampness; seek advice about this if unsure (particularly if installing insulation between rafters because a vapour control layer and ventilation above the insulation are required). Further information about loft insulation and details of local contractors can be obtained from the National Insulation Association (www.nationalinsulationassociation.org.uk).",
       "improvement_id" => "5",
       "improvement_item" => 1,
       "improvement_summary_text" => "Increase loft insulation to 270 mm",
       "indicative_cost" => nil },
     { "certificate_number" => "1000-0000-0000-0000-0142",
       "improvement_descr_text" => "Installing an 80 mm thick cylinder jacket around the hot water cylinder will help to maintain the water at the required temperature; this will reduce the amount of energy used and lower fuel bills. A cylinder jacket is a layer of insulation that is fitted around the hot water cylinder. The jacket should be fitted over any thermostat clamped to the cylinder. Hot water pipes from the hot water cylinder should also be insulated, using pre-formed pipe insulation of up to 50 mm thickness (or to suit the space available) for as far as they can be accessed to reduce losses in summer. All these materials can be purchased from DIY stores and installed by a competent DIY enthusiast.",
       "improvement_id" => "1",
       "improvement_item" => 2,
       "improvement_summary_text" => "Insulate hot water cylinder with 80 mm jacket",
       "indicative_cost" => nil }]
  end

  let(:expected_ni_150_sap_data) do
    [{ "certificate_number" => ni_150_sap_assessment_id,
       "improvement_descr_text" => "Replacement of traditional light bulbs with energy saving recommended ones will reduce lighting costs over the lifetime of the bulb, and they last up to 12 times longer than ordinary light bulbs. Also consider selecting low energy light fittings when redecorating; contact the Lighting Association for your nearest stockist of Domestic Energy Efficient Lighting Scheme fittings.",
       "improvement_id" => "35",
       "improvement_item" => 1,
       "improvement_summary_text" => "Low energy lighting for all fixed outlets",
       "indicative_cost" => nil },
     { "certificate_number" => ni_150_sap_assessment_id,
       "improvement_descr_text" => "A solar PV system is one which converts light directly into electricity via panels placed on the roof with no waste and no emissions. This electricity is used throughout the home in the same way as the electricity purchased from an energy supplier. The British Photovoltaic Association has up-to-date information on local installers who are qualified electricians. It is best to obtain advice from a qualified electrician. Ask the electrician to explain the options.",
       "improvement_id" => "34",
       "improvement_item" => 2,
       "improvement_summary_text" => "Solar photovoltaic panels, 2.5 kWp",
       "indicative_cost" => nil }]
  end

  let(:expected_ni_150_rdsap_data) do
    [{ "certificate_number" => ni_150_rdsap_assessment_id,
       "improvement_descr_text" => "Replacement of traditional light bulbs with energy saving recommended ones will reduce lighting costs over the lifetime of the bulb, and they last up to 12 times longer than ordinary light bulbs. Also consider selecting low energy light fittings when redecorating; contact the Lighting Association for your nearest stockist of Domestic Energy Efficient Lighting Scheme fittings.",
       "improvement_id" => "35",
       "improvement_item" => 1,
       "improvement_summary_text" => "Low energy lighting for all fixed outlets",
       "indicative_cost" => "£35" },
     { "certificate_number" => ni_150_rdsap_assessment_id,
       "improvement_descr_text" => "A hot water cylinder thermostat enables the boiler to switch off when the water in the cylinder reaches the required temperature; this minimises the amount of energy that is used and lowers fuel bills. The thermostat is a temperature sensor that sends a signal to the boiler when the required temperature is reached. To be fully effective it needs to be sited in the correct position and hard wired in place, so it should be installed by a competent plumber or heating engineer.",
       "improvement_id" => "4",
       "improvement_item" => 2,
       "improvement_summary_text" => "Hot water cylinder thermostat",
       "indicative_cost" => "£200 - £400" },
     { "certificate_number" => ni_150_rdsap_assessment_id,
       "improvement_descr_text" => "A room thermostat will increase the efficiency of the heating system by enabling the boiler to switch off when no heat is required; this will reduce the amount of energy used and lower fuel bills. Thermostatic radiator valves should also be installed, to allow the temperature of each room to be controlled to suit individual needs, adding to comfort and reducing heating bills provided internal doors are kept closed. For example, they can be set to be warmer in the living room and bathroom than in the bedrooms. Ask a competent heating engineer to install thermostatic radiator valves and a fully pumped system with the pump and the boiler turned off by the room thermostat. Thermostatic radiator valves should be fitted to every radiator except for the radiator in the same room as the room thermostat. Remember the room thermostat is needed as well as the thermostatic radiator valves, to enable the boiler to switch off when no heat is required. It is best to obtain advice from a qualified heating engineer.",
       "improvement_id" => "12",
       "improvement_item" => 3,
       "improvement_summary_text" => "Upgrade heating controls",
       "indicative_cost" => "£350 - £450" },
     { "certificate_number" => ni_150_rdsap_assessment_id,
       "improvement_descr_text" => "A condensing boiler is capable of much higher efficiencies than other types of boiler, meaning it will burn less fuel to heat this property. This improvement is most appropriate when the existing central heating boiler needs repair or replacement, but there may be exceptional circumstances making this impractical. Condensing boilers need a drain for the condensate which limits their location; remember this when considering remodelling the room containing the existing boiler even if the latter is to be retained for the time being (for example a kitchen makeover). It is best to obtain advice from a qualified heating engineer. Ask the engineer to explain the options.",
       "improvement_id" => "20",
       "improvement_item" => 4,
       "improvement_summary_text" => "Replace boiler with new condensing boiler",
       "indicative_cost" => "£1,500 - £3,500" },
     { "certificate_number" => ni_150_rdsap_assessment_id,
       "improvement_descr_text" => "A solar water heating panel, usually fixed to the roof, uses the sun to pre-heat the hot water supply. This will significantly reduce the demand on the heating system to provide hot water and hence save fuel and money. The Solar Trade Association has up-to-date information on local installers.",
       "improvement_id" => "19",
       "improvement_item" => 5,
       "improvement_summary_text" => "Solar water heating",
       "indicative_cost" => "£4,000 - £6,000" },
     { "certificate_number" => ni_150_rdsap_assessment_id,
       "improvement_descr_text" => "A solar PV system is one which converts light directly into electricity via panels placed on the roof with no waste and no emissions. This electricity is used throughout the home in the same way as the electricity purchased from an energy supplier. The British Photovoltaic Association has up-to-date information on local installers who are qualified electricians. It is best to obtain advice from a qualified electrician. Ask the electrician to explain the options.",
       "improvement_id" => "34",
       "improvement_item" => 6,
       "improvement_summary_text" => "Solar photovoltaic panels, 2.5 kWp",
       "indicative_cost" => "£11,000 - £20,000" }]
  end

  let(:expected_ni_161_sap_data) do
    [{ "certificate_number" => ni_161_sap_assessment_id,
       "improvement_descr_text" => "Replacement of traditional light bulbs with energy saving recommended ones will reduce lighting costs over the lifetime of the bulb, and they last up to 12 times longer than ordinary light bulbs. Also consider selecting low energy light fittings when redecorating; contact the Lighting Association for your nearest stockist of Domestic Energy Efficient Lighting Scheme fittings.",
       "improvement_id" => "35",
       "improvement_item" => 1,
       "improvement_summary_text" => "Low energy lighting for all fixed outlets",
       "indicative_cost" => nil },
     { "certificate_number" => ni_161_sap_assessment_id,
       "improvement_descr_text" => "A solar water heating panel, usually fixed to the roof, uses the sun to pre-heat the hot water supply. This will significantly reduce the demand on the heating system to provide hot water and hence save fuel and money. The Solar Trade Association has up-to-date information on local installers.",
       "improvement_id" => "19",
       "improvement_item" => 2,
       "improvement_summary_text" => "Solar water heating",
       "indicative_cost" => nil },
     { "certificate_number" => ni_161_sap_assessment_id,
       "improvement_descr_text" => "A solar PV system is one which converts light directly into electricity via panels placed on the roof with no waste and no emissions. This electricity is used throughout the home in the same way as the electricity purchased from an energy supplier. The British Photovoltaic Association has up-to-date information on local installers who are qualified electricians. It is best to obtain advice from a qualified electrician. Ask the electrician to explain the options.",
       "improvement_id" => "34",
       "improvement_item" => 3,
       "improvement_summary_text" => "Solar photovoltaic panels, 2.5 kWp",
       "indicative_cost" => nil }]
  end

  let(:expected_ni_172_sap_data) do
    [{ "certificate_number" => ni_172_sap_assessment_id,
       "improvement_item" => 1,
       "improvement_id" => "35",
       "indicative_cost" => "£25",
       "improvement_summary_text" => "Low energy lighting for all fixed outlets",
       "improvement_descr_text" => "Replacement of traditional light bulbs with energy saving recommended ones will reduce lighting costs over the lifetime of the bulb, and they last up to 12 times longer than ordinary light bulbs. Also consider selecting low energy light fittings when redecorating; contact the Lighting Association for your nearest stockist of Domestic Energy Efficient Lighting Scheme fittings." },
     { "certificate_number" => ni_172_sap_assessment_id,
       "improvement_item" => 2,
       "improvement_id" => "19",
       "indicative_cost" => "£4,000 - £6,000",
       "improvement_summary_text" => "Solar water heating",
       "improvement_descr_text" => "A solar water heating panel, usually fixed to the roof, uses the sun to pre-heat the hot water supply. This will significantly reduce the demand on the heating system to provide hot water and hence save fuel and money. The Solar Trade Association has up-to-date information on local installers." },
     { "certificate_number" => ni_172_sap_assessment_id,
       "improvement_item" => 3,
       "improvement_id" => "34",
       "indicative_cost" => "£9,000 - £14,000",
       "improvement_summary_text" => "Solar photovoltaic panels, 2.5 kWp",
       "improvement_descr_text" => "A solar PV system is one which converts light directly into electricity via panels placed on the roof with no waste and no emissions. This electricity is used throughout the home in the same way as the electricity purchased from an energy supplier. The British Photovoltaic Association has up-to-date information on local installers who are qualified electricians. It is best to obtain advice from a qualified electrician. Ask the electrician to explain the options." }]
  end

  let(:expected_ni_173_rdsap_data) do
    [{ "certificate_number" => ni_173_rdsap_assessment_id,
       "improvement_descr_text" => "Replacement of traditional light bulbs with energy saving recommended ones will reduce lighting costs over the lifetime of the bulb, and they last up to 12 times longer than ordinary light bulbs. Also consider selecting low energy light fittings when redecorating; contact the Lighting Association for your nearest stockist of Domestic Energy Efficient Lighting Scheme fittings.",
       "improvement_id" => "35",
       "improvement_item" => 1,
       "improvement_summary_text" => "Low energy lighting for all fixed outlets",
       "indicative_cost" => "£30" },
     { "certificate_number" => ni_173_rdsap_assessment_id,
       "improvement_descr_text" => "A hot water cylinder thermostat enables the boiler to switch off when the water in the cylinder reaches the required temperature; this minimises the amount of energy that is used and lowers fuel bills. The thermostat is a temperature sensor that sends a signal to the boiler when the required temperature is reached. To be fully effective it needs to be sited in the correct position and hard wired in place, so it should be installed by a competent plumber or heating engineer.",
       "improvement_id" => "4",
       "improvement_item" => 2,
       "improvement_summary_text" => "Hot water cylinder thermostat",
       "indicative_cost" => "£200 - £400" },
     { "certificate_number" => ni_173_rdsap_assessment_id,
       "improvement_descr_text" => "The heating system controls should be improved so that both the temperature and time of heating can be set differently in separate areas of your house; this will reduce the amount of energy used and lower fuel bills. For example, it is possible to have cooler temperatures in the bedrooms than in the living room provided internal doors are kept closed, and to have a longer heating period for the living room. It is best to obtain advice from a qualified heating engineer.",
       "improvement_id" => "16",
       "improvement_item" => 3,
       "improvement_summary_text" => "Time and temperature zone control",
       "indicative_cost" => "£350 - £450" },
     { "certificate_number" => ni_173_rdsap_assessment_id,
       "improvement_item" => 4,
       "improvement_id" => "19",
       "indicative_cost" => "£4,000 - £6,000",
       "improvement_summary_text" => "Solar water heating",
       "improvement_descr_text" => "A solar water heating panel, usually fixed to the roof, uses the sun to pre-heat the hot water supply. This will significantly reduce the demand on the heating system to provide hot water and hence save fuel and money. The Solar Trade Association has up-to-date information on local installers." },
     { "certificate_number" => ni_173_rdsap_assessment_id,
       "improvement_item" => 5,
       "improvement_id" => "34",
       "indicative_cost" => "£5,000 - £8,000",
       "improvement_summary_text" => "Solar photovoltaic panels, 2.5 kWp",
       "improvement_descr_text" => "A solar PV system is one which converts light directly into electricity via panels placed on the roof with no waste and no emissions. This electricity is used throughout the home in the same way as the electricity purchased from an energy supplier. The British Photovoltaic Association has up-to-date information on local installers who are qualified electricians. It is best to obtain advice from a qualified electrician. Ask the electrician to explain the options." }]
  end

  let(:expected_ni_173_sap_data) do
    [{ "certificate_number" => ni_173_sap_assessment_id,
       "improvement_descr_text" => "A solar water heating panel, usually fixed to the roof, uses the sun to pre-heat the hot water supply. This will significantly reduce the demand on the heating system to provide hot water and hence save fuel and money. The Solar Trade Association has up-to-date information on local installers.",
       "improvement_id" => "19",
       "improvement_item" => 1,
       "improvement_summary_text" => "Solar water heating",
       "indicative_cost" => "£4,000 - £6,000" },
     { "certificate_number" => ni_173_sap_assessment_id,
       "improvement_descr_text" => "A solar PV system is one which converts light directly into electricity via panels placed on the roof with no waste and no emissions. This electricity is used throughout the home in the same way as the electricity purchased from an energy supplier. The British Photovoltaic Association has up-to-date information on local installers who are qualified electricians. It is best to obtain advice from a qualified electrician. Ask the electrician to explain the options.",
       "improvement_id" => "34",
       "improvement_item" => 2,
       "improvement_summary_text" => "Solar photovoltaic panels, 2.5 kWp",
       "indicative_cost" => "£9,000 - £14,000" }]
  end

  let(:expected_ni_180_sap_data) do
    [{ "certificate_number" => ni_180_sap_assessment_id,
       "improvement_descr_text" => "A solar water heating panel, usually fixed to the roof, uses the sun to pre-heat the hot water supply. This will significantly reduce the demand on the heating system to provide hot water and hence save fuel and money. The Solar Trade Association has up-to-date information on local installers.",
       "improvement_id" => "19",
       "improvement_item" => 1,
       "improvement_summary_text" => "Solar water heating",
       "indicative_cost" => "£4,000 - £6,000" },
     { "certificate_number" => ni_180_sap_assessment_id,
       "improvement_descr_text" => "A solar PV system is one which converts light directly into electricity via panels placed on the roof with no waste and no emissions. This electricity is used throughout the home in the same way as the electricity purchased from an energy supplier. The British Photovoltaic Association has up-to-date information on local installers who are qualified electricians. It is best to obtain advice from a qualified electrician. Ask the electrician to explain the options.",
       "improvement_id" => "34",
       "improvement_item" => 2,
       "improvement_summary_text" => "Solar photovoltaic panels, 2.5 kWp",
       "indicative_cost" => "£11,000 - £20,000" },
     { "certificate_number" => ni_180_sap_assessment_id,
       "improvement_descr_text" => "A wind turbine provides electricity from wind energy. This electricity is used throughout the home in the same way as the electricity purchased from an energy supplier. The British Wind Energy Association has up-to-date information on suppliers of small-scale wind systems. Wind turbines are not suitable for all properties. The system’s effectiveness depends on local wind speeds and the presence of nearby obstructions, and a site survey should be undertaken by an accredited installer.",
       "improvement_id" => "44",
       "improvement_item" => 3,
       "improvement_summary_text" => "Wind turbine",
       "indicative_cost" => "£1,500 - £4,000" }]
  end

  let(:expected_ni_2101_rdsap_data) do
    [{ "certificate_number" => ni_2101_rdsap_assessment_id,
       "improvement_descr_text" => "Loft insulation laid in the loft space or between roof rafters to a depth of at least 270 mm will significantly reduce heat loss through the roof; this will improve levels of comfort, reduce energy use and lower fuel bills. Insulation should not be placed below any cold water storage tank; any such tank should also be insulated on its sides and top, and there should be boarding on battens over the insulation to provide safe access between the loft hatch and the cold water tank. The insulation can be installed by professional contractors but also by a capable DIY enthusiast. Loose granules may be used instead of insulation quilt; this form of loft insulation can be blown into place and can be useful where access is difficult. The loft space must have adequate ventilation to prevent dampness; seek advice about this if unsure (particularly if installing insulation between rafters because a vapour control layer and ventilation above the insulation are required). Further information about loft insulation and details of local contractors can be obtained from the National Insulation Association (www.nationalinsulationassociation.org.uk).",
       "improvement_id" => "5",
       "improvement_item" => 1,
       "improvement_summary_text" => "Increase loft insulation to 270 mm",
       "indicative_cost" => "£100 - £350" },
     { "certificate_number" => ni_2101_rdsap_assessment_id,
       "improvement_descr_text" => "Installing an 80 mm thick cylinder jacket around the hot water cylinder will help to maintain the water at the required temperature; this will reduce the amount of energy used and lower fuel bills. A cylinder jacket is a layer of insulation that is fitted around the hot water cylinder. The jacket should be fitted over any thermostat clamped to the cylinder. Hot water pipes from the hot water cylinder should also be insulated, using pre-formed pipe insulation of up to 50 mm thickness (or to suit the space available) for as far as they can be accessed to reduce losses in summer. All these materials can be purchased from DIY stores and installed by a competent DIY enthusiast.",
       "improvement_id" => "1",
       "improvement_item" => 2,
       "improvement_summary_text" => "Insulate hot water cylinder with 80 mm jacket",
       "indicative_cost" => "2000" },
     { "certificate_number" => ni_2101_rdsap_assessment_id,
       "improvement_descr_text" => "Improvement desc",
       "improvement_id" => nil,
       "improvement_item" => 3,
       "improvement_summary_text" => "Water heating",
       "indicative_cost" => "1000" }]
  end

  before(:all) do
    import_postcode_directory_name
    import_postcode_directory_data

    config_path = "spec/config/attribute_improvements_map.json"
    config_gateway = Gateway::XsdConfigGateway.new(config_path)
    import_use_case = UseCase::ImportEnums.new(
      assessment_lookups_gateway: Gateway::AssessmentLookupsGateway.new,
      xsd_presenter: XmlPresenter::Xsd.new,
      assessment_attribute_gateway: Gateway::AssessmentAttributesGateway.new,
      xsd_config_gateway: config_gateway,
    )
    import_use_case.execute
    add_countries

    add_assessment_eav(assessment_id: "0000-0000-0000-0000-0010", schema_type: "RdSAP-Schema-21.0.1", type_of_assessment: "RdSAP", type: "epc", different_fields: {
      "postcode": "SW10 0AA", "country_id": 1
    })
    add_assessment_eav(assessment_id: "0000-0000-0000-0000-0011", schema_type: "RdSAP-Schema-20.0.0", type_of_assessment: "RdSAP", type: "epc", different_fields: {
      "postcode": "CF10 1AA", "country_id": 2
    })
    add_assessment_eav(assessment_id: "1000-0000-0000-0000-0120", schema_type: "SAP-Schema-NI-12.0", type_of_assessment: "SAP", type: "sap", different_fields: {
      "postcode": "BT10 0AA", "country_id": 3
    })
    add_assessment_eav(assessment_id: "1000-0000-0000-0000-1130", schema_type: "SAP-Schema-NI-13.0", type_of_assessment: "RdSAP", type: "rdsap", different_fields: {
      "postcode": "BT10 0AA", "country_id": 3
    })
    add_assessment_eav(assessment_id: "1000-0000-0000-0000-0130", schema_type: "SAP-Schema-NI-13.0", type_of_assessment: "SAP", type: "sap", different_fields: {
      "postcode": "BT10 0AA", "country_id": 3
    })
    add_assessment_eav(assessment_id: "1000-0000-0000-0000-1140", schema_type: "SAP-Schema-NI-14.0", type_of_assessment: "RdSAP", type: "rdsap", different_fields: {
      "postcode": "BT10 0AA", "country_id": 3
    })
    add_assessment_eav(assessment_id: "1000-0000-0000-0000-1142", schema_type: "SAP-Schema-NI-14.2", type_of_assessment: "RdSAP", type: "rdsap", different_fields: {
      "postcode": "BT10 0AA", "country_id": 3
    })
    add_assessment_eav(assessment_id: "1000-0000-0000-0000-0142", schema_type: "SAP-Schema-NI-14.2", type_of_assessment: "RdSAP", type: "sap", different_fields: {
      "postcode": "BT10 0AA", "country_id": 3
    })
    add_assessment_eav(assessment_id: "1000-0000-0000-0000-0150", schema_type: "SAP-Schema-NI-15.0", type_of_assessment: "SAP", type: "sap", different_fields: {
      "postcode": "BT10 0AA", "country_id": 3
    })
    add_assessment_eav(assessment_id: "1000-0000-0000-0000-1150", schema_type: "SAP-Schema-NI-15.0", type_of_assessment: "RdSAP", type: "rdsap", different_fields: {
      "postcode": "BT10 0AA", "country_id": 3
    })
    add_assessment_eav(assessment_id: "1000-0000-0000-0000-0172", schema_type: "SAP-Schema-NI-17.2", type_of_assessment: "SAP", type: "sap", different_fields: {
      "postcode": "BT10 0AA", "country_id": 3
    })

    add_assessment_eav(assessment_id: "1000-0000-0000-0000-1173", schema_type: "RdSAP-Schema-NI-17.3", type_of_assessment: "RdSAP", type: "epc", different_fields: {
      "postcode": "BT10 0AA", "country_id": 3
    })

    add_assessment_eav(assessment_id: "1000-0000-0000-0000-0173", schema_type: "SAP-Schema-NI-17.3", type_of_assessment: "SAP", type: "epc", different_fields: {
      "postcode": "BT10 0AA", "country_id": 3
    })

    add_assessment_eav(assessment_id: "1000-0000-0000-0000-0161", schema_type: "SAP-Schema-NI-16.1", type_of_assessment: "SAP", type: "sap", different_fields: {
      "postcode": "BT10 0AA", "country_id": 3
    })

    add_assessment_eav(assessment_id: "1000-0000-0000-0000-0180", schema_type: "SAP-Schema-NI-18.0.0", type_of_assessment: "SAP", type: "epc", different_fields: {
      "postcode": "BT10 0AA", "country_id": 3
    })

    add_assessment_eav(assessment_id: "0000-0000-0000-0000-1211", schema_type: "RdSAP-Schema-NI-21.0.1", type_of_assessment: "RdSAP", type: "epc", different_fields: {
      "postcode": "BT1 0AA", "country_id": 3
    })

    Gateway::MaterializedViewsGateway.new.refresh(name: "mvw_domestic_ni_rr_search")
  end

  it "returns the expected columns" do
    expect(mview_columns("mvw_domestic_ni_rr_search").sort.map(&:downcase)).to eq expected_columns.sort
  end

  it "returns recommendations for NI assessments only" do
    expect(certificate_numbers).to contain_exactly(ni_161_sap_assessment_id, ni_2101_rdsap_assessment_id, ni_120_sap_assessment_id, ni_130_rdsap_assessment_id, ni_130_sap_assessment_id, ni_140_rdsap_assessment_id, ni_142_rdsap_assessment_id, ni_142_sap_assessment_id, ni_150_sap_assessment_id, ni_150_rdsap_assessment_id, ni_172_sap_assessment_id, ni_173_rdsap_assessment_id, ni_173_sap_assessment_id, ni_180_sap_assessment_id)
  end

  it "does not include England or Wales assessments" do
    expect(certificate_numbers).not_to include(england_assessment_id)
    expect(certificate_numbers).not_to include(wales_assessment_id)
  end

  context "when checking exact recommendation rows for NI schema versions" do
    it "returns the expected rows for SAP-NI 12.0" do
      items = query_result.select { |i| i["certificate_number"] == ni_120_sap_assessment_id }
      expect(items).to eq expected_ni_120_sap_data
    end

    it "returns the expected rows for RdSAP-NI 13.0" do
      items = query_result.select { |i| i["certificate_number"] == ni_130_rdsap_assessment_id }
      expect(items).to eq expected_ni_130_rdsap_data
    end

    it "returns the expected rows for SAP-NI 13.0" do
      items = query_result.select { |i| i["certificate_number"] == ni_130_sap_assessment_id }
      expect(items).to eq expected_ni_130_sap_data
    end

    it "returns the expected rows for RdSAP-NI 14.0" do
      items = query_result.select { |i| i["certificate_number"] == ni_140_rdsap_assessment_id }
      expect(items).to eq expected_ni_140_rdsap_data
    end

    it "returns the expected rows for SAP-NI 14.2" do
      items = query_result.select { |i| i["certificate_number"] == ni_142_sap_assessment_id }
      expect(items).to eq expected_ni_142_sap_data
    end

    it "returns the expected rows for RdSAP-NI 14.2" do
      items = query_result.select { |i| i["certificate_number"] == ni_142_rdsap_assessment_id }
      expect(items).to eq expected_ni_142_rdsap_data
    end

    it "returns the expected rows for SAP-NI 15.0" do
      items = query_result.select { |i| i["certificate_number"] == ni_150_sap_assessment_id }
      expect(items).to eq expected_ni_150_sap_data
    end

    it "returns the expected rows for RdSAP-NI 15.0" do
      items = query_result.select { |i| i["certificate_number"] == ni_150_rdsap_assessment_id }
      expect(items).to eq expected_ni_150_rdsap_data
    end

    it "returns the expected rows for SAP-NI 16.1" do
      items = query_result.select { |i| i["certificate_number"] == ni_161_sap_assessment_id }
      expect(items).to eq expected_ni_161_sap_data
    end

    it "returns the expected rows for SAP-NI 17.2" do
      items = query_result.select { |i| i["certificate_number"] == ni_172_sap_assessment_id }
      expect(items).to eq expected_ni_172_sap_data
    end

    it "returns the expected rows for RdSAP-NI 17.3" do
      items = query_result.select { |i| i["certificate_number"] == ni_173_rdsap_assessment_id }
      expect(items).to eq expected_ni_173_rdsap_data
    end

    it "returns the expected rows for SAP-NI 17.3" do
      items = query_result.select { |i| i["certificate_number"] == ni_173_sap_assessment_id }
      expect(items).to eq expected_ni_173_sap_data
    end

    it "returns the expected rows for SAP-NI 18.0.0" do
      items = query_result.select { |i| i["certificate_number"] == ni_180_sap_assessment_id }
      expect(items).to eq expected_ni_180_sap_data
    end

    it "returns the expected rows for RdSAP-NI 21.0.1" do
      items = query_result.select { |i| i["certificate_number"] == ni_2101_rdsap_assessment_id }
      expect(items).to eq expected_ni_2101_rdsap_data
    end
  end
end
