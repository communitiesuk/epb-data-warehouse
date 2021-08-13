class UseCase::ImportBase
  def save_attributes(assessment_id, certificate, parent_name = nil)
    certificate.each do |key, value|
      if value.instance_of?(Hash) &&
          value.symbolize_keys.keys != %i[description value]
        save_attributes(assessment_id, value, key.to_s)
      else

        attribute = {
          attribute: key.to_s,
          value: value.instance_of?(Array) ? value.join("|") : value,
          assessment_id: assessment_id,
          parent_name: parent_name,
        }
        save_attribute_data(attribute)
      end
    end
  end

  def save_attribute_data(attribute)
    @assessment_attribute_gateway.add_attribute_value(
      assessment_id: attribute[:assessment_id],
      attribute_name: attribute[:attribute],
      attribute_value: attribute[:value],
      parent_name: attribute[:parent_name],
    )
  end
end
