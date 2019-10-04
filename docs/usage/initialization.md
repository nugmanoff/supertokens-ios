---
id: initialization
title: Initialization
sidebar_label: Initializing
---

## Call the SuperTokens.`init` function: [API Reference](../api-reference/api-reference#supertokens-init-refreshtokenendpoint-string-sessionexpirystatuscode-int-throws)

- To be called at least once before any http request is made to any of your APIs that require authentication. 
- <span class="highlighted-text">You only need to call this once in your app.</span>

```swift
do {
    try SuperTokens.`init`(refreshTokenEndpoint: "\(Constants.apiBase):8080/api/refreshtoken")
} catch SuperTokensError.invalidURL {
    // Invalid URL provided for refresh token
} catch {
    // Unexpected Error
}
```