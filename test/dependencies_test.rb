require 'lib/dependencies'
require 'test/unit'

class DependenciesTest < Test::Unit::TestCase
  def setup
    @resolver = Dependencies[dependencies]
  end
  
  def test_build_should_include_wanted_objects
    assert_equal [:f], @resolver.resolve([:f])
    assert_equal [:d], @resolver.resolve([:d])
  end
  
  def test_build_should_include_dependencies
    assert_equal [:e, :f, :b], @resolver.resolve([:b])
  end
  
  def test_build_should_contain_unique_objects
    assert_equal [:f], @resolver.resolve([:f, :f])
    assert_equal [:e, :f, :b, :d, :c], @resolver.resolve([:b, :c])
  end
  
  def test_should_raise_on_circular_dependency
    assert_raise(Dependencies::CircularDependencyError) do
      Dependencies[:a => :b, :b => :a].resolve([:a])
    end
  end
  
  def test_should_fully_resolve_with_no_argument
    assert_equal [:e, :f, :b, :d, :c, :a], @resolver.resolve
  end
  
  def dependencies
    {
      :a => [:b, :c, :d],
      :b => [:e, :f],
      :c => [:e, :d],
      :f => nil
    }
  end
end
