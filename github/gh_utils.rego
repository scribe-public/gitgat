package github.gh_utils

import future.keywords.in
import data.github.utils as utils

get_nested_data(url_collection, url, suffix, filter, err_substitute) = v {
  u = concat("?", [trim_suffix(url_collection[url], suffix), filter])
  r := utils.parse(data.github.api.call_github_abs(u))
  v := utils.error_substitute(r, err_substitute)
}
