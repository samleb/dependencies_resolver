require 'lib/dependencies'
require 'test/unit'

class DependenciesTest < Test::Unit::TestCase
  def setup
    @resolver = Dependencies[
      :a => [:b, :c, :d],
      :b => :d,
      :c => :e
    ]
  end
  
  def test_build_should_include_wanted_objects
    assert_equal [:f], @resolver.resolve([:f])
    assert_equal [:d], @resolver.resolve([:d])
  end
  
  def test_build_should_include_dependencies
    assert_equal [:d, :b], @resolver.resolve([:b])
  end
  
  def test_build_should_contain_unique_objects
    assert_equal [:f], @resolver.resolve([:f, :f])
    assert_equal [:d, :b, :e, :c], @resolver.resolve([:b, :c])
  end
  
  def test_should_raise_on_circular_dependency
    assert_raise(Dependencies::CircularDependencyError) do
      Dependencies.resolve(:a => :b, :b => :a)
    end
  end
  
  def test_should_fully_resolve_with_no_argument
    assert_equal [:d, :b, :e, :c, :a], @resolver.resolve
  end
end
