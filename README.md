# ios-vanilla
A vanilla flavour version of basic Flybits iOS application for V3

This is an as-simple-as-you-get demostration of the Flybits V3 platform. Here you will learn how our Context, Content and Push SDKs are implemented in an application and learn how to leverage our SDKs and provide contextually relevant content to your users.

Our SDK is supported on iOS version 8 and up!

## Documentation

Please visit our [developer portal](https://devportal.flybits.com)

## Installation
### CocoaPods

[CocoaPods](http://cocoapods.org) is a dependency manager for macOS, iOS, tvOS and watchOS projects. You can install it with the following command:

```bash
$ gem install cocoapods
```

To integrate the Flybits SDK into your Xcode project, add a Podfile file to your project and add the following lines:

```ruby
use_frameworks!

pod 'FlybitsKernelSDK'
pod 'FlybitsContextSDK'
pod 'FlybitsPushSDK'
```

### Manually

Add any Flybits frameworks to your project, navigate to your project file, project target, and ensure to add the frameworks to both Linked Frameworks and Libraries and Embedded Binaries sections.

### Code Implementation

First import the relevant SDKs into your project:

```swift
import FlybitsKernelSDK
import FlybitsContextSDK
import FlybitsPushSDK
```

## Implementation

### Flybits Project ID

Obtain your Project ID from the Flybits [Developer Portal](https://devportal.flybits.com)

Once you have created an account on the Flybits Developer Portal and logged in, click the "MyProjects" link in the top right corner and "Create new project". Once you have finished creating a project, a Project ID is assigned to your new project - this identifier is required for you to access our services. Add this to a new Property List file (plist) with one key-value pair in your Xcode project. Supply the key "ProjectID" and value set to your new Project ID. 

### Logging in with Single Sign-On

For your user-login logic, use our `connect(completion:)` API

```swift
let manager = FlybitsManager()
let flybitsManager = FlybitsManager(projectID: projectID, idProvider: flybitsIDP, scopes: scopes)
let scopes: [FlybitsScope] = [KernelScope(), ContextScope(timeToUploadContext: 1, timeUnit: Utilities.TimeUnit.minutes), PushScope()]

let connectRequest = flybitsManager.connect { user, error in
    guard let user = user, error == nil else {
        print("Failed to connect")
        return
    }
    print("Welcome, \(user.firstname!)")
    // Logged in
}
```

Or if a user has already signed in, avoid asking them for their credentials a second time by using the `isConnected(scopes:completion:)` API

```swift
let isConnectedRequest = FlybitsManager.isConnected(scopes: scopes) { isConnected, user, error in
    guard error == nil else {
        print(error!.localizedDescription)
    }
    guard isConnected, let user = user else {
        // Not logged in
        return
    }
    // Logged in
}
```

### Uploading Context

```swift
let contextPlugin = BankingDataContextPlugin(accountBalance: 50, segmentation: "Student", creditCard: "VISA")
_ = try? ContextManager.shared.register(self.contextPlugin!)

// ... Potentially mutate context plugin data here ...

let contextData = contextPlugin.toDictionary()

// Upload any context data you want to update here by passing it in an array
let contextDataRequest = ContextDataRequest.sendData([contextData]) { (error) -> () in
    guard error == nil else {
        // Error sending context data
        return
    }
    // Successfully uploaded context data
}.execute()
```

### Getting Content

```swift
let contentDataRequest = Content.getAllRelevant(with: templateIDsAndClassModelsDictionary, pager: pager) { pagedContent, error in
    guard let pagedContent = pagedContent, error == nil else {
        // Returned without any relevant content
        return
    }
    // Valid content
}
```

### Push

Implementation description will be added soon...
