class Dependencies
  class CircularDependencyError < RuntimeError; end
  
  class << Dependencies
    def [](dependencies)
      new(dependencies)
    end
  
    def resolve(dependencies)
      new(dependencies).resolve
    end
  end

  def initialize(dependencies)
    @dependencies = dependencies.to_hash
  end
  
  def resolve(objects = nil)
    @stack, @list = [], []
    concat_dependencies(objects || @dependencies.keys)
    @list
  end

private

  def concat_dependencies(objects)
    objects.uniq.each do |object|
      next if @list.include?(object)
      raise_circular_dependency_error(object) if @stack.include?(object)
      @stack << object
      concat_dependencies(Array(@dependencies[object]))
      @list << @stack.pop
    end
  end

  def raise_circular_dependency_error(object)
    raise CircularDependencyError,
      "Circular dependency on #{object.inspect}, dependencies stack : #{@stack.inspect}"
  end
end
