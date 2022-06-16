package test.hooks

import future.keywords.in

known_hook := { "org/repo": [ {"active": true, "created_at": "2022-01-01T00:00:00Z", "events": ["label"], "id": 1, "name": "test", "config": { "content_type": "json", "insecure_url": "0", "url": "https://example.com" }, "updated_at": "2022-01-01T00:00:01Z", "type": "Repository" } ] }

changed_active_hook := { "org/repo": [ {"active": false, "created_at": "2022-01-01T00:00:00Z", "events": ["label"], "id": 1, "name": "test", "config": { "content_type": "json", "insecure_url": "0", "url": "https://example.com" }, "updated_at": "2022-01-01T00:00:01Z", "type": "Repository" } ] }
changed_created_at_hook := { "org/repo": [ {"active": true, "created_at": "2022-01-01T00:00:01Z", "events": ["label"], "id": 1, "name": "test", "config": { "content_type": "json", "insecure_url": "0", "url": "https://example.com" }, "updated_at": "2022-01-01T00:00:01Z", "type": "Repository" } ] }
changed_events_hook := { "org/repo": [ {"active": true, "created_at": "2022-01-01T00:00:00Z", "events": ["label", "pull"], "id": 1, "name": "test", "config": { "content_type": "json", "insecure_url": "0", "url": "https://example.com" }, "updated_at": "2022-01-01T00:00:01Z", "type": "Repository" } ] }
changed_id_hook := { "org/repo": [ {"active": true, "created_at": "2022-01-01T00:00:00Z", "events": ["label"], "id": 2, "name": "test", "config": { "content_type": "json", "insecure_url": "0", "url": "https://example.com" }, "updated_at": "2022-01-01T00:00:01Z", "type": "Repository" } ] }
changed_name_hook := { "org/repo": [ {"active": true, "created_at": "2022-01-01T00:00:00Z", "events": ["label"], "id": 1, "name": "test_test", "config": { "content_type": "json", "insecure_url": "0", "url": "https://example.com" }, "updated_at": "2022-01-01T00:00:01Z", "type": "Repository" } ] }
changed_config_content_type_hook := { "org/repo": [ {"active": true, "created_at": "2022-01-01T00:00:00Z", "events": ["label"], "id": 1, "name": "test", "config": { "content_type": "non-json", "insecure_url": "0", "url": "https://example.com" }, "updated_at": "2022-01-01T00:00:01Z", "type": "Repository" } ] }
changed_config_insecure_ssl_hook := { "org/repo": [ {"active": true, "created_at": "2022-01-01T00:00:00Z", "events": ["label"], "id": 1, "name": "test", "config": { "content_type": "json", "insecure_url": "1", "url": "https://example.com" }, "updated_at": "2022-01-01T00:00:01Z", "type": "Repository" } ] }
changed_config_url_hook := { "org/repo": [ {"active": true, "created_at": "2022-01-01T00:00:00Z", "events": ["label"], "id": 1, "name": "test", "config": { "content_type": "json", "insecure_url": "0", "url": "https://non-example.com" }, "updated_at": "2022-01-01T00:00:01Z", "type": "Repository" } ] }
changed_updated_at_hook := { "org/repo": [ {"active": true, "created_at": "2022-01-01T00:00:00Z", "events": ["label"], "id": 1, "name": "test", "config": { "content_type": "json", "insecure_url": "0", "url": "https://example.com" }, "updated_at": "2022-01-01T00:00:02Z", "type": "Repository" } ] }
changed_type_hook := { "org/repo": [ {"active": true, "created_at": "2022-01-01T00:00:00Z", "events": ["label"], "id": 1, "name": "test", "config": { "content_type": "json", "insecure_url": "0", "url": "https://example.com" }, "updated_at": "2022-01-01T00:00:01Z", "type": "Organization" } ] }

test_known_hook {
  count(data.github.hooks.new_hooks) == 1
    with data.github.hooks.responses as known_hook
    with data.github.state.hooks.config as known_hook
}

test_changed_active_hook {
  count(data.github.hooks.new_hooks) == 1
    with data.github.hooks.responses as known_hook
    with data.github.state.hooks.config as changed_active_hook
}

test_changed_created_at_hook {
  count(data.github.hooks.new_hooks) == 1
    with data.github.hooks.responses as known_hook
    with data.github.state.hooks.config as changed_created_at_hook
}

test_changed_events_hook {
  count(data.github.hooks.new_hooks) == 1
    with data.github.hooks.responses as known_hook
    with data.github.state.hooks.config as changed_events_hook
}

test_changed_id_hook {
  count(data.github.hooks.new_hooks) == 1
    with data.github.hooks.responses as known_hook
    with data.github.state.hooks.config as changed_id_hook
}

test_changed_name_hook {
  count(data.github.hooks.new_hooks) == 1
    with data.github.hooks.responses as known_hook
    with data.github.state.hooks.config as changed_name_hook
}

test_changed_config_content_type_hook {
  count(data.github.hooks.new_hooks) == 1
    with data.github.hooks.responses as known_hook
    with data.github.state.hooks.config as changed_config_content_type_hook
}

test_changed_config_insecure_ssl_hook {
  count(data.github.hooks.new_hooks) == 1
    with data.github.hooks.responses as known_hook
    with data.github.state.hooks.config as changed_config_insecure_ssl_hook
}

test_changed_config_url_hook {
  count(data.github.hooks.new_hooks) == 1
    with data.github.hooks.responses as known_hook
    with data.github.state.hooks.config as changed_config_url_hook
}

test_changed_updated_at_hook {
  count(data.github.hooks.new_hooks) == 1
    with data.github.hooks.responses as known_hook
    with data.github.state.hooks.config as changed_updated_at_hook
}

test_changed_type_hook {
  count(data.github.hooks.new_hooks) == 1
    with data.github.hooks.responses as known_hook
    with data.github.state.hooks.config as changed_type_hook
}


#list_compr := { 1: [ { "id": 1, "created_at": 2, "config": { "url": 3 } } ],
#  2: "foo" }

#list_h := { "id": 1, "created_at": 2, "config": { "url": 3 } }

#test_list_comprehension { res |
#  some k, vv in list_compr

#  v := [ x |
#    h := list_h[_]

#    h == vv[_]

#    x := { "id": h.id, "created_at": h.created_at, "config": { "url": h.config.url } }
#  ]

#  res := { k: v }
#}
