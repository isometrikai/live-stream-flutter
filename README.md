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

### 3. Customizing Stream Behavior

You can customize various stream behaviors using the `configureInterface` method:

```dart
IsmLiveApp.configureInterface(
  // Custom GoLive button click handler
  onGoLiveClick: (context, isScheduledStream, streamDetails) async {
    // Your custom logic here
    if (isScheduledStream) {
      // Handle scheduled stream
      print('Scheduled stream detected');
    } else {
      // Handle regular stream
      print('Regular stream detected');
    }
    
    // You can perform custom actions like:
    // - Show custom dialogs
    // - Validate user permissions
    // - Track analytics
    // - Custom navigation
  },
  
  // Custom host stop stream handler
  onHostStopStream: (streamId) async {
    // Custom logic when host stops stream
    print('Host stopped stream: $streamId');
  },
  
  // Other customization options...
  showHeader: true,
  streamHeader: (context) => CustomHeader(),
  // ... more options
);
```

#### Available Callbacks:

- **`onGoLiveClick`**: Called when the "Go Live" button is tapped
  - Parameters: `context`, `isScheduledStream`, `streamDetails`
  - If not set, default behavior is used (edit scheduled stream or start stream)
  
- **`onHostStopStream`**: Called when host stops the stream
  - Parameter: `streamId`
  - If not set, default stop stream behavior is used

---

### 4. Runtime Check (Optional)

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
| Custom Stream Behavior  | `IsmLiveApp.configureInterface` | Customize stream interactions |

---

For more details, see the API documentation or contact support.
