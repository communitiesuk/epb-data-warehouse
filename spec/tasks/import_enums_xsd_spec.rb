describe "ImportEnumsXsd Rake" do
  subject(:task) { get_task("import_enums_xsd") }

  context "when the import task runs with the test config" do
    before do
      allow($stdout).to receive(:puts)
      allow($stdout).to receive(:write)
    end


    it "runs the task without raising any errors" do
      expect { task.invoke }.not_to raise_error
    end
  end
end
