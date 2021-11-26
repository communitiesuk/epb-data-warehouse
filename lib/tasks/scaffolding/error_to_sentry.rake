namespace :scaffolding do
  desc "Generate an error and immediately send it to Sentry to check connectivity"
  task :error_to_sentry, [:message] do |_, args|
    message = args[:message]
    begin
      raise message
    rescue StandardError => e
      report_to_sentry e
      puts "Reported error!"
    end
  end
end
