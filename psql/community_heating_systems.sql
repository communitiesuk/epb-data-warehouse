SELECT
    ad.document ->> 'hashed_assessment_id' as hashed_assessment_id,
    ad.document ->> 'registration_date' as registration_date,
    community_heat_sources ->> 'heat_source_type' as heat_source_type,
    community_heat_sources ->> 'heat_fraction' as heat_fraction,
    community_heat_sources ->> 'fuel_type' as fuel_type,
    community_heat_sources ->> 'pcdf_fuel_index' as pcdf_fuel_index,
    community_heat_sources ->> 'heat_efficiency' as heat_efficiency,
    community_heat_sources ->> 'power_efficiency' as power_efficiency,
    community_heat_sources ->> 'description' as description,
    community_heat_sources ->> 'chp_electricity_generation' as chp_electricity_generation
    FROM assessment_documents ad,
    jsonb_array_elements(ad.document -> 'sap_heating' -> 'sap_community_heating_systems') sap_community_heating_systems,
    jsonb_array_elements(sap_community_heating_systems -> 'community_heat_sources') community_heat_sources
    WHERE ad.document ->> 'assessment_type' = 'SAP'
    AND ad.document ->> 'postcode' NOT LIKE 'BT%'
    AND ad.document->>'registration_date' BETWEEN '2021-01-01' AND '2024-12-31';

SELECT
   ad.document ->> 'hashed_assessment_id' as hashed_assessment_id,
   ad.document ->> 'registration_date' as registration_date,
   sap_community_heating_systems ->> 'heat_network_index_number' as heat_network_index_number,
   sap_community_heating_systems ->> 'sub_network_name' as sub_network_name,
   sap_community_heating_systems ->> 'heat_network_existing' as heat_network_existing,
   sap_community_heating_systems ->> 'community_heating_name' as community_heating_name,
   sap_community_heating_systems ->> 'community_heating_co2_emission_factor' as community_heating_co2_emission_factor,
   sap_community_heating_systems ->> 'community_heating_primary_energy_factor' as community_heating_primary_energy_factor,
   sap_community_heating_systems ->> 'community_heating_use' as community_heating_use,
   sap_community_heating_systems ->> 'is_community_heating_cylinder_in_dwelling' as is_community_heating_cylinder_in_dwelling,
   sap_community_heating_systems ->> 'is_hiu_in_dwelling' as is_hiu_in_dwelling,
   sap_community_heating_systems ->> 'hiu_index_number' as hiu_index_number,
   sap_community_heating_systems ->> 'community_heating_distribution_type' as community_heating_distribution_type,
   sap_community_heating_systems ->> 'community_heat_sources' as community_heat_sources,
   sap_community_heating_systems ->> 'community_heating_distribution_loss_factor' as community_heating_distribution_loss_factor,
   sap_community_heating_systems ->> 'charging_linked_to_heat_use' as charging_linked_to_heat_use
   FROM assessment_documents ad,
   jsonb_array_elements(ad.document -> 'sap_heating' -> 'sap_community_heating_systems') sap_community_heating_systems
   WHERE ad.document ->> 'assessment_type' = 'SAP'
   AND ad.document ->> 'postcode' NOT LIKE 'BT%'
   AND ad.document->>'registration_date' BETWEEN '2021-01-01' AND '2024-12-31';