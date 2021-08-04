describe "redis queue mainipulation" do
  context "start redis servive and manipulate " do
    let!(:redis) { Redis.new }

    it "can start the redis service" do
      expect { redis }.not_to raise_error
    end

    it "can store a single assessment id " do
      redis.set "asssessmets", "0000-0000-0000-0000-0000"
      expect(redis.get("asssessmets")).to eq("0000-0000-0000-0000-0000")
    end

    context "it persists data across requests" do
      before do
        redis.set "asssessmets", %w[0000-0000-0000-0000-0000].to_json
      end

      it "the existing key's value is incremented to have an array of 2 values" do
        new_value = JSON.parse(redis.get("asssessmets")) << "0000-0000-0000-0000-0001"
        redis.set "asssessmets", new_value.to_json

        expect(JSON.parse(redis.get("asssessmets"))).to eq(%w[0000-0000-0000-0000-0000 0000-0000-0000-0000-0001])
      end
    end

    context "when can store complex data of many queues" do
      let(:queues) do
        { asssessmets: %w[5555-0000-0000-0000-0000 5555-0000-0000-0000-0001],
          opt_outs: %w[9999-0000-0000-0000-5444 9999-0000-0000-0000-4444] }
      end

      it "can store hash convert to a json string" do
        redis.flushall
        expect(redis.set("queues", queues.to_json)).to eq("OK")
      end

      it "get the first id in opt outs" do
        hash = JSON.parse(redis.get("queues"))
        expect(hash["opt_outs"].first).to eq("9999-0000-0000-0000-5444")
      end
    end
  end
end
