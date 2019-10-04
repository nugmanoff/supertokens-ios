---
id: migration
title: Add SuperTokens to an existing application
sidebar_label: Migration
---

## Add the SuperTokens Pod to your Podfile

```
pod 'SuperTokensSession', '~> {latest-version}'
```

You can find the latest version <a href="https://github.com/supertokens/supertokens-ios/releases" target="_blank">here</a>

## Using SuperTokens to make API calls

The library is designed to allow integration with minimal changes. For example if your API flow looks something like this:

```swift
let url = URL(string: "http://api.example.com/api/getUserInfo")
let request = URLRequest(url: url!)
request.httpMethod = "POST"

URLSession.shared.dataTask(request: request, completionHandler: {
    data, response, error in

    // DO SOMETHING
}).resume()
```

when using SuperTokens the following code snippet would need to modified like so:

```swift
let url = URL(string: "http://api.example.com/api/getUserInfo")
let request = URLRequest(url: url!)
request.httpMethod = "POST"

SuperTokensURLSession.newTask(request: request, completionHandler: {
    data, response, error in

    // DO SOMETHING
})
```