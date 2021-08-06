describe Gateway::RedisGateway do
  let(:gateway) { described_class.new }

  describe ".fetch_queue" do
    context "when processing simple string objects" do
      before do
        gateway.redis.set "assessments", "0000-0000-0000-0000-0000"
      end

      it "can fetch a single assessment id" do
        expect(gateway.fetch_queue("assessments")).to eq("0000-0000-0000-0000-0000")
      end
    end

    context "when processing complex objects" do
      before do
        gateway.redis.set "assessments", %w[0000-0000-0000-0000-0000].to_json
      end

      it "can fetch a single assessment id as an array" do
        expect(gateway.fetch_queue("assessments")).to eq(%w[0000-0000-0000-0000-0000])
      end
    end

    context "when can store complex data of many queues" do
      let(:queues) do
        { assessments: %w[5555-0000-0000-0000-0000 5555-0000-0000-0000-0001],
          opt_outs: %w[9999-0000-0000-0000-5444 9999-0000-0000-0000-4444] }
      end

      before do
        gateway.redis.flushall
        gateway.redis.set("queues", queues.to_json)
      end

      it "can fetch a single assessment id as an array" do
        expect(gateway.fetch_queue("queues", "assessments")).to eq(%w[5555-0000-0000-0000-0000 5555-0000-0000-0000-0001])
      end
    end
  end

  describe ".update_queue" do
    context "when can store complex data of many queues" do
      let(:queues) do
        { assessments: %w[5555-0000-0000-0000-0000 5555-0000-0000-0000-0001],
          opt_outs: %w[9999-0000-0000-0000-5444 9999-0000-0000-0000-4444] }
      end

      before do
        gateway.redis.flushall
        gateway.redis.set("queues", queues.to_json)
      end

      it "updates the queue values" do
        expect(gateway.fetch_queue("queues", "assessments")).to eq(%w[5555-0000-0000-0000-0000 5555-0000-0000-0000-0001])
        gateway.remove_from_queue(
          assessment_id: "5555-0000-0000-0000-0000",
          queue: "queues",
          child_queue: "assessments",
        )

        expect(gateway.fetch_queue("queues", "assessments")).to eq(%w[5555-0000-0000-0000-0001])
      end
    end
  end
end
