# Live Stream Flutter SDK

A comprehensive Flutter SDK for integrating live streaming capabilities into your mobile applications. Built with Flutter and GetX, this SDK provides everything you need to add live streaming, e-commerce integration, analytics, and real-time interactions to your app.

## Table of Contents

- [Features](#features)
- [Installation](#installation)
- [Quick Start](#quick-start)
- [Configuration](#configuration)
- [API Reference](#api-reference)
- [Platform Setup](#platform-setup)
- [Examples](#examples)
- [Troubleshooting](#troubleshooting)

---

## Features

- 🎥 **Live Streaming**: Start, join, and manage live streams
- 💬 **Real-time Chat**: Interactive chat with emoji support
- 🛍️ **E-commerce Integration**: Product linking, shopping cart, and purchase flows
- 📊 **Analytics**: Stream analytics with viewer tracking
- 🎁 **Gifts & Interactions**: Send gifts, hearts, and engage with streams
- 👥 **Multi-user Features**: PK battles, co-publishing, multi-live
- 🎨 **Customizable UI**: Extensive customization options for all components
- 📱 **Cross-platform**: Android, iOS, and Web support
- 🔔 **Notifications**: Real-time notifications and updates
- 🎬 **Stream Recording**: Play recorded streams with product integration

---

## Installation

Add the SDK to your `pubspec.yaml`:

```yaml
dependencies:
  appscrip_live_stream_component:
    git:
      url: https://github.com/your-repo/live-stream-flutter.git
      ref: feature/dependency
```

Then run:

```bash
flutter pub get
```

---

## Quick Start

The SDK provides two ways to get started:

### Option 1: Plug-and-Play (Recommended for Quick Start)

The `IsmLiveApp` widget handles initialization automatically. Simply add it to your widget tree:

```dart
import 'package:appscrip_live_stream_component/appscrip_live_stream_component.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: IsmLiveApp(
        configuration: IsmLiveConfigData(
          baseUrl: 'https://your-api.com',
          userId: 'user123',
          // ... other required fields
        ),
        navigatorKey: navigatorKey,
      ),
    );
  }
}
```

**Note**: The `IsmLiveApp` widget automatically calls `IsmLiveApp.initialize()` internally, so you don't need to initialize manually. The widget shows a loading indicator during initialization and displays the default stream listing UI when ready.

### Option 2: Manual Initialization (Advanced Usage)

If you need more control over initialization timing or want to use individual SDK widgets:

```dart
import 'package:appscrip_live_stream_component/appscrip_live_stream_component.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize SDK manually
  await IsmLiveApp.initialize(
    IsmLiveConfigData(
      baseUrl: 'https://your-api.com',
      userId: 'user123',
      // ... other required fields
    ),
    navigatorKey: navigatorKey,
  );
  
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: IsmLiveStreamListing(), // Use SDK widgets directly
    );
  }
}
```

**When to use manual initialization:**
- You need to initialize the SDK before showing any UI
- You want to use individual SDK widgets instead of the default UI
- You need to control initialization timing for better app startup performance

---

## Configuration

The SDK provides extensive configuration options through `IsmLiveApp.configureInterface()`. Configure once at app startup or update dynamically at runtime.

### Core Configuration

```dart
IsmLiveApp.configureInterface(
  // Core settings
  productionMode: true,
  fontFamily: 'Roboto',
  
  // UI customization
  showHeader: true,
  streamHeader: (context) => CustomHeader(),
);
```

### Complete Configuration Example

```dart
IsmLiveApp.configureInterface(
  // ===== CORE CONFIGURATION =====
  productionMode: true,
  fontFamily: 'YourCustomFont',
  
  // ===== GO LIVE SCREEN =====
  goLiveScreenConfigure: IsmLiveGoLiveScreenConfigure(
    goLiveHeaderBuilder: (context, controller) => CustomGoLiveHeader(),
    goLiveButtonBuilder: (context, controller, onGoLivePressed, isEnabled) => 
        CustomGoLiveButton(
          onPressed: isEnabled ? onGoLivePressed : null,
          isEnabled: isEnabled,
        ),
    radioTileTextStyle: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
    addCoverTextStyle: TextStyle(fontSize: 14, color: Colors.grey[600]),
  ),
  
  // ===== STREAM INTERACTIONS =====
  onGoLiveClick: (context, isScheduledStream, streamDetails, goLiveData) async {
    // Handle GoLive button click
    print('Stream Title: ${goLiveData.title}');
    return true; // Return true to proceed
  },
  
  streamDisconnectApiHandler: (streamId, disconnectType) async {
    // Replace SDK's default disconnect API
    await myApi.disconnectStream(streamId, disconnectType);
    return true;
  },
  
  // ===== CONTROL SYSTEM =====
  controlWidgetBuilder: (context, option, onTap, isHost, isCopublishing, streamId) {
    // Replace specific control buttons
    if (option == IsmLiveStreamOption.gift) {
      return CustomGiftButton(onTap: onTap);
    }
    return null; // Use default
  },
  
  controlOptionCallback: (context, option, streamId, isHost, isCopublishing) async {
    // Handle all control option taps
    if (option == IsmLiveStreamOption.gift) {
      await _handleCustomGift();
      return true; // Handled
    }
    return false; // Use default
  },
  
  // ===== E-COMMERCE =====
  ecomConfigure: IsmLiveEcomConfigure(
    pinItemCallback: (direction) {
      // Handle product navigation
      if (direction == IsmLiveArrowDirection.previous) {
        _navigateToPreviousProduct();
      } else {
        _navigateToNextProduct();
      }
    },
    buyNowCallback: () {
      // Handle purchase
      _showPurchaseDialog();
    },
  ),
  
  // ===== ANALYTICS =====
  streamAnalyticsApiHandler: (streamId, isHost) async {
    // Replace SDK's analytics API
    final data = await myApi.getStreamAnalytics(streamId);
    return IsmLiveStreamAnalyticsModel(
      totalViewersCount: data['viewers'] ?? 0,
      hearts: data['hearts'] ?? 0,
      // ... other fields
    );
  },
  
  streamAnalyticsViewersApiHandler: (streamId, skip, limit) async {
    // Replace SDK's viewers API
    final viewers = await myApi.getStreamViewers(streamId, skip, limit);
    return viewers.map((v) => IsmLiveAnalyticViewerModel(
      userName: v['userName'],
      profilePic: v['profilePic'],
      // ... other fields
    )).toList();
  },
  
  // ===== CHAT CUSTOMIZATION =====
  chatItemBgColorCallback: (message) {
    // Customize chat background colors
    if (message.sentByHost) {
      return Colors.purple.withOpacity(0.4);
    }
    return null; // Use default
  },
  
  chatMessageBuilder: (context, message, defaultChild) {
    // Full chat message customization
    return Container(
      margin: EdgeInsets.only(left: message.sentByHost ? 0 : 20),
      child: defaultChild,
    );
  },
  
  // ===== UI COMPONENTS =====
  cartBuilder: (context, controller) {
    return CustomCartWidget(
      itemCount: _getCartItemCount(controller.streamId ?? ''),
    );
  },
  
  attentionDialogButtonCallback: (context) async {
    // Handle stream end dialog
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => HomeScreen()),
    );
  },
  
  // ===== STREAM EVENTS =====
  onStreamScrollCallback: (context, currentStreamId, nextStreamIndex, nextStream, isHost) {
    // Notification when user scrolls to different stream
    _trackStreamScrollEvent(currentStreamId, nextStreamIndex);
  },
  
  streamListingRefreshCallback: (eventType, streamId, payload) {
    // Handle stream listing refresh events
    if (eventType == 'streamStartPresence') {
      myStreamListingController.refresh();
    }
  },
);
```

---

## API Reference

### Initialization

#### `IsmLiveApp.initialize()`

Initialize the SDK manually. **Only required if you're not using the `IsmLiveApp` widget** (which handles initialization automatically).

```dart
await IsmLiveApp.initialize(
  IsmLiveConfigData(
    baseUrl: 'https://your-api.com',
    userId: 'user123',
    // ... other config
  ),
  navigatorKey: navigatorKey,
);
```

**Note**: If you're using the `IsmLiveApp` widget, initialization happens automatically - you don't need to call this method separately.

#### `IsmLiveApp.isInitialized`

Check if SDK is initialized.

```dart
if (IsmLiveApp.isInitialized) {
  // SDK is ready
}
```

### Configuration Methods

#### `IsmLiveApp.configureInterface()`

Configure SDK behavior and customization options. See [Configuration](#configuration) section for details.

#### `IsmLiveApp.update*()` Methods

Update specific configurations at runtime:

```dart
// Update control callback
IsmLiveApp.updateControlOptionCallback((context, option, streamId, isHost, isCopublishing) async {
  // New handler
  return false;
});

// Update analytics handler
IsmLiveApp.updateStreamAnalyticsApiHandler((streamId, isHost) async {
  // New handler
  return null;
});

// Update cart builder
IsmLiveApp.updateCartBuilder((context, controller) {
  return CustomCartWidget();
});

// Disable custom handlers (use SDK defaults)
IsmLiveApp.updateControlOptionCallback(null);
IsmLiveApp.updateStreamAnalyticsApiHandler(null);
IsmLiveApp.updateCartBuilder(null);
```

### Widgets

#### `IsmLiveApp`

Plug-and-play widget that **automatically handles initialization** and displays default UI. This widget calls `IsmLiveApp.initialize()` internally, so manual initialization is not required.

```dart
IsmLiveApp(
  configuration: IsmLiveConfigData(...),
  navigatorKey: navigatorKey,
  onCallStart: () => print('Call started'),
  onCallEnd: () => print('Call ended'),
  enableLog: true,
  onLogout: () => print('User logged out'),
)
```

**Behavior:**
- Shows a loading indicator (`CircularProgressIndicator`) during initialization
- Automatically calls `IsmLiveApp.initialize()` with the provided configuration
- Displays `IsmLiveStreamListing()` once initialization is complete
- No need to call `IsmLiveApp.initialize()` separately when using this widget

#### `IsmLiveStreamListing()`

Display list of live streams.

```dart
IsmLiveStreamListing()
```

### Callbacks Reference

| Callback | Purpose | Parameters | Return Type |
|----------|---------|------------|-------------|
| `onGoLiveClick` | Handle GoLive button click | `context, isScheduledStream, streamDetails, goLiveData` | `Future<bool>` |
| `streamDisconnectApiHandler` | Replace disconnect API | `streamId, disconnectType` | `Future<bool>` |
| `controlOptionCallback` | Handle control option taps | `context, option, streamId, isHost, isCopublishing` | `Future<bool>` |
| `controlWidgetBuilder` | Replace control widgets | `context, option, onTap, isHost, isCopublishing, streamId` | `Widget?` |
| `streamAnalyticsApiHandler` | Replace analytics API | `streamId, isHost` | `Future<IsmLiveStreamAnalyticsModel?>` |
| `streamAnalyticsViewersApiHandler` | Replace viewers API | `streamId, skip, limit` | `Future<List<IsmLiveAnalyticViewerModel>?>` |
| `chatItemBgColorCallback` | Customize chat colors | `message` | `Color?` |
| `chatMessageBuilder` | Customize chat UI | `context, message, defaultChild` | `Widget` |
| `cartBuilder` | Customize cart widget | `context, controller` | `Widget` |
| `attentionDialogButtonCallback` | Handle stream end dialog | `context` | `Future<void>` |
| `onStreamScrollCallback` | Stream scroll notification | `context, currentStreamId, nextStreamIndex, nextStream, isHost` | `void` |
| `pinItemCallback` | Product navigation | `direction` | `void` |
| `buyNowCallback` | Purchase flow | - | `void` |

### Enums

#### `IsmLiveStreamOption`

Control options available in streams:
- `gift` - Send gifts
- `share` - Share stream
- `heart` - Send hearts
- `members` - View analytics/members
- `settings` - Stream settings
- `multiLive` - Multi-live features
- `pk` - PK battle
- `copublish` - Co-publishing

#### `IsmLiveStreamDisconnectType`

Disconnect types:
- `host` - Host ending stream
- `viewer` - Viewer leaving
- `pkGuest` - PK guest leaving
- `copublisher` - Co-publisher leaving

#### `IsmLiveArrowDirection`

Product navigation:
- `previous` - Previous product
- `next` - Next product

---

## Platform Setup

### Android

See [Android Setup Guide](./README_android.md) for:
- Required permissions
- Manifest configuration
- Foreground service setup
- Build configuration

### iOS

See [iOS Setup Guide](./README_ios.md) for:
- Info.plist configuration
- Podfile setup
- Background modes
- Permissions

### Web

See [Web Setup Guide](./README_web.md) for:
- HTML configuration
- Google Maps integration
- Web-specific setup

---

## Examples

### Minimal Configuration

```dart
IsmLiveApp.configureInterface(
  productionMode: true,
  fontFamily: 'Roboto',
);
```

### Custom Control Handling

```dart
IsmLiveApp.configureInterface(
  controlOptionCallback: (context, option, streamId, isHost, isCopublishing) async {
    switch (option) {
      case IsmLiveStreamOption.gift:
        await _showCustomGiftDialog(context);
        return true; // Handled
      case IsmLiveStreamOption.share:
        await _shareWithCustomService(streamId);
        return true; // Handled
      default:
        return false; // Use SDK default
    }
  },
);
```

### Custom Analytics

```dart
IsmLiveApp.configureInterface(
  streamAnalyticsApiHandler: (streamId, isHost) async {
    try {
      final data = await myAnalyticsService.getStreamData(streamId);
      return IsmLiveStreamAnalyticsModel(
        totalViewersCount: data.viewers,
        hearts: data.hearts,
        followers: data.followers,
        totalEarning: data.earnings,
        duration: data.duration,
        productCount: data.products,
      );
    } catch (e) {
      return null; // Use SDK default on error
    }
  },
);
```

### E-commerce Integration

```dart
IsmLiveApp.configureInterface(
  ecomConfigure: IsmLiveEcomConfigure(
    pinItemCallback: (direction) {
      _analyticsService.trackEvent('product_navigation', {
        'direction': direction.name,
      });
      _productController.navigate(direction);
    },
    buyNowCallback: () {
      Navigator.of(context).push(
        MaterialPageRoute(builder: (context) => CheckoutScreen()),
      );
    },
  ),
);
```

### Chat Customization

```dart
IsmLiveApp.configureInterface(
  // Simple color customization
  chatItemBgColorCallback: (message) {
    if (message.sentByHost) return Colors.purple.withOpacity(0.4);
    if (message.sentByMe) return Colors.green.withOpacity(0.3);
    return null; // Default
  },
  
  // Advanced UI customization
  chatMessageBuilder: (context, message, defaultChild) {
    if (message.sentByHost) {
      return Container(
        decoration: BoxDecoration(
          border: Border.all(color: Colors.amber, width: 2),
          borderRadius: BorderRadius.circular(12),
        ),
        child: defaultChild,
      );
    }
    return defaultChild;
  },
);
```

---

## Troubleshooting

### SDK Not Initializing

**Problem**: `IsmLiveApp.isInitialized` returns `false`

**Solution**:
- If using `IsmLiveApp` widget: Wait for initialization to complete (widget shows loading indicator)
- If using manual initialization: Ensure `IsmLiveApp.initialize()` is called and awaited before using SDK widgets
- Check that all required configuration fields are provided
- Verify network connectivity
- Check SDK logs for initialization errors

### Stream Not Starting

**Problem**: Stream fails to start

**Solution**:
- Check camera and microphone permissions
- Verify network connection
- Ensure `onGoLiveClick` callback returns `true` if implemented
- Check SDK logs for error messages

### Custom Callbacks Not Working

**Problem**: Custom callbacks not being called

**Solution**:
- Verify `configureInterface()` is called before using SDK features
- Check callback return values (some require `true` to proceed)
- Ensure callbacks are not set to `null`

### Analytics Not Loading

**Problem**: Analytics data not showing

**Solution**:
- If using custom `streamAnalyticsApiHandler`, ensure it returns valid `IsmLiveStreamAnalyticsModel`
- Check API endpoint connectivity
- Verify `streamId` is correct
- Return `null` from handler to use SDK default

### Platform-Specific Issues

- **Android**: See [Android Setup Guide](./README_android.md)
- **iOS**: See [iOS Setup Guide](./README_ios.md)
- **Web**: See [Web Setup Guide](./README_web.md)

---

## Additional Resources

- [Android Setup](./README_android.md) - Android-specific configuration
- [iOS Setup](./README_ios.md) - iOS-specific configuration
- [Web Setup](./README_web.md) - Web-specific configuration
- [Stream Recording Player Spec](./SDK_STREAM_RECORDING_PLAYER_SPEC.md) - Stream recording player documentation

---

## Support

For issues, questions, or contributions, please contact support or visit the project repository.

---

## License

See [LICENSE](./LICENSE) file for details.
