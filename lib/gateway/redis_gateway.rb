# frozen_string_literal: true

module Gateway
  class RedisGateway
    attr_reader :redis

    def initialize
      @redis = Redis.new
    end

    def fetch_queue(queue, child_queue_name = nil)
      parent_queue_value = @redis.get(queue)

      begin
        parsed_value = JSON.parse(parent_queue_value)

        return parsed_value if child_queue_name.nil?

        parsed_value.dig(child_queue_name)
      rescue StandardError
        parent_queue_value
      end
    end

    def remove_from_queue(assessment_id:, queue:, child_queue: nil)
      assessment_ids = fetch_queue(queue, child_queue)
      assessment_ids.delete(assessment_id)

      parent_queue_hash = fetch_queue(queue).symbolize_keys
      parent_queue_hash[child_queue.to_sym] = assessment_ids unless child_queue.nil?

      @redis.set(queue, parent_queue_hash.to_json)
    end
  end
end
