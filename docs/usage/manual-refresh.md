---
id: manual-refresh
title: Manual Refresh
sidebar_label: Manual Refresh
---

## Call the SuperTokensURLSession.attemptRefreshingSession method: [API Reference](../api-reference/api-reference#supertokensurlsessionattemptrefreshingsessioncompletionhandler-escaping-bool-error-void)

- This is required if you need to manually call the refresh token endpoint
- This will call the refresh token endpoint and handle all the token changes

```swift
SuperTokensURLSession.attemptRefreshingSession(completionHandler: {
    result, error in

    if error != nil {
        switch error! {
            case SuperTokensError.illegalAccess:
                // SuperTokens.init not called
                break
            default:
                // Unexpected error
                break
        }
    }

    if result {
        // Refresh successful
    } else {
        // Refresh failed
    }
})
```