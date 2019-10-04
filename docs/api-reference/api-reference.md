---
id: api-reference
title: API Reference
sidebar_label: API Reference
---

## ```SuperTokens.`init`(refreshTokenEndpoint: String, sessionExpiryStatusCode: Int?) throws```
##### Parameters
- ```refreshTokenEndpoint```
    - Should be the full request URL for your refresh session API endpoint. 
    - The library will use this endpoint in case of session expiry.

- ```sessionExpiryStatusCode```
    - Value for the HTTP Status Code which represents unauthorised access.
    - Optional, defaults to ```440```.

##### Returns
- ```void```

##### Throws
- ```SuperTokensError.invalidURL``` if the refreshTokenEndpoint does not start with http or https, or it has an invalid format.

<div class="divider"></div>

## ```SuperTokens.sessionPossiblyExists()```
##### Parameters
- none

##### Returns
- ```Boolean```, true if there is an existing session

##### Throws
- nothing

<div class="divider"></div>

## ```SuperTokensURLSession.newTask(request: URLRequest, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void)```
##### Parameters
- ```request``` - The URLRequest with which the API call should be made
- ```completionHandler``` - The callback that will be called with the API result

##### Returns
- nothing

##### Throws
- nothing

<div class="divider"></div>

## ```SuperTokensURLSession.attemptRefreshingSession(completionHandler: @escaping (Bool, Error?) -> Void)```
##### Parameters
- ```completionHandler``` - Callback which accepts a Bool value representing whether it was successful and an Error if one occurs.

##### Returns
- nothing

##### Throws
- nothing