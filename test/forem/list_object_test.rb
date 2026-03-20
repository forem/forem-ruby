require "test_helper"

class Forem::ListObjectTest < Minitest::Test
  def test_data_access
    list = Forem::ListObject.new(
      data: [Forem::ForemObject.construct_from({"id" => 1})],
      current_page: 1, per_page: 30,
      resource_class: Forem::ForemObject, filters: {}, requestor: nil
    )
    assert_equal 1, list.data.length
    assert_equal 1, list.data[0].id
  end

  def test_has_more_true_when_full_page
    items = Array.new(30) { |i| Forem::ForemObject.construct_from({"id" => i}) }
    list = Forem::ListObject.new(
      data: items, current_page: 1, per_page: 30,
      resource_class: Forem::ForemObject, filters: {}, requestor: nil
    )
    assert list.has_more?
  end

  def test_has_more_false_when_partial_page
    items = Array.new(10) { |i| Forem::ForemObject.construct_from({"id" => i}) }
    list = Forem::ListObject.new(
      data: items, current_page: 1, per_page: 30,
      resource_class: Forem::ForemObject, filters: {}, requestor: nil
    )
    refute list.has_more?
  end

  def test_has_more_false_when_empty
    list = Forem::ListObject.new(
      data: [], current_page: 1, per_page: 30,
      resource_class: Forem::ForemObject, filters: {}, requestor: nil
    )
    refute list.has_more?
  end

  def test_each_iterates_current_page
    items = [Forem::ForemObject.construct_from({"id" => 1}), Forem::ForemObject.construct_from({"id" => 2})]
    list = Forem::ListObject.new(
      data: items, current_page: 1, per_page: 30,
      resource_class: Forem::ForemObject, filters: {}, requestor: nil
    )
    ids = []
    list.each { |item| ids << item.id }
    assert_equal [1, 2], ids
  end

  def test_current_page
    list = Forem::ListObject.new(
      data: [], current_page: 3, per_page: 30,
      resource_class: Forem::ForemObject, filters: {}, requestor: nil
    )
    assert_equal 3, list.current_page
  end
end
