# Login Sample: Facebook Login

This repository contains a basic app that can be used with Facebook Login, demonstrating a `FBLoginButton` that will authenticate with Facebook and then perform a token exchange with Auth0 to yield Auth0 user tokens.

View the full tutorial on [auth0.com/docs](https://auth0.com/docs/quickstart/native/ios-swift-facebook-login).

## Requirements

- Xcode 11+
- iOS 13+
- CocoaPods

## Installation

Install pods using the following:

```sh
pod install
```

Then open the `Facebook.xcworkspace` workspace in Xcode.

## Configure the Sample App

You will need to configure your Auth0 application with a valid Facebook connection. Please see [Add Facebook Login to Native Apps](https://auth0.com/docs/connections/nativesocial/facebook).


### Add Auth0 configuration

Copy the `Auth0.plist.example` file to a file called `Auth0.plist`, and populate the values with your Auth0 app Domain and Client ID:

```xml
<plist version="1.0">
<dict>
    <key>Domain</key>
    <string>{DOMAIN}</string>
    <key>ClientId</key>
    <string>{CLIENT_ID}</string>
</dict>
</plist>
```

## Facebook References

- [Getting Started with the Facebook SDK for iOS](https://developers.facebook.com/docs/ios/getting-started/)
- [Facebook Login for iOS - Quickstart](https://developers.facebook.com/docs/facebook-login/ios)
