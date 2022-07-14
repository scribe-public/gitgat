package github.utils

import future.keywords.in

exists(obj, k) {
  _ = obj[k]
}

pick(k, obj1, obj2) = v {
  v := obj1[k]
}

pick(k, obj1, obj2) = v {
  not exists(obj1, k)
  v := obj2[k]
}

merge(a, b) = c {
  keys := {k | _ = a[k]} | {k | _ = b[k]}
  c := {k: v | k := keys[_]; v := pick(k, b, a)}
}

okay(response) {
  response.status_code == 200
}

error(response) {
  response.status_code == 0
}

not_okay(response) {
  response.status_code != 0
  response.status_code != 200
}

parse(response) = v {
  okay(response)
  v := response.body
}

parse(response) = v {
  error(response)
  v := {"processing_error": response.error}
}

parse(response) = v {
  not_okay(response)
  v := {"processing_error": sprintf("%s: %s", [response.status, response.body.message])}
}

error_substitute(response, substitutes) = v {
  is_error(response)
  v := { "processing_error": substitutes[response.processing_error] }
}

error_substitute(response, substitutes) = v {
  is_error(response)
  not exists(substitutes, response.processing_error)
  v := response
}

error_substitute(response, substitutes) = v {
  not is_error(response)
  v := response
}

is_okay(v) {
  not is_error(v)
}

is_error(v) {
  exists(v, "processing_error")
}

keys(o) = v {
  v := [ x | o[x] ]
}

array_intersection(arr_a, arr_b) = v {
  v_set := { a | a := arr_a[_] } & { b | b := arr_b[_] }
  v := [ x | v_set[x] ]
}

array_subtraction(arr_a, arr_b) = v {
  v_set := { a | a := arr_a[_] } - { b | b := arr_b[_] }
  v := [ x | v_set[x] ]
}

is_expired(key, expiration) {
  year := expiration[0]
  month := expiration[1]
  day := expiration[2]

  expired := time.add_date(time.parse_rfc3339_ns(key.created_at), year, month, day)
  expired < time.now_ns()
}

# { key1: [ val1, val2 ], key2: [ val3 ] } -
# { key1: [ val1 ] } =
# { key1: [ val2 ], key2: [ val3 ] }
object_subtraction( obj1, obj2 ) = v {
  keys_only_first := {k | _ = obj1[k]} - {k | _ = obj2[k]}
  v_only_first := { k: v | some k in keys_only_first; v := obj1[k] }

  keys_both := {k | _ = obj1[k]} & {k | _ = obj2[k]}
  v_both := { k: v | some k in keys_both; v := obj1[k] - obj2[k] }
  v := merge(v_only_first, v_both)
}

# array_of_objects = [{field1: value1, field: value}] -> [value]
flatten_array(array_of_objects, field) = [ v |
  obj := array_of_objects[_]
  v := obj[field]
]

# object = { field1: { field2: value1 } -> { field1: value1 }
# extract_field(object, field) = [

# flatten_array = apply json.filter
# flatten_array(array_of_objects, field) = mapped {
#   mapped := [ json.filter(x) | x = array_of_objects[_] ]
# }

# apply_func(array_of_objects, func) = mapped {
#   mapped := [ func(x) | x = array_of_objects[_] ]
# }


# objects_to_array(objects, field)
# objects_to_array([{"login": login}], "login") -> [login]

# apply_func
# mapped := [func(x) | x = list[_]]

# Json = [1, 2, 3]
# MD: * 1
#     * 2
#     * 3
json_to_md_list(json_input, indent) = res {
  s := concat("\n", [sprintf("%s* %v", [indent, x]) | x = json_input[_]])
  res := sprintf("%s", [s])
}

json_to_md_dict(json_input, separator, indent) = res {
  s := concat("\n", [sprintf("%s* %v%s %v", [indent, k, separator, v]) | v = json_input[k]])
  res := sprintf("%s", [s])
}

json_to_md_headed_list(k, json_list, indent) = res {
  extra_indent := sprintf("  %s", [indent])
  list_str := json_to_md_list(json_list, extra_indent)
  header := sprintf("%s* **%s**:", [indent, k])
  s := concat("\n", [header, list_str])
  res := sprintf("%s", [s])
}

json_to_md_headed_dict(k, json_dict, separator, indent) = res {
  extra_indent := sprintf("  %s", [indent])
  dict_str := json_to_md_dict(json_dict, separator, extra_indent)
  header := sprintf("%s* **%s**:", [indent, k])
  s := concat("\n", [header, dict_str])
  res := sprintf("%s", [s])
}

# Json = {1: [1, 2, 3], k: [5, 6, 7]}
# MD: * **1**
#       * 1
#       * 2
#       * 3

json_to_md_dict_of_lists(json_input, indent) = res {
  s := concat("\n", [json_to_md_headed_list(k, json_list, indent) | some k, json_list in json_input])
  res := sprintf("%s", [s])
}

json_to_md_dict_of_dicts(json_input, separator, indent) = res {
  s := concat("\n", [json_to_md_headed_dict(k, json_list, separator, indent) | some k, json_list in json_input])
  res := sprintf("%s", [s])
}

json_to_md_dict_to_table(json_input, indent) = res {
  key_lens := [count(k) | some k, _ in json_input]
  body_in := [ sprintf("| %v | %v |", [k, v]) | some k, v in json_input ]
  body := concat("\n", body_in)
  res := sprintf("%s", [body])
}

json_to_md_dict_to_row(json_input, keys, indent) = res {
  # Works for json_input[v] as strings, does not work for int
  row := concat(" | ", [ json_input[v] | v = keys[k]])
  res := sprintf("| %s |", [row])
}

json_to_md_array_of_dict_to_table(json_input, keys, indent) = res {
  header := sprintf("| %s |", [concat(" | ", keys)])
  delims := { i: " --- " | some i in numbers.range(1, count(keys)) }
  delim := sprintf("|%s|", [concat("|", [d | some d in delims])])

  records := [ s |
    some r in json_input
    s := json_to_md_dict_to_row(r, keys, indent)
  ]

  body := concat("\n", records)
  res := concat("\n", [header, delim, body])
}

array_group_by(input_array, fields) = res {
  path := concat(".", fields)
  res := [ r |
    r := input_array[_][path]
  ]
}

state_diff(current, field, configured) = diff {
  some x in current
  exists(configured, x)
  flattened = { x: flatten_array(current[x], field) }

  diff = { y: array_subtraction(flattened[y], configured[y]) }
}

state_diff(current, field, configured) = diff {
  some x in current
  not exists(configured, x)

  flattened = { x: flatten_array(current[x], field) }

  diff = flattened
}
