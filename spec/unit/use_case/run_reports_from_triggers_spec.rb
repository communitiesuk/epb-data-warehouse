# frozen_string_literal: true

describe UseCase::RunReportsFromTriggers do
  subject(:usecase) { described_class.new(report_triggers_gateway:, report_use_cases:, logger:) }

  let(:logger) do
    logger = instance_double(Logger)
    allow(logger).to receive(:error)
    logger
  end

  let(:report_triggers_gateway) { instance_double(Gateway::ReportTriggersGateway) }

  let(:report_use_cases) do
    {
      how_many_splines: spline_use_case,
      how_many_widgets: widget_use_case,
    }
  end

  let(:spline_use_case) do
    use_case = double Object # rubocop:disable RSpec/VerifiedDoubles
    allow(use_case).to receive(:execute)
    use_case
  end

  let(:widget_use_case) do
    use_case = double Object # rubocop:disable RSpec/VerifiedDoubles
    allow(use_case).to receive(:execute)
    use_case
  end

  before do
    allow(report_triggers_gateway).to receive(:triggers).and_return([])
    allow(report_triggers_gateway).to receive(:remove_trigger)
  end

  context "when invoking the use case with no triggers" do
    it "calls the report triggers gateway" do
      usecase.execute
      expect(report_triggers_gateway).to have_received(:triggers)
    end

    it "would not call any use cases" do
      usecase.execute
      expect(spline_use_case).not_to have_received(:execute)
      expect(widget_use_case).not_to have_received(:execute)
      expect(report_triggers_gateway).not_to have_received(:remove_trigger)
    end
  end

  context "when invoking the use case with triggers" do
    before do
      allow(report_triggers_gateway).to receive(:triggers).and_return(%i[how_many_splines how_many_widgets])
      usecase.execute
    end

    it "calls the use cases" do
      expect(spline_use_case).to have_received(:execute)
      expect(widget_use_case).to have_received(:execute)
    end

    it "calls the method to remove the trigger" do
      count = 0
      expect(report_triggers_gateway).to have_received(:remove_trigger).twice do |arg|
        expect(arg).to eq(%i[how_many_splines how_many_widgets][count])
        count += 1
      end
    end
  end

  context "when a use case execution fails" do
    subject(:erroring_usecase) do
      described_class.new(
        report_triggers_gateway:,
        report_use_cases: {
          how_many_splines: spline_bad_use_case,
          how_many_widgets: widget_use_case,
        },
        logger:,
      )
    end

    let(:spline_bad_use_case) do
      use_case = double Object # rubocop:disable RSpec/VerifiedDoubles
      allow(use_case).to receive(:execute).and_raise "bang!"
      use_case
    end

    before do
      allow(report_triggers_gateway).to receive(:triggers).and_return(%i[how_many_splines how_many_widgets])
    end

    it "logs one error" do
      expect { erroring_usecase.execute }.not_to raise_error
      expect(logger).to have_received(:error).once
    end
  end
end
