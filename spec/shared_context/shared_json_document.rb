shared_context "when exporting json data" do
  def redacted_keys
    %w[scheme_assessor_id equipment_operator equipment_owner owner occupier cancelled_at hashed_assessment_id opt_out]
  end
end
