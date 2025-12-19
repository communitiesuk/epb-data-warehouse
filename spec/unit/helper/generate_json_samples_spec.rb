describe Helper::GenerateJsonSamples do
  describe "#parse_assessment" do
    let(:expected_json) do
      {
        "addendum" => { "addendumNumbers" => [1, 8], "stoneWalls" => "true", "systemBuild" => "true" },
        "addressLine1" => "1 Some Street",
        "assessmentType" => "RdSAP",
        "builtForm" => 2,
        "calculationSoftwareVersion" => "13.05r16",
        "co2EmissionsCurrent" => 2.4,
        "co2EmissionsCurrentPerFloorArea" => 20,
        "co2EmissionsPotential" => 1.4,
        "completionDate" => "2020-05-04",
        "conservatoryType" => 1,
        "countryCode" => "EAW",
        "currentEnergyEfficiencyBand" => "E",
        "doorCount" => 2,
        "dwellingType" => "Mid-terrace house",
        "energyConsumptionCurrent" => 230,
        "energyConsumptionPotential" => 88,
        "energyRatingAverage" => 60,
        "energyRatingCurrent" => 50,
        "energyRatingPotential" => 72,
        "environmentalImpactCurrent" => 52,
        "environmentalImpactPotential" => 74,
        "extensionsCount" => 0,
        "fixedLightingOutletsCount" => 16,
        "floors" => [{ "description" => "Suspended, no insulation (assumed)", "energyEfficiencyRating" => 0, "environmentalEfficiencyRating" => 0 }, { "description" => "Solid, insulated (assumed)", "energyEfficiencyRating" => 0, "environmentalEfficiencyRating" => 0 }],
        "glazedArea" => 1,
        "habitableRoomCount" => 5,
        "heatedRoomCount" => 5,
        "heatingCostCurrent" => 365.98,
        "heatingCostPotential" => 250.34,
        "hotWater" => { "description" => "From main system", "energyEfficiencyRating" => 4, "environmentalEfficiencyRating" => 4 },
        "hotWaterCostCurrent" => 200.4,
        "hotWaterCostPotential" => 180.43,
        "inspectionDate" => "2020-05-04",
        "insulatedDoorCount" => 2,
        "insulatedDoorUValue" => 3,
        "languageCode" => 1,
        "lighting" => { "description" => "Low energy lighting in 50% of fixed outlets", "energyEfficiencyRating" => 4, "environmentalEfficiencyRating" => 4 },
        "lightingCostCurrent" => 123.45,
        "lightingCostPotential" => 84.23,
        "lowEnergyFixedLightingOutletsCount" => 16,
        "lowEnergyLighting" => 100,
        "lzcEnergySources" => [11],
        "mainHeating" => [{ "description" => "Boiler and radiators, anthracite", "energyEfficiencyRating" => 3, "environmentalEfficiencyRating" => 1 }, { "description" => "Boiler and radiators, mains gas", "energyEfficiencyRating" => 4, "environmentalEfficiencyRating" => 4 }],
        "mainHeatingControls" => [{ "description" => "Programmer, room thermostat and TRVs", "energyEfficiencyRating" => 4, "environmentalEfficiencyRating" => 4 }, { "description" => "Time and temperature zone control", "energyEfficiencyRating" => 5, "environmentalEfficiencyRating" => 5 }],
        "measurementType" => 1,
        "mechanicalVentilation" => 0,
        "multipleGlazedProportion" => 100,
        "multipleGlazedProportionNr" => "NR",
        "multipleGlazingType" => 2,
        "openFireplacesCount" => 0,
        "percentDraughtproofed" => 100,
        "postTown" => "Whitbury",
        "postcode" => "A0 0AA",
        "propertyType" => 0,
        "regionCode" => 1,
        "registrationDate" => "2020-05-04",
        "renewableHeatIncentive" => { "impactOfCavityInsulation" => -122, "impactOfLoftInsulation" => -2114, "impactOfSolidWallInsulation" => -3560, "spaceHeatingExistingDwelling" => 13_120, "waterHeating" => 2285 },
        "reportType" => 2,
        "roofs" => [{ "description" => "Pitched, 25 mm loft insulation", "energyEfficiencyRating" => 2, "environmentalEfficiencyRating" => 2 }, { "description" => "Pitched, 250 mm loft insulation", "energyEfficiencyRating" => 4, "environmentalEfficiencyRating" => 4 }],
        "sapBuildingParts" => [{ "buildingPartNumber" => 1, "constructionAgeBand" => "K", "floorHeatLoss" => 7, "floorInsulationThickness" => "NI", "identifier" => "Main Dwelling", "partyWallConstruction" => 0, "roofConstruction" => 4, "roofInsulationLocation" => 2, "roofInsulationThickness" => "200mm", "sapFloorDimensions" => [{ "floor" => 0, "floorConstruction" => 1, "floorInsulation" => 1, "heatLossPerimeter" => { "quantity" => "metres", "value" => 19.5 }, "partyWallLength" => { "quantity" => "metres", "value" => 7.9 }, "roomHeight" => { "quantity" => "metres", "value" => 2.45 }, "totalFloorArea" => { "quantity" => "square metres", "value" => 45.82 } }, { "floor" => 1, "heatLossPerimeter" => { "quantity" => "metres", "value" => 19.5 }, "partyWallLength" => { "quantity" => "metres", "value" => 7.9 }, "roomHeight" => { "quantity" => "metres", "value" => 2.59 }, "totalFloorArea" => { "quantity" => "square metres", "value" => 45.82 } }], "sapRoomInRoof" => { "constructionAgeBand" => "B", "floorArea" => 100, "insulation" => "AB", "roofRoomConnected" => "N" }, "wallConstruction" => 4, "wallDryLined" => "N", "wallInsulationThickness" => "NI", "wallInsulationType" => 2, "wallThicknessMeasured" => "N" }],
        "sapEnergySource" => { "mainsGas" => "Y", "meterType" => 2, "photovoltaicSupply" => { "noneOrNoDetails" => { "percentRoofArea" => 50, "pvConnection" => 0 } }, "windTurbinesCount" => 0, "windTurbinesTerrainType" => 2 },
        "sapFlatDetails" => { "flatLocation" => 1, "heatLossCorridor" => 2, "level" => 1, "storeyCount" => 3, "topStorey" => "N", "unheatedCorridorLength" => 10 },
        "sapHeating" => { "cylinderSize" => 1, "hasFixedAirConditioning" => "false", "immersionHeatingType" => "NA", "instantaneousWwhrs" => { "roomsWithBathAndMixerShower" => 0, "roomsWithBathAndOrShower" => 1, "roomsWithMixerShowerNoBath" => 0 }, "mainHeatingDetails" => [{ "boilerFlueType" => 2, "centralHeatingPumpAge" => 0, "emitterTemperature" => 0, "fanFluePresent" => "N", "hasFghrs" => "N", "heatEmitterType" => 1, "mainFuelType" => 26, "mainHeatingCategory" => 2, "mainHeatingControl" => 2106, "mainHeatingDataSource" => 1, "mainHeatingFraction" => 1, "mainHeatingIndexNumber" => 17_507, "mainHeatingNumber" => 1, "sapMainHeatingCode" => 101 }], "secondaryFuelType" => 25, "waterHeatingCode" => 901, "waterHeatingFuel" => 26 },
        "sapVersion" => 9.8,
        "sapWindows" => [{ "glazingType" => 1, "orientation" => 1, "windowArea" => 200.1, "windowLocation" => 0, "windowType" => 2 }, { "glazingType" => 2, "orientation" => 2, "windowArea" => 180.2, "windowLocation" => 1, "windowType" => 1 }],
        "schemaType" => "RdSAP-Schema-20.0.0",
        "schemaVersionOriginal" => "SAP-19.0",
        "secondaryHeating" => { "description" => "Room heaters, electric", "energyEfficiencyRating" => 0, "environmentalEfficiencyRating" => 0 },
        "solarWaterHeating" => "N",
        "status" => "entered",
        "suggestedImprovements" => [{ "energyPerformanceRating" => 50, "environmentalImpactRating" => 50, "improvementCategory" => 6, "improvementDetails" => { "improvementNumber" => 5 }, "improvementType" => "Z3", "indicativeCost" => "£100 - £350", "sequence" => 1, "typicalSaving" => 360 }, { "energyPerformanceRating" => 60, "environmentalImpactRating" => 64, "improvementCategory" => 2, "improvementDetails" => { "improvementNumber" => 1 }, "improvementType" => "Z2", "indicativeCost" => 2000, "sequence" => 2, "typicalSaving" => 99 }, { "energyPerformanceRating" => 60, "environmentalImpactRating" => 64, "improvementCategory" => 2, "improvementDetails" => { "improvementTexts" => { "improvementDescription" => "An improvement desc", "improvementSummary" => "An improvement summary" } }, "improvementType" => "Z2", "indicativeCost" => 1000, "sequence" => 3, "typicalSaving" => 99 }],
        "tenure" => 1,
        "totalFloorArea" => 55,
        "transactionType" => 1,
        "uprn" => 12_457,
        "walls" => [{ "description" => "Solid brick, as built, no insulation (assumed)", "energyEfficiencyRating" => 1, "environmentalEfficiencyRating" => 1 }, { "description" => "Cavity wall, as built, insulated (assumed)", "energyEfficiencyRating" => 4, "environmentalEfficiencyRating" => 4 }],
        "window" => { "description" => "Fully double glazed", "energyEfficiencyRating" => 3, "environmentalEfficiencyRating" => 3 },
        "windowsTransmissionDetails" => { "dataSource" => 2, "solarTransmittance" => 0.72, "uValue" => 2 },

      }
    end

    it "returns a redacted document with camel case keys" do
      schema_type = "RdSAP-Schema-20.0.0"
      type = "epc"
      xml = Nokogiri.XML Samples.xml(schema_type, type)
      assessment_id = described_class.get_rrn(xml:, type:, schema_type:)
      json = described_class.parse_assessment(xml:, assessment_id:, schema_type:, type:)
      expect(json).to eq expected_json
    end
  end

  describe "#get_sample_files" do
    let(:output_dir) do
      "#{Dir.pwd}/spec/fixtures/samples/"
    end

    let(:sample_files) do
      described_class.get_sample_files
    end

    it "returns all the expected sample files" do
      expect(sample_files.length).to eq 36
    end

    it "files are being generated from the relevant xml samples" do
      expect(sample_files).to include(/\/spec\/fixtures\/samples/)
    end

    %w[cepc cepc-rr dec dec-rr epc rdsap sap].each do |i|
      it "files are being generated from the relevant xml #{i} sample" do
        expect(sample_files).to include a_string_matching(/#{i}/)
      end
    end

    %w[ac-cert redacted dec_exceeds 15 NI].each do |i|
      it "files do not return an anything that contains #{i}" do
        expect(sample_files).not_to include a_string_matching(/#{i}/)
      end
    end
  end
end
