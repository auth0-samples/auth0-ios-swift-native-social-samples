# Login sample: Native Sign In With Apple

This repository contains a basic app that can be used with SIWA, demonstrating a `sign in` button that will perform native SIWA and then perform a token exchange with Auth0 to yield Auth0 user tokens.

Cocoapods are used here. However, you can access the [early-access branch of Auth0.swift](https://github.com/auth0/Auth0.swift/tree/added-apple-token-exchange).

View the full tutorial on [auth0.com/docs](https://auth0.com/docs/quickstart/native/ios-swift-siwa).

## Requirements

- [Xcode 11 beta 6 (11M392q)](https://developer.apple.com/news/releases/)
- iOS 13 Beta 8 Device
- CocoaPods

## Installation

Install pods using the following:

```text
pod install
```

Then open the `signinwithapple.xcworkspace' workspace in XCode 11.

## Configure the sample app

1. You will need to configure your Auth0 application with a valid Apple connection, please see [Setting up Sign in with Apple](https://auth0.com/docs/connections/apple-setup) with Auth0.

1. You will need to modify the the `Bundle Identifier` to match your own app identifier that has been configured for SIWA in the Apple Developer Portal.

### Add Auth0 configuration

Copy the `Auth0.plist.example` file to a file called `Auth0.plist`, and populate the values with your Auth0 app domain and client ID:

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

## Apple References

- [Adding the Sign In with Apple Flow to Your App](https://developer.apple.com/documentation/authenticationservices/adding_the_sign_in_with_apple_flow_to_your_app)
- [https://developer.apple.com/videos/play/wwdc2019/706](https://developer.apple.com/videos/play/wwdc2019/706)

