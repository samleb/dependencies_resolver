class Dependencies
  class CircularDependencyError < RuntimeError; end
  
  def Dependencies.[](dependencies)
    new(dependencies)
  end

  def initialize(dependencies)
    @dependencies = dependencies.to_hash
  end
  
  attr_reader :dependencies
  
  def resolve(objects = nil)
    @stack, @build = [ ], [ ]
    concat_dependencies(objects || dependencies.keys)
    @build
  end
  
private

  def concat_dependencies(objects)
    objects.uniq.each do |object|
      next if @build.include?(object)
      ensure_no_circular_dependency!(object)
      object_dependencies = Array(dependencies[object])
      stacking(object) do
        concat_dependencies(object_dependencies)
      end
    end
  end
  
  def stacking(object)
    @stack.push(object)
    yield
    @build << @stack.pop
  end
  
  def ensure_no_circular_dependency!(object)
    if @stack.member?(object)
      raise CircularDependencyError,
        "Circular dependency on #{object.inspect}, dependencies stack : #{@stack.inspect}"
    end
  end
end
