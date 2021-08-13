require "zeitwerk"
class TestLoader
  def self.setup
    @loader = Zeitwerk::Loader.new
    @loader.push_dir("#{__dir__}/../lib/helper", namespace: Helper)
    @loader.push_dir("#{__dir__}/../lib")
    @loader.push_dir("#{__dir__}/../spec/test_doubles")
    @loader.setup
  end

  def self.override(path)
    load path
  end
end
TestLoader.setup
