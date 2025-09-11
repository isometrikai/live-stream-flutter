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
  
  // GoLive screen configuration (recommended approach)
  goLiveScreenConfigure: IsmLiveGoLiveScreenConfigure(
    goLiveHeaderBuilder: (context, controller) => CustomGoLiveHeader(),
    goLiveButtonBuilder: (context, controller, onGoLivePressed, isEnabled) => 
        CustomGoLiveButton(
          onPressed: isEnabled ? onGoLivePressed : null,
          isEnabled: isEnabled,
        ),
    radioTileTextStyle: TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w500,
      color: Colors.black87,
    ),
    addCoverTextStyle: TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w600,
      color: Colors.blue,
    ),
    addIcon: Icons.add_box_rounded,
  ),
  
  // Other customization options...
  showHeader: true,
  streamHeader: (context) => CustomHeader(),
  // ... more options
);
```

#### GoLive Screen Configuration

The SDK now provides a dedicated `IsmLiveGoLiveScreenConfigure` class for better organization of GoLive screen customization:

```dart
// New recommended approach
IsmLiveApp.configureInterface(
  goLiveScreenConfigure: IsmLiveGoLiveScreenConfigure(
    goLiveHeaderBuilder: (context, controller) => CustomGoLiveHeader(),
    goLiveButtonBuilder: (context, controller, onGoLivePressed, isEnabled) => 
        CustomGoLiveButton(
          onPressed: isEnabled ? onGoLivePressed : null,
          isEnabled: isEnabled,
        ),
    radioTileTextStyle: TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w500,
      color: Colors.black87,
    ),
    addCoverTextStyle: TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w600,
      color: Colors.blue,
    ),
  ),
);

// Legacy approach (still supported for backward compatibility)
IsmLiveApp.configureInterface(
  goLiveHeaderBuilder: (context, controller) => CustomGoLiveHeader(),
  goLiveButtonBuilder: (context, controller, onGoLivePressed, isEnabled) => 
      CustomGoLiveButton(
        onPressed: isEnabled ? onGoLivePressed : null,
        isEnabled: isEnabled,
      ),
);
```

**Benefits of the new approach:**
- Better organization and cleaner code
- Easier to extend with future GoLive screen features
- Consistent with other configuration classes like `IsmLiveEcomConfigure`
- Backward compatible with existing implementations

#### Text Style Customization

The `IsmLiveGoLiveScreenConfigure` class includes specific text style properties for different UI elements:

```dart
IsmLiveApp.configureInterface(
  goLiveScreenConfigure: IsmLiveGoLiveScreenConfigure(
    radioTileTextStyle: TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w500,
      color: Colors.black87,
      letterSpacing: 0.5,
    ),
    addCoverTextStyle: TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w600,
      color: Colors.blue,
      decoration: TextDecoration.underline,
    ),
    addIcon: Icons.add_circle,
    // ... other configurations
  ),
);
```

**Text Style Properties:**
- **`radioTileTextStyle`**: Customizes text in radio tiles, switches, and toggle components
- **`addCoverTextStyle`**: Customizes action text elements like "Add cover", "Add description", etc.
- **`addIcon`**: Customizes the icon used for "Add" actions like "Add Cover", "Add products", etc.
- **Fallback Support**: Uses default styling and icons if no custom configuration is provided
- **Easy Management**: Centralized styling for consistent appearance across different UI elements

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

- **`heartMessageCallback`**: Called when a user sends a heart message to the stream
  - Parameters: `streamId`, `userId`, `userName`, `userImage`, `deviceId`, `customType`
  - Return `true` if your app successfully handled the heart message, `false` to let SDK handle with default implementation
  - Useful for custom heart message APIs, analytics tracking, user validation, rate limiting, etc.
  - If not set, SDK uses default heart message handling

- **`streamAnalyticsCallback`**: Called when the SDK needs to fetch stream analytics data
  - Parameters: `streamId`
  - Return `IsmLiveStreamAnalyticsModel` if your app successfully provided analytics data, `null` to let SDK handle with default implementation
  - Useful for custom analytics APIs, real-time analytics integration, custom analytics processing, etc.
  - If not set, SDK uses default analytics API

- **`streamAnalyticsViewersCallback`**: Called when the SDK needs to fetch stream analytics viewers data
  - Parameters: `streamId`, `skip`, `limit`
  - Return `List<IsmLiveAnalyticViewerModel>` if your app successfully provided viewers data, `null` to let SDK handle with default implementation
  - Useful for custom analytics viewers APIs, real-time viewers data integration, custom viewers data processing, etc.
  - If not set, SDK uses default analytics viewers API

#### Heart Message Callback Examples

**Basic Usage:**
```dart
IsmLiveApp.configureInterface(
  heartMessageCallback: (streamId, userId, userName, userImage, deviceId, customType) async {
    // Call your own API to handle heart messages
    final success = await _callYourHeartMessageAPI(
      streamId: streamId,
      userId: userId,
      userName: userName,
      userImage: userImage,
      deviceId: deviceId,
      customType: customType,
    );
    
    if (success) {
      // Log analytics
      await _logAnalytics(streamId, userId, userName);
      return true; // Host app handled successfully
    }
    
    return false; // Let SDK handle with default implementation
  },
);
```

**Advanced Usage with Validation:**
```dart
IsmLiveApp.configureInterface(
  heartMessageCallback: (streamId, userId, userName, userImage, deviceId, customType) async {
    // Validate if user can send heart messages
    if (!_canUserSendHeart(userId)) {
      return false; // Let SDK handle (might show error)
    }
    
    // Check rate limiting
    if (_isRateLimited(userId)) {
      return false;
    }
    
    // Call your API
    return await _callYourHeartMessageAPI(/* params */);
  },
);
```

**Premium User Handling:**
```dart
IsmLiveApp.configureInterface(
  heartMessageCallback: (streamId, userId, userName, userImage, deviceId, customType) async {
    if (_isPremiumUser(userId)) {
      // Premium users get special handling
      return await _handlePremiumHeartMessage(/* params */);
    } else {
      // Regular users get standard handling
      return await _handleRegularHeartMessage(/* params */);
    }
  },
);
```

**Dynamic Updates:**
```dart
// Update callback at runtime
IsmLiveApp.updateHeartMessageCallback(_newHeartMessageHandler);

