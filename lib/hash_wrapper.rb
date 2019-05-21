class HashWrapper
  def initialize(wrapped_hash)
    @wrapped_hash = wrapped_hash
  end

  def method_missing(method_name, *args, &block)
    @wrapped_hash[method_name.to_s] if self.respond_to?(method_name) || super
  end

  def respond_to_missing?(method_name, include_private = false)
    @wrapped_hash.key?(method_name.to_s) || super
  end
end
