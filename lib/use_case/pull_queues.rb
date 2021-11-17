module UseCase
  class PullQueues
    def execute
      %i[
        import_certificates
        cancel_certificates
        opt_out_certificates
      ].each { |use_case| use_case(use_case).execute }
    end
  end
end
