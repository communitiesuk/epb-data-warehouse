module Services
  class ServiceNotFound < ArgumentError; end

  def self.use_case(name)
    find_on_container name, type: :use_case
  end

  def self.gateway(name)
    find_on_container name, type: :gateway
  end

  def self.find_on_container(name, type:)
    Container.send [name, type].join("_").to_sym
  rescue NoMethodError
    raise ServiceNotFound, "unable to find a #{type} with the name '#{name}'"
  end

  private_class_method :find_on_container
end
