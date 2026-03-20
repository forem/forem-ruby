require "test_helper"

class Forem::ForemObjectTest < Minitest::Test
  def test_dot_notation_access
    obj = Forem::ForemObject.construct_from({"id" => 1, "title" => "Hello"})
    assert_equal 1, obj.id
    assert_equal "Hello", obj.title
  end

  def test_bracket_notation_access
    obj = Forem::ForemObject.construct_from({"id" => 1, "title" => "Hello"})
    assert_equal 1, obj["id"]
    assert_equal "Hello", obj["title"]
  end

  def test_bracket_returns_nil_for_unknown_key
    obj = Forem::ForemObject.construct_from({"id" => 1})
    assert_nil obj["unknown"]
  end

  def test_respond_to_known_attributes
    obj = Forem::ForemObject.construct_from({"id" => 1, "title" => "Hello"})
    assert obj.respond_to?(:id)
    assert obj.respond_to?(:title)
    refute obj.respond_to?(:unknown_attr)
  end

  def test_to_hash
    obj = Forem::ForemObject.construct_from({"id" => 1, "title" => "Hello"})
    assert_equal({"id" => 1, "title" => "Hello"}, obj.to_hash)
  end

  def test_nested_hash_becomes_forem_object
    obj = Forem::ForemObject.construct_from({"user" => {"id" => 5, "name" => "Alice"}})
    assert_instance_of Forem::ForemObject, obj.user
    assert_equal 5, obj.user.id
    assert_equal "Alice", obj.user.name
  end

  def test_nested_array_of_hashes
    obj = Forem::ForemObject.construct_from({"tags" => [{"name" => "ruby"}, {"name" => "elixir"}]})
    assert_instance_of Array, obj.tags
    assert_instance_of Forem::ForemObject, obj.tags[0]
    assert_equal "ruby", obj.tags[0].name
  end

  def test_equality
    a = Forem::ForemObject.construct_from({"id" => 1})
    b = Forem::ForemObject.construct_from({"id" => 1})
    assert_equal a, b
  end

  def test_setter
    obj = Forem::ForemObject.construct_from({"id" => 1, "title" => "Hello"})
    obj.title = "Updated"
    assert_equal "Updated", obj.title
  end
end
