package github.test.utils

import future.keywords.in

test_error {
  data.github.utils.is_error({"processing_error": true})
}

test_not_error {
  not data.github.utils.is_error({"not_processing_error": true})
}

arr1 := [ 1, 2, 3 ]
arr2 := [ 1, 4, 5 ]

test_array_intersection {
  data.github.utils.array_intersection(arr1, arr2) == [1]
}

obj1 := { 1: ["a", "b", "c"] }
obj2 := { 1: ["a", "d", "e"] }

test_array_intersection_in_object {
  data.github.utils.array_intersection(obj1[x], obj2[x]) == ["a"]
}

resp1 := { 1: [{ "field1": "value1", "field2": "value2" }] }
nested_resp1 := [{ "field1": "value1", "field2": "value2" },
  {"field1": "value3"}]

#test_object_filter {
#  q := object.filter(nested_resp1[_], {"field1"})
#  print(q)
#  object.filter(nested_resp1[_], {"field1"}) == ["value"]
#}

test_flatten_array {
  data.github.utils.flatten_array(nested_resp1, "field1") == ["value1", "value3"]
}

# test_nested_flatten_array {
#   some x in resp1
#   a[x] = data.github.utils.flatten_array(resp1[x], "field1")
#   a[1] == ["value1", "value3"]
# }

add_one(x) = v {
  v := x + 1
}

# test_apply_func {
#   [2, 3, 4] == data.github.utils.apply_func([1, 2, 3], add_one)
# }

test_array_subtraction {
  data.github.utils.array_subtraction([1,2,3], [1]) == [2,3]
}

test_array_subtraction_no_intersection {
  data.github.utils.array_subtraction([1,2,3], [0]) == [1,2,3]
}

test_object_subtraction {
  data.github.utils.object_subtraction({1: 2}, {2: 3}) == {1: 2}
  data.github.utils.object_subtraction({1: 2}, {1: 1}) == {1: 1}
}

test_state_diff {
#  data.github.utils.state_diff({1: {"a": [1, 2]}, 2: {"a": [3, 4]} },
#    "a", {1: {"a": [2]}}) == {1: {"a": [1]}, 2: {"a": [3, 4]}}
  data.github.utils.state_diff({"a": [1, 2]}, "a",
    {"a": [2]}) == {"a": [1]}
}