// Disable custom handling (use SDK default)
IsmLiveApp.updateHeartMessageCallback(null);
```

#### Stream Analytics Callback Examples

**Basic Usage:**
```dart
IsmLiveApp.configureInterface(
  streamAnalyticsCallback: (streamId) async {
    // Call your own analytics API
    final analyticsData = await _callYourAnalyticsAPI(streamId);
    
    if (analyticsData != null) {
      // Convert your data to IsmLiveStreamAnalyticsModel format
      return IsmLiveStreamAnalyticsModel(
        totalViewersCount: analyticsData['viewers'],
        hearts: analyticsData['hearts'],
        followers: analyticsData['followers'],
        totalEarning: analyticsData['earnings'],
        duration: analyticsData['duration'],
        productCount: analyticsData['products'],
        // ... other fields
      );
    }
    
    return null; // Let SDK handle with default implementation
  },
);
```

**Advanced Usage with Real-time Analytics:**
```dart
IsmLiveApp.configureInterface(
  streamAnalyticsCallback: (streamId) async {
    try {
      // Call your real-time analytics service
      final realTimeData = await _getRealTimeAnalytics(streamId);
      
      // Apply custom business logic
      final processedData = _processAnalyticsData(realTimeData);
      
      return IsmLiveStreamAnalyticsModel(
        totalViewersCount: processedData.viewers,
        hearts: processedData.hearts,
        followers: processedData.followers,
        totalEarning: processedData.earnings,
        duration: processedData.duration,
        productCount: processedData.products,
        soldCount: processedData.soldProducts,
        newViewersCount: processedData.newViewers,
        earnings: processedData.revenue,
        giftsCount: processedData.gifts,
        coinsCount: processedData.coins,
      );
    } catch (e) {
      IsmLiveLog.error('Error fetching analytics: $e');
      return null; // Let SDK handle with default implementation
    }
  },
);
```

**Dynamic Updates:**
```dart
// Update analytics callback at runtime
IsmLiveApp.updateStreamAnalyticsCallback(_newAnalyticsHandler);

