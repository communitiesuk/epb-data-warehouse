class UseCase::ImportBase
  def save_attributes(assessment_id, certificate, parent_name = nil)
    certificate.each do |_key, _value|
      if _value.class == Hash &&
          _value.symbolize_keys.keys != %i[description value]
        save_attributes(assessment_id, _value, _key.to_s)
      else
        attribute = {
          attribute: _key.to_s,
          value: _value.class == Array ? _value.join("|") : _value,
          assessment_id: assessment_id,
          parent_name: parent_name,
        }
        save_attribute_data(attribute)
      end
    end
  end

  def save_attribute_data(attribute)
    @assessment_attribute_gateway.add_attribute_value(
      attribute[:assessment_id],
      attribute[:attribute],
      attribute[:value],
      attribute[:parent_name],
    )
  end
end
