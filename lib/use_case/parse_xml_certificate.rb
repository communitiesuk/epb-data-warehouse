require "parallel"

module UseCase
  class ParseXmlCertificate
    def execute(xml:, schema_type:, assessment_id:, use_subprocess: true)
      configuration_class = export_configuration(schema_type)
      return if configuration_class.nil?

      parse = lambda {
        export_config = configuration_class.new
        parser = XmlPresenter::Parser.new(**export_config.to_args(sub_node_value: assessment_id))
        Helper::Stopwatch.log_elapsed_time @logger, "parsed XML for assessment #{assessment_id}" do
          parser.parse(xml)
        end
      }

      if use_subprocess
        Parallel.map([0]) { |_|
          parse.call
        }.first
      else
        parse.call
      end
    end

  private

    def export_configuration(schema_type)
      export_config_file = {
        "RdSAP-Schema-20.0.0" => XmlPresenter::Rdsap::Rdsap20ExportConfiguration,
        "RdSAP-Schema-19.0" => XmlPresenter::Rdsap::Rdsap19ExportConfiguration,
        "RdSAP-Schema-NI-20.0.0" => XmlPresenter::Rdsap::Rdsap20NiExportConfiguration,
        "RdSAP-Schema-NI-19.0" => XmlPresenter::Rdsap::Rdsap19NiExportConfiguration,
        "RdSAP-Schema-18.0" => XmlPresenter::Rdsap::Rdsap18ExportConfiguration,
        "SAP-Schema-18.0.0" => XmlPresenter::Sap::Sap1800ExportConfiguration,
        "SAP-Schema-17.1" => XmlPresenter::Sap::Sap1800ExportConfiguration,
        "SAP-Schema-NI-18.0.0" => XmlPresenter::Sap::Sap1800NiExportConfiguration,
        "SAP-Schema-NI-17.4" => XmlPresenter::Sap::Sap174NiExportConfiguration,
        "SAP-Schema-NI-17.3" => XmlPresenter::Sap::Sap173NiExportConfiguration,
        "CEPC-8.0.0" => XmlPresenter::Cepc::Cepc800ExportConfiguration,
        "CEPC-7.1" => XmlPresenter::Cepc::Cepc71ExportConfiguration,
        "CEPC-NI-8.0.0" => XmlPresenter::Cepc::Cepc800NiExportConfiguration,
      }
      export_config_file[schema_type]
    end
  end
end
