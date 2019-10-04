---
id: what-and-why
title: Why is a Frontend SDK needed
sidebar_label: Why is this needed
---

- When the users access token expires, this library silently calls your refresh token endpoint to retrieve a new access token and then automatically retries the original request that fails. This requires minimal changes to integrate.
- Manages anti-CSRF tokens and Id refresh tokens for you.
- Synchronizes with other network requests to the refresh token endpoint to prevent <a href="https://supertokens.io/blog/the-best-way-to-securely-manage-user-sessions#e81c" target="_blank">this</a> race condition.
- Provides interceptors for OkHttp and Retrofit to allow single-step integration.

<div class="specialNote">
You also need to use our backend SDK for a complete solution. Please visit <a target="_blank" href="https://supertokens.io#tech-stack">our home page</a> to find the right one for you.
</div>