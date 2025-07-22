# Live Stream Flutter SDK

## Usage

### 1. Plug-and-Play (Default UI)

Add the SDK widget directly to your widget tree. This will handle initialization and show the default live stream UI when ready:

```dart
IsmLiveApp(
  configuration: myConfig, // Your IsmLiveConfigData
  navigatorKey: myNavKey,  // Your app's navigator key
)
```

- The widget will show a loading indicator until initialization is complete.
- When ready, it displays the default live stream UI.

---

### 2. Manual Initialization (Custom/Advanced Usage)

If you want to control initialization and use only specific SDK features or screens:

```dart
// In your app's startup logic (e.g., splash screen):
await IsmLiveApp.initialize(myConfig, navigatorKey: myNavKey);

// Later, in your widget tree, use any SDK widget:
IsmLiveStreamListing()
// or any other SDK-provided widget/feature
```

- This approach gives you full control over when and how to show SDK screens.
- You can use any SDK widget after initialization.

---

### 3. Runtime Check (Optional)

If you use SDK widgets directly, you can check initialization:

```dart
assert(IsmLiveApp.isInitialized, 'Call IsmLiveApp.initialize before using SDK widgets!');
```

---

## Summary Table

| Host App Needs         | What to Use                | What Happens                |
|----------------------- |---------------------------|-----------------------------|
| Plug-and-play          | `IsmLiveApp`              | Handles init, shows loader & default UI |
| Custom/Advanced        | `IsmLiveApp.initialize` + SDK widgets | Host controls init, uses any SDK feature |

---

For more details, see the API documentation or contact support.
