class DependenciesResolver
  class CircularDependencyError < RuntimeError; end

  def initialize(dependencies)
    @dependencies = dependencies.to_hash
    @stack = [ ]
    @build = [ ]
  end
  
  attr_reader :dependencies
  
  def resolve(*objects)
    @build.clear
    concat_dependencies(*objects)
    @build
  end
  
private

  def concat_dependencies(*objects)
    objects.each do |object|
      ensure_no_circular_dependency!(object)
      push(object)
      object_dependencies = Array(dependencies[object])
      concat_dependencies(*object_dependencies)
      pop
    end
  end
  
  def push(object)
    @stack.push(object)
  end
  
  def pop
    object = @stack.pop
    @build << object unless @build.include? object
  end
  
  def ensure_no_circular_dependency!(object)
    if @stack.member?(object)
      message = "Circular dependency on #{object.inspect}, dependencies stack : #{@stack.inspect}"
      @stack.clear
      raise CircularDependencyError, message
    end
  end
end
