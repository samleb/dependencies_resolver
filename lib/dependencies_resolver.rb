class DependenciesResolver
  class CircularDependencyError < RuntimeError; end

  def initialize(dependencies)
    @dependencies = dependencies.to_hash
    @stack = [ ]
    @build = [ ]
  end
  
  attr_reader :dependencies
  
  def resolve(*objects)
    @stack.clear
    @build.clear
    concat_dependencies(*objects)
    @build.dup
  end
  
private

  def concat_dependencies(*objects)
    objects.each do |object|
      ensure_no_circular_dependency!(object)
      object_dependencies = Array(dependencies[object])
      stacking(object) do
        concat_dependencies(*object_dependencies)
      end
    end
  end
  
  def stacking(object)
    @stack.push(object)
    yield
    object = @stack.pop
    @build << object unless @build.include? object
  end
  
  def ensure_no_circular_dependency!(object)
    if @stack.member?(object)
      raise CircularDependencyError,
        "Circular dependency on #{object.inspect}, dependencies stack : #{@stack.inspect}"
    end
  end
end
