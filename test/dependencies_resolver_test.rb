require 'lib/dependencies_resolver'
require 'test/unit'

class DependenciesResolverTest < Test::Unit::TestCase
  def setup
    @resolver = DependenciesResolver.new(dependencies)
  end
  
  def test_build_should_include_wanted_objects
    assert_equal [:f], @resolver.resolve(:f)
    assert_equal [:d], @resolver.resolve(:d)
  end
  
  def test_build_should_include_dependencies
    assert_equal [:e, :f, :b], @resolver.resolve(:b)
  end
  
  def test_should_accept_multiple_objects
    assert_nothing_raised { @resolver.resolve(:a, :b) }
  end
  
  def test_build_should_contain_unique_objects
    assert_equal [:f], @resolver.resolve(:f, :f)
    assert_equal [:e, :f, :b, :c], @resolver.resolve(:b, :c)
  end
  
  def test_should_raise_on_circular_dependency
    assert_raise(DependenciesResolver::CircularDependencyError) do
      DependenciesResolver.new(:a => :b, :b => :a).resolve(:a)
    end
  end
  
  def dependencies
    {
      :a => [:b, :c, :d],
      :b => [:e, :f],
      :c => [:e],
      :f => nil 
    }
  end
end
