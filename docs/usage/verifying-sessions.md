---
id: verifying-sessions
title: Verifying Sessions
sidebar_label: Verifying Sessions
---

## Call the SuperTokens.sessionPossiblyExists function: [API Reference](../api-reference/api-reference#supertokenssessionpossiblyexists)

```swift
if SuperTokens.sessionPossiblyExists() {
    // There is currently an active session
} else {
    // No sessions currently active
}
```

- This method can be used to check if there is currently an active session.
- For example: To check whether a user should be asked to login or redirected to the main flow directly.