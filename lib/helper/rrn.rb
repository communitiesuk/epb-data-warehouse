# frozen_string_literal: true

module Helper
  module Rrn
    def self.format(rrn)
      rrn.tr("-", "").chars.each_slice(4).map(&:join).join("-")
    end
  end
end
