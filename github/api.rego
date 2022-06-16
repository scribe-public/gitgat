package github.api

import future.keywords.in

call_github(url) = response {
  request_url := concat("/", ["https://api.github.com", url])
  response = call_github_abs(request_url)
}

call_github_abs(url) = response {
  request := {"method": "GET",
              "url": url,
              "headers": {
                "Authorization": input.token,
                "Accept": "application/vnd.github.v3+json; application/vnd.github.v3.repository+json"},
              "raise_error": false}
  response := http.send(request)
}

post_github(url, upload_data) = response {
  request_url := concat("/", ["https://api.github.com", url])
  response = post_github_abs(request_url, upload_data)
}

post_github_abs(url, upload_data) = response {
  request := {"method": "POST",
              "url": url,
              "headers": {
                "Authorization": input.token,
                "Accept": "application/vnd.github.v3+json",
                "Content-Type": "application/json"
              },
              "raise_error": false,
              "body": upload_data
             }
  response := http.send(request)
}

post_test(upload_data) = response {
  request := {"method": "POST",
              "url": "http://localhost:8282",
              "headers": {
                "Authorization": input.token,
                "Accept": "application/vnd.github.v3+json",
                "Content-Type": "application/json"
              },
              "raise_error": false,
              "raw_body": "{\"files\": {}}"
             }
  print(request)
  response := http.send(request)
}
