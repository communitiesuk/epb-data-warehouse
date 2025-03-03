describe "Fix attribute duplicates rake" do
  context "when calling the rake task" do
    subject(:task) { get_task("one_off:fix_attribute_duplicates") }

    it "does something" do
      expect { task.invoke }.not_to raise_error
    end
  end
end
