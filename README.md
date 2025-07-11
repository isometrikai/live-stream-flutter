# Appscrip LiveStream Component
[![isometrik.io](./assets/logo/isometrik.png)](https://isometrik.io/)

**Appscrip LiveStream Component** is a Flutter package that enables robust, customizable live streaming functionality in your apps, powered by Isometrik.

---

## Features

- Easy integration of live streaming features
- Works with any Flutter navigation system (MaterialApp, GoRouter, GetX, etc.)
- Highly customizable UI components
- Built-in support for analytics, gifting, and more

---

## Installation

> **Note:** This package is for **live streaming only**  
> Use the following branch for the latest live streaming features:

```yaml
dependencies:
  appscrip_live_stream_component:
    git:
      url: https://github.com/your-org/appscrip_live_stream_component.git
      ref: feature/dependency
```

---

## Platform Setup

- [Android Setup](./README_android.md)
- [iOS Setup](./README_ios.md)

---

## Configuration (`myConfig`)

You need to provide an `IsmLiveConfigData` object to initialize the live stream component.  
Here’s an example of how to create it:

```dart
final myConfig = IsmLiveConfigData(
  projectConfig: IsmLiveProjectConfig(
    accountId: '<your-account-id>',
    appSecret: '<your-app-secret>',
    userSecret: '<your-user-secret>',
    keySetId: '<your-key-set-id>',
    licenseKey: '<your-license-key>',
    projectId: '<your-project-id>',
    deviceId: '<your-device-id>',
  ),
  userConfig: IsmLiveUserConfig(
    userToken: '<user-token>',
    userId: '<user-id>',
    firstName: '<first-name>',
    lastName: '<last-name>',
    userEmail: '<user-email>',
    userProfile: '<user-profile-url>',
  ),
  mqttConfig: IsmLiveMqttConfig(
    hostName: '<mqtt-host>',
    port: <mqtt-port>,
  ),
);
```

> **Tip:**  
> You can see a real-world example in [`example/lib/controllers/home/home_controller.dart`](example/lib/controllers/home/home_controller.dart).

---

## Getting Started

### 1. Initialize in `main.dart`

```dart
final kNavigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Create your config as shown above
  final myConfig = ...;

  await IsmLiveApp.initialize(
    myConfig, // Your IsmLiveConfigData object
    navigatorKey: kNavigatorKey,
  );

  runApp(
    MaterialApp(
      navigatorKey: kNavigatorKey,
      // ... other properties
    ),
  );
}
```

---

## UI Customization

You can easily customize the look and feel of the live stream UI using `IsmLiveApp.configureInterface`.  
For example, to customize stream options and button styles:

```dart
IsmLiveApp.configureInterface(
  hostOptions: [
    IsmLiveStreamOption.bars,
    IsmLiveStreamOption.share,
    IsmLiveStreamOption.rotateCamera,
    IsmLiveStreamOption.settings,
  ],
  viewersOptions: [
    IsmLiveStreamOption.gift,
    IsmLiveStreamOption.share,
    IsmLiveStreamOption.speaker,
    IsmLiveStreamOption.heart,
  ],
  ismLiveButtonConfig: IsmLiveButtonConfig(
    primaryBuilder: (context, {required label, onTap, ...}) =>
      CustomButton(title: label, onPress: onTap),
    secondaryBuilder: (context, {required label, onTap, ...}) =>
      CustomButton(title: label, onPress: onTap, onlyBorder: true),
  ),
  streamOptionsBgGradient: const LinearGradient(
    begin: Alignment.bottomCenter,
    end: Alignment.topCenter,
    colors: [
      ColorsValue.gradientStart,
      ColorsValue.gradientEnd,
    ],
  ),
  liveAnalyticsOptions: [
    IsmLiveAnalyticsOptions.hearts,
    IsmLiveAnalyticsOptions.viewers,
    IsmLiveAnalyticsOptions.followers,
    IsmLiveAnalyticsOptions.earnings,
    IsmLiveAnalyticsOptions.duration,
  ],
);
```

See [`example/lib/controllers/home/home_controller.dart`](example/lib/controllers/home/home_controller.dart) for a full example.

---

## Example

For a complete working example, check the [`example/`](./example/) directory.

---

## Support

For questions, issues, or feature requests, please open an issue on the [GitHub repository](https://github.com/your-repo).

---

## License

[MIT](./LICENSE)