// Disable custom analytics (use SDK default)
IsmLiveApp.updateStreamAnalyticsCallback(null);
```

#### Stream Analytics Viewers Callback Examples

**Basic Usage:**
```dart
IsmLiveApp.configureInterface(
  streamAnalyticsViewersCallback: (streamId, skip, limit) async {
    // Call your own analytics viewers API
    final viewersData = await _callYourAnalyticsViewersAPI(
      streamId: streamId,
      skip: skip,
      limit: limit,
    );
    
    if (viewersData != null) {
      // Convert your data to List<IsmLiveAnalyticViewerModel> format
      return viewersData.map((viewer) => IsmLiveAnalyticViewerModel(
        isometrikUserId: viewer['isometrikUserId'],
        appUserId: viewer['appUserId'],
        firstName: viewer['firstName'],
        lastName: viewer['lastName'],
        userName: viewer['userName'],
        profilePic: viewer['profilePic'],
        timestamp: viewer['timestamp'],
        // ... other fields
      )).toList();
    }
    
    return null; // Let SDK handle with default implementation
  },
);
```

**Advanced Usage with Real-time Viewers Data:**
```dart
IsmLiveApp.configureInterface(
  streamAnalyticsViewersCallback: (streamId, skip, limit) async {
    try {
      // Call your real-time viewers analytics service
      final realTimeViewersData = await _getRealTimeViewersAnalytics(
        streamId: streamId,
        skip: skip,
        limit: limit,
      );
      
      // Apply custom business logic
      final processedViewersData = _processViewersData(realTimeViewersData);
      
      return processedViewersData.map((viewer) => IsmLiveAnalyticViewerModel(
        isometrikUserId: viewer.isometrikUserId,
        appUserId: viewer.appUserId,
        firstName: viewer.firstName,
        lastName: viewer.lastName,
        userName: viewer.userName,
        profilePic: viewer.profilePic,
        timestamp: viewer.timestamp,
        userMetaData: viewer.userMetaData,
        statusLogs: viewer.statusLogs,
      )).toList();
    } catch (e) {
      IsmLiveLog.error('Error fetching viewers analytics: $e');
      return null; // Let SDK handle with default implementation
    }
  },
);
```

**Dynamic Updates:**
```dart
// Update viewers analytics callback at runtime
IsmLiveApp.updateStreamAnalyticsViewersCallback(_newViewersAnalyticsHandler);

// Disable custom viewers analytics (use SDK default)
IsmLiveApp.updateStreamAnalyticsViewersCallback(null);
```

#### GoLive Screen Configuration Dynamic Updates

You can update GoLive screen configuration at runtime using the new configuration class:

```dart
// Update entire GoLive screen configuration
IsmLiveApp.updateGoLiveScreenConfigure(
  IsmLiveGoLiveScreenConfigure(
    goLiveHeaderBuilder: (context, controller) => NewCustomHeader(),
    goLiveButtonBuilder: (context, controller, onGoLivePressed, isEnabled) => 
        NewCustomButton(
          onPressed: isEnabled ? onGoLivePressed : null,
          isEnabled: isEnabled,
        ),
    radioTileTextStyle: TextStyle(
      fontSize: 18,
      fontWeight: FontWeight.w600,
      color: Colors.blue,
    ),
    addCoverTextStyle: TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w700,
      color: Colors.green,
    ),
    addIcon: Icons.add_rounded,
  ),
);

// Disable custom GoLive screen configuration (use SDK default)
IsmLiveApp.updateGoLiveScreenConfigure(null);

// Legacy individual updates (still supported)
IsmLiveApp.updateGoLiveHeaderBuilder((context, controller) => CustomHeader());
IsmLiveApp.updateGoLiveButtonBuilder((context, controller, onGoLivePressed, isEnabled) => 
    CustomButton(onPressed: isEnabled ? onGoLivePressed : null));
```

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
| Custom GoLive Screen   | `IsmLiveGoLiveScreenConfigure`  | Customize GoLive screen header and button |
| Custom Heart Messages  | `heartMessageCallback`    | Handle heart messages with your own API |
| Custom Analytics      | `streamAnalyticsCallback` | Handle stream analytics with your own API |
| Custom Viewers Analytics | `streamAnalyticsViewersCallback` | Handle stream viewers analytics with your own API |

---

For more details, see the API documentation or contact support.

## Platform-Specific Setup

The SDK requires platform-specific configuration for different operating systems. Please follow the setup guides for your target platforms:

- **[Android Setup](./README_android.md)** - Android-specific configuration including permissions, manifest changes, and build settings
- **[iOS Setup](./README_ios.md)** - iOS-specific configuration including Info.plist, Podfile, and background modes
- **[Web Setup](./README_web.md)** - Web-specific configuration including HTML setup and Google Maps integration

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
