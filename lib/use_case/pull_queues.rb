module UseCase
  class PullQueues
    def execute(from_recovery_list: false)
      %i[
        import_certificates
        cancel_certificates
        opt_out_certificates
        update_certificate_addresses
        update_certificate_matched_addresses
        backfill_update_certificate_matched_addresses
      ].each { |use_case| use_case(use_case).execute(from_recovery_list:) }
    end
  end
end
