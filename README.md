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
  // Custom GoLive button click handler with comprehensive data
  onGoLiveClick: (context, isScheduledStream, streamDetails, goLiveData) async {
    // Access all user-entered details
    print('Description: ${goLiveData.description}');
    print('HD Broadcast: ${goLiveData.isHdBroadcast}');
    print('Record Broadcast: ${goLiveData.isRecordingBroadcast}');
    print('Restream Broadcast: ${goLiveData.isRestreamBroadcast}');
    print('Premium Stream: ${goLiveData.isPremium}');
    print('Premium Coins: ${goLiveData.premiumStreamCoins}');
    print('Picked Image: ${goLiveData.pickedImage?.path}');
    print('Selected Products: ${goLiveData.selectedProductsList.length}');
    print('RTMP URL: ${goLiveData.rtmpUrl}');
    print('Stream Key: ${goLiveData.streamKey}');
    print('Restream Facebook: ${goLiveData.restreamFacebook}');
    print('Restream YouTube: ${goLiveData.restreamYoutube}');
    print('Restream Instagram: ${goLiveData.restreamInstagram}');
    
    // Your custom logic here
    if (isScheduledStream) {
      print('Scheduled stream detected - editing schedule');
      // Handle scheduled stream
    } else {
      print('Regular stream detected - starting stream');
      // Handle regular stream
    }
    
    // You can perform custom actions like:
    // - Validate user permissions
    // - Track analytics
    // - Show custom dialogs
    // - Custom navigation
    // - Process the picked image
    // - Validate stream settings
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
  - Parameters: `context`, `isScheduledStream`, `streamDetails`, `goLiveData`
  - `goLiveData` contains all user-entered details:
    - `description`: User-entered stream description
    - `pickedImage`: Selected image file (XFile) - **Note**: If no image was picked by user, the system will automatically take a picture from camera or pick from gallery, similar to the default behavior
    - `isHdBroadcast`: HD Broadcast toggle status
    - `isRecordingBroadcast`: Record Broadcast toggle status
    - `isRestreamBroadcast`: Restream Broadcast toggle status
    - `isPremium`: Premium stream toggle status
    - `premiumStreamCoins`: Premium stream coins amount
    - `selectedProductsList`: List of selected products
    - `rtmpUrl`, `streamKey`: RTMP settings
    - `restreamFacebook`, `restreamYoutube`, `restreamInstagram`: Restream platform toggles
    - And many more stream configuration options
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

## Dynamic Font Family Support

The SDK now supports dynamic font family configuration, allowing host apps to use their own fonts throughout the live streaming interface.

### Usage

```dart
// Configure the interface with your custom font family
IsmLiveApp.configureInterface(
  fontFamily: 'YourCustomFont', // Your font family name
  // ... other configurations
);
```

### How it Works

1. **Font Family Configuration**: Host app provides the font family name via `configureInterface`
2. **Automatic Application**: The SDK automatically applies the font family to all text styles
3. **Fallback Support**: If no font family is provided, the SDK uses default system fonts
4. **Consistent Styling**: All other font properties (size, weight, color) remain unchanged

### Implementation Details

- **IsmLiveStyles**: All predefined styles automatically use the configured font family
- **Extension Method**: Use `.withLiveFont` on any TextStyle to apply the dynamic font
- **Theme Integration**: Font family is integrated into the theme system for consistency

### Example

```dart
// In your host app
IsmLiveApp.configureInterface(
  fontFamily: 'Poppins', // Your app's font family
  productionMode: true,
  // ... other configurations
);

// The SDK will automatically use 'Poppins' for all text
// You can also manually apply it to custom styles:
Text(
  'Custom Text',
  style: TextStyle(fontSize: 16).withLiveFont,
)
```
