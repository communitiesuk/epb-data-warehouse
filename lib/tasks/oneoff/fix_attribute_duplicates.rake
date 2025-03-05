namespace :one_off do
  desc "Apply fix to remove attributes and re-assign attribute values"
  task :fix_attribute_duplicates do
    begin
      num_dupes = Container.fix_attribute_duplicates_use_case.execute
    rescue Boundary::NoData => e
      raise e
    end

    puts "There were #{num_dupes} duplicated attributes fixed"
  end
end
