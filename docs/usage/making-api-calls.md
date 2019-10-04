---
id: making-api-calls
title: Making API Calls
sidebar_label: Making API Calls
---

## Call the SuperTokensURLSession.newTask method: [API Reference](../api-reference/api-reference#supertokensurlsessionnewtaskrequest-urlrequest-completionhandler-escaping-data-urlresponse-error-void)

```swift
let url = URL(string: "http://api.example.com/api/getUserInfo")
var request = URLRequest(url: url!)
request.httpMethod = "POST"
SuperTokensURLSession.newTask(request: request, completionHandler: {
    data, response, error in

    // DO SOMETHING
})
```