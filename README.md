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
// In your app's startup logic (e.g., landing screen):
await IsmLiveApp.initialize(myConfig, navigatorKey: myNavKey);

// Later, in your widget tree, use any SDK widget:
IsmLiveStreamListing()
// or any other SDK-provided widget/feature
```

- This approach gives you full control over when and how to show SDK screens.
- You can use any SDK widget after initialization.

---

### 3. Complete Configuration Reference

The SDK provides a comprehensive `configureInterface` method that allows you to customize all aspects of the live streaming experience. Here's the complete configuration with all available options:

```dart
IsmLiveApp.configureInterface(
  // ===== CORE CONFIGURATION =====
  productionMode: true,
  fontFamily: 'YourCustomFont',
  
  // ===== GO LIVE SCREEN CUSTOMIZATION =====
  goLiveScreenConfigure: IsmLiveGoLiveScreenConfigure(
    goLiveHeaderBuilder: (context, controller) => CustomGoLiveHeader(),
    goLiveButtonBuilder: (context, controller, onGoLivePressed, isEnabled) => 
        CustomGoLiveButton(
          onPressed: isEnabled ? onGoLivePressed : null,
          isEnabled: isEnabled,
        ),
    radioTileTextStyle: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
    addCoverTextStyle: TextStyle(fontSize: 14, color: Colors.grey[600]),
    addProductTextStyle: TextStyle(fontSize: 14, color: Colors.blue),
    addIcon: Icons.add_box_rounded,
    // ... other GoLive screen customizations
  ),
  
  // ===== STREAM INTERACTION CALLBACKS =====
  onGoLiveClick: (context, isScheduledStream, streamDetails, goLiveData) async {
    // Handle GoLive button click with full data access
    print('Stream Title: ${goLiveData.title}');
    print('Selected Products: ${goLiveData.selectedProductsList.length}');
    return true; // Return true to proceed with stream creation
  },
  
  streamDisconnectApiHandler: (streamId, disconnectType) async {
    // Replace SDK's default disconnect API with your own implementation
    print('Disconnecting from stream: $streamId as ${disconnectType.name}');
    
    // Call your custom backend API
    switch (disconnectType) {
      case IsmLiveStreamDisconnectType.host:
        await myApi.endStream(streamId);
        break;
      case IsmLiveStreamDisconnectType.viewer:
        await myApi.leaveStream(streamId);
        break;
      case IsmLiveStreamDisconnectType.pkGuest:
        await myApi.leavePkBattle(streamId);
        break;
      case IsmLiveStreamDisconnectType.copublisher:
        await myApi.stopCopublishing(streamId);
        break;
    }
    
    return true; // Return true to proceed with SDK cleanup
  },
  
  // ===== CONTROL SYSTEM CALLBACKS =====
  controlWidgetBuilder: (context, option, onTap, isHost, isCopublishing, streamId) {
    // Replace specific control buttons with custom widgets
    if (option == IsmLiveStreamOption.gift) {
      return CustomGiftButton(onTap: onTap);
    }
    return null; // Use default widget
  },
  
  controlOptionCallback: (context, option, streamId, isHost, isCopublishing) async {
    // Handle all control option taps with unified callback
    if (option == IsmLiveStreamOption.gift) {
      // Custom gift handling logic
      _handleCustomGiftAction();
      return true; // Handled by custom logic
    }
    return false; // Use default SDK behavior
  },
  
  // ===== E-COMMERCE CALLBACKS =====
  ecomConfigure: IsmLiveEcomConfigure(
    pinItemCallback: (direction) {
      // Handle host arrow button clicks
      if (direction == IsmLiveArrowDirection.previous) {
        _navigateToPreviousProduct();
      } else {
        _navigateToNextProduct();
      }
    },
    buyNowCallback: () {
      // Handle "Buy now" button clicks
      _showPurchaseDialog();
    },
    // ... other e-commerce configurations
  ),
  
  // ===== ANALYTICS API HANDLERS =====
  streamAnalyticsApiHandler: (streamId, isHost) async {
    // Replace SDK's analytics API with your own backend call
    final analyticsData = await myApi.getStreamAnalytics(streamId);
    return IsmLiveStreamAnalyticsModel(
      totalViewersCount: analyticsData['viewers'] ?? 0,
      hearts: analyticsData['hearts'] ?? 0,
      followers: analyticsData['followers'] ?? 0,
      totalEarning: analyticsData['earning'] ?? 0,
      duration: analyticsData['duration'] ?? 0,
      productCount: analyticsData['products'] ?? 0,
    );
  },
  
  streamAnalyticsViewersApiHandler: (streamId, skip, limit) async {
    // Replace SDK's analytics viewers API with your own backend call
    final viewersData = await myApi.getStreamViewers(streamId, skip, limit);
    return viewersData.map((viewer) => IsmLiveAnalyticViewerModel(
      userName: viewer['userName'],
      profilePic: viewer['profilePic'],
      isometrikUserId: viewer['isometrikUserId'],
      appUserId: viewer['appUserId'],
      firstName: viewer['firstName'],
      lastName: viewer['lastName'],
      timestamp: viewer['timestamp'],
    )).toList();
  },
  
  // Hearts are handled via unified controlOptionCallback using IsmLiveStreamOption.heart
  
  // ===== UI CUSTOMIZATION CALLBACKS =====
  cartBuilder: (context, controller) {
    // Customize shopping cart widget
    return CustomCartWidget(
      onTap: () => _navigateToCart(),
      itemCount: _getCartItemCount(controller.streamId ?? ''),
    );
  },
  
  attentionDialogButtonCallback: (context) async {
    // Handle attention dialog button clicks
    _navigateToCustomScreen();
  },
  
  // ===== ADDITIONAL UI OPTIONS =====
  showHeader: true,
  streamHeader: (context) => CustomHeader(),
  // ... more options
);
```

#### Complete Callbacks Reference Table

| **Category** | **Callback** | **Parameters** | **Purpose** | **Return Type** |
|-------------|--------------|----------------|-------------|-----------------|
| **Core Configuration** | `productionMode` | `bool` | Enable/disable production mode | - |
| | `fontFamily` | `String` | Custom font family for all text | - |
| **GoLive Screen** | `goLiveScreenConfigure` | `IsmLiveGoLiveScreenConfigure` | Customize GoLive screen appearance | - |
| **Stream Interaction** | `onGoLiveClick` | `context, isScheduledStream, streamDetails, goLiveData` | Handle GoLive button clicks | `Future<bool>` |
| | `streamDisconnectApiHandler` | `streamId, disconnectType` | Replace SDK's default disconnect API with custom implementation | `Future<bool>` |
| **Control System** | `controlWidgetBuilder` | `context, option, onTap, isHost, isCopublishing, streamId` | Replace control buttons with custom widgets | `Widget?` |
| | `controlOptionCallback` | `context, option, streamId, isHost, isCopublishing` | Handle all control option taps | `Future<bool>` |
| **E-commerce** | `pinItemCallback` | `direction` | Handle host arrow button clicks | `void` |
| | `buyNowCallback` | - | Handle "Buy now" button clicks | `void` |
| **Analytics** | `streamAnalyticsApiHandler` | `streamId, isHost` | Replace SDK's analytics API with custom implementation | `Future<IsmLiveStreamAnalyticsModel?>` |
| | `streamAnalyticsViewersApiHandler` | `streamId, skip, limit` | Replace SDK's analytics viewers API with custom implementation | `Future<List<IsmLiveAnalyticViewerModel>?>` |
| **Heart Messages** | `controlOptionCallback` | `context, option, streamId, isHost, isCopublishing` | Handle heart interactions (`IsmLiveStreamOption.heart`) | `Future<bool>` |
| **UI Customization** | `cartBuilder` | `context, controller` | Customize shopping cart widget | `Widget` |
| | `attentionDialogButtonCallback` | `context` | Handle attention dialog button clicks | `Future<void>` |
| | `showHeader` | `bool` | Show/hide stream header | - |
| | `streamHeader` | `context` | Custom stream header widget | `Widget` |

#### Quick Start Examples

**Minimal Configuration:**
```dart
IsmLiveApp.configureInterface(
  productionMode: true,
  fontFamily: 'Roboto',
);
```

**Basic Customization:**
```dart
IsmLiveApp.configureInterface(
  productionMode: true,
  controlOptionCallback: (context, option, streamId, isHost, isCopublishing) async {
    if (option == IsmLiveStreamOption.gift) {
      _handleCustomGift();
      return true; // Handled by custom logic
    }
    return false; // Use default behavior
  },
  streamAnalyticsApiHandler: (streamId, isHost) async {
    return await myApi.getStreamAnalytics(streamId);
  },
);
```

**Advanced E-commerce Setup:**
```dart
IsmLiveApp.configureInterface(
  productionMode: true,
  ecomConfigure: IsmLiveEcomConfigure(
    pinItemCallback: (direction) => _navigateProduct(direction),
    buyNowCallback: () => _showCheckout(),
  ),
  controlOptionCallback: (context, option, streamId, isHost, isCopublishing) async {
    // Handle all control interactions
    return await _handleControlOption(option);
  },
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
    radioTileTextStyle: (context, isDark) => TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w500,
      color: isDark ? Colors.white : Colors.black87,
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
- **`radioTileTextStyle`**: Function-based text style for radio tiles that receives context and isDark parameter for theme-aware styling
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
  
- **`streamDisconnectApiHandler`**: API handler to replace SDK's default disconnect endpoints
  - Parameters: `streamId`, `disconnectType` (IsmLiveStreamDisconnectType enum)
  - Disconnect types: `host`, `viewer`, `pkGuest`, `copublisher`
  - Return `true` if your API call succeeded (SDK proceeds with cleanup), `false` if failed (SDK aborts disconnect)
  - **Purpose**: Replace the SDK's default disconnect API calls with your own backend implementation
  - If not set, SDK uses its default disconnect APIs:
    - For `host`: calls SDK's `stopStream` API
    - For `viewer`: calls SDK's `leaveStream` API
    - For `pkGuest`: calls SDK's `pkEnd` operation
    - For `copublisher`: calls SDK's `leaveMember` operation

Deprecated: `heartMessageCallback` has been removed. Use `controlOptionCallback` with `IsmLiveStreamOption.heart` instead.
  - Parameters: `streamId`, `userId`, `userName`, `userImage`, `deviceId`, `customType`
  - Return `true` if your app successfully handled the heart message, `false` to let SDK handle with default implementation
  - Useful for custom heart message APIs, analytics tracking, user validation, rate limiting, etc.
  - If not set, SDK uses default heart message handling

- **`streamAnalyticsApiHandler`**: API handler to replace SDK's default analytics endpoint
  - Parameters: `streamId`, `isHost` (bool)
  - Return `IsmLiveStreamAnalyticsModel` if your API call was successful with analytics data, `null` to let SDK use its default
  - **Purpose**: Replace the SDK's default analytics API calls with your own backend implementation
  - If not set, SDK uses its default analytics API endpoint
  - Useful for custom analytics APIs, real-time analytics integration, custom analytics processing, etc.

- **`streamAnalyticsViewersApiHandler`**: API handler to replace SDK's default analytics viewers endpoint
  - Parameters: `streamId`, `skip`, `limit`
  - Return `List<IsmLiveAnalyticViewerModel>` if your API call was successful with viewers data, `null` to let SDK use its default
  - **Purpose**: Replace the SDK's default analytics viewers API calls with your own backend implementation
  - If not set, SDK uses its default analytics viewers API endpoint
  - Useful for custom analytics viewers APIs, real-time viewers data integration, custom viewers data processing, etc.


- **`controlOptionCallback`**: Unified callback for handling any control option tap
  - Parameters: `context`, `option`, `streamId`, `isHost`, `isCopublishing`
  - Return `true` if your app successfully handled the control action, `false` to let SDK handle with default implementation
  - Useful for custom control button functionality, integration with external services, custom permission checks, etc.
  - If not set, SDK uses default control behavior

- **`controlWidgetBuilder`**: Builder for custom control widgets
  - Parameters: `context`, `option`, `onTap`, `isHost`, `isCopublishing`, `streamId`
  - Return a custom Widget or `null` to use the default widget
  - Useful for replacing specific control buttons with custom designs, branding, or functionality
  - If not set, SDK uses default control widgets

- **`attentionDialogButtonCallback`**: Called when the "Okay" button is tapped in the stream end attention dialog
  - Parameters: `context`
  - Return `true` if your app successfully handled the attention dialog action, `false` to let SDK handle with default implementation
  - Useful for custom navigation after stream ends, custom analytics tracking, integration with host app's navigation flow, etc.
  - If not set, SDK uses default dialog dismissal behavior
  - Note: The dialog will be closed automatically regardless of the callback result

#### Attention Dialog Button Callback Examples

**Basic Usage:**
```dart
IsmLiveApp.configureInterface(
  attentionDialogButtonCallback: (context) async {
    // Custom navigation after stream ends
    print('Stream ended');
    
    // Navigate to your app's home screen or stream listing
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => YourHomeScreen()),
      (route) => false,
    );
    
    // Return true to indicate we handled the action
    return true;
  },
);
```

**Advanced Usage with Analytics:**
```dart
IsmLiveApp.configureInterface(
  attentionDialogButtonCallback: (context) async {
    try {
      // Track stream end analytics
      await _analyticsService.trackEvent('stream_ended', {
        'timestamp': DateTime.now().toIso8601String(),
      });
      
      // Show feedback dialog before navigating
      final shouldShowFeedback = await _shouldShowFeedbackDialog();
      if (shouldShowFeedback) {
        await _showFeedbackDialog(context);
      }
      
      // Navigate to appropriate screen based on user preferences
      await _navigateToNextScreen(context);
      
      return true; // Host app handled successfully
    } catch (e) {
      print('Error handling stream end: $e');
      // Fall back to default behavior
      return false;
    }
  },
);
```

**Integration with Host App Flow:**
```dart
IsmLiveApp.configureInterface(
  attentionDialogButtonCallback: (context) async {
    // Check if user has uncompleted purchases
    final hasUncompletedPurchases = await _checkUncompletedPurchases();
    
    if (hasUncompletedPurchases) {
      // Navigate to checkout screen
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => CheckoutScreen(),
        ),
      );
    } else {
      // Navigate to stream history or recommendations
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => StreamHistoryScreen(),
        ),
      );
    }
    
    return true; // Host app handled the navigation
  },
);
```

**Dynamic Updates:**
```dart
// Update attention dialog callback at runtime
IsmLiveApp.updateAttentionDialogButtonCallback((context) async {
  // New attention dialog handling
  await _newStreamEndHandler(context);
  return true;
});

// Disable custom attention dialog handling (use SDK default)
IsmLiveApp.updateAttentionDialogButtonCallback(null);
```

#### Cart Builder

- **`cartBuilder`**: Custom widget builder for shopping cart icon in stream header
  - Parameters: `context`, `controller`
  - Return a Widget that will be displayed as the shopping cart in the stream header
  - Useful for custom cart icon design, cart item count display, integration with host app's shopping cart system, etc.
  - If not set, SDK uses default cart icon (only shows when user is not host and stream has products linked)

#### Cart Builder Examples

**Basic Usage:**
```dart
IsmLiveApp.configureInterface(
  cartBuilder: (context, controller) {
    return Container(
      padding: EdgeInsets.all(8),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white24,
      ),
      child: Icon(
        Icons.shopping_cart_rounded,
        color: Colors.white,
        size: 16,
      ),
    );
  },
);
```

**Advanced Usage with Cart Count:**
```dart
IsmLiveApp.configureInterface(
  cartBuilder: (context, controller) {
    // Get cart count from your app's cart system
    final cartCount = _getCartItemCount(controller.streamId ?? '');
    
    return Stack(
      children: [
        Container(
          padding: EdgeInsets.all(8),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white24,
          ),
          child: Icon(
            Icons.shopping_cart_rounded,
            color: Colors.white,
            size: 16,
          ),
        ),
        if (cartCount > 0)
          Positioned(
            right: 0,
            top: 0,
            child: Container(
              padding: EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Colors.red,
                shape: BoxShape.circle,
              ),
              child: Text(
                cartCount.toString(),
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
      ],
    );
  },
);
```

**Integration with Host App Cart System:**
```dart
IsmLiveApp.configureInterface(
  cartBuilder: (context, controller) {
    return GestureDetector(
      onTap: () {
        // Navigate to your app's cart screen
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => YourCartScreen(
              streamId: controller.streamId ?? '',
            ),
          ),
        );
      },
      child: StreamBuilder<List<CartItem>>(
        stream: _cartService.getCartItemsStream(controller.streamId ?? ''),
        builder: (context, snapshot) {
          final cartCount = snapshot.data?.length ?? 0;
          
          return Container(
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: cartCount > 0 ? Colors.orange : Colors.white24,
            ),
            child: Stack(
              children: [
                Icon(
                  Icons.shopping_cart_rounded,
                  color: Colors.white,
                  size: 16,
                ),
                if (cartCount > 0)
                  Positioned(
                    right: -2,
                    top: -2,
                    child: Container(
                      padding: EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                      constraints: BoxConstraints(
                        minWidth: 12,
                        minHeight: 12,
                      ),
                      child: Text(
                        cartCount.toString(),
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 8,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  },
);
```

**Dynamic Updates:**
```dart
// Update cart builder at runtime
IsmLiveApp.updateCartBuilder((context, controller) {
  // New cart implementation
  return CustomCartWidget(controller: controller);
});

// Disable custom cart builder (use SDK default)
IsmLiveApp.updateCartBuilder(null);
```


#### Stream Disconnect API Handler Examples

**Basic Usage:**
```dart
IsmLiveApp.configureInterface(
  streamDisconnectApiHandler: (streamId, disconnectType) async {
    // Replace SDK's API with your own backend call
    print('Disconnecting: $streamId as ${disconnectType.name}');
    
    switch (disconnectType) {
      case IsmLiveStreamDisconnectType.host:
        await myApi.endStream(streamId);
        break;
      case IsmLiveStreamDisconnectType.viewer:
        await myApi.leaveStream(streamId);
        break;
      case IsmLiveStreamDisconnectType.pkGuest:
        await myApi.leavePkBattle(streamId);
        break;
      case IsmLiveStreamDisconnectType.copublisher:
        await myApi.stopCopublishing(streamId);
        break;
    }
    
    return true; // Success - SDK proceeds with cleanup
  },
);
```

**Advanced Usage with Error Handling:**
```dart
IsmLiveApp.configureInterface(
  streamDisconnectApiHandler: (streamId, disconnectType) async {
    try {
      // Call your unified disconnect API
      final response = await myApi.disconnectStream(
        streamId: streamId,
        type: disconnectType.name,
      );
      
      if (response.success) {
        print('Successfully disconnected as ${disconnectType.name}');
        return true; // Proceed with SDK cleanup
      } else {
        print('Disconnect failed: ${response.error}');
        return false; // Abort disconnect
      }
    } catch (e) {
      print('Error during disconnect: $e');
      return false; // Abort on error
    }
  },
);
```

**With Analytics Tracking:**
```dart
IsmLiveApp.configureInterface(
  streamDisconnectApiHandler: (streamId, disconnectType) async {
    // Track disconnect event
    _analyticsService.trackEvent('stream_disconnect', {
      'stream_id': streamId,
      'disconnect_type': disconnectType.name,
      'timestamp': DateTime.now().toIso8601String(),
    });
    
    // Different handling per disconnect type
    switch (disconnectType) {
      case IsmLiveStreamDisconnectType.host:
        // Save stream statistics before ending
        await _saveStreamStats(streamId);
        await myApi.endStream(streamId);
        break;
        
      case IsmLiveStreamDisconnectType.viewer:
        // Track viewer session duration
        await _trackViewerSession(streamId);
        await myApi.leaveStream(streamId);
        break;
        
      case IsmLiveStreamDisconnectType.pkGuest:
        // Update PK battle status
        await myApi.updatePkStatus(streamId, 'guest_left');
        await myApi.leavePkBattle(streamId);
        break;
        
      case IsmLiveStreamDisconnectType.copublisher:
        // Notify host
        await myApi.notifyHost(streamId, 'copublisher_left');
        await myApi.stopCopublishing(streamId);
        break;
    }
    
    return true;
  },
);
```

**Retry Logic:**
```dart
IsmLiveApp.configureInterface(
  streamDisconnectApiHandler: (streamId, disconnectType) async {
    int maxRetries = 3;
    int retryCount = 0;
    
    while (retryCount < maxRetries) {
      try {
        await myApi.disconnectStream(streamId, disconnectType);
        return true; // Success
      } catch (e) {
        retryCount++;
        if (retryCount >= maxRetries) {
          print('Max retries reached');
          return false; // Failed after retries
        }
        await Future.delayed(Duration(seconds: 2));
      }
    }
    return false;
  },
);
```

#### Heart Handling via Unified Control Callback

**Basic Usage:**
```dart
IsmLiveApp.configureInterface(
  controlOptionCallback: (context, option, streamId, isHost, isCopublishing) async {
    if (option == IsmLiveStreamOption.heart) {
      final handled = await _callYourHeartMessageAPI(streamId);
      return handled; // true to prevent default, false to use SDK default
    }
    return false;
  },
);
```

**Advanced Usage with Validation:**
```dart
IsmLiveApp.configureInterface(
  controlOptionCallback: (context, option, streamId, isHost, isCopublishing) async {
    if (option == IsmLiveStreamOption.heart) {
      if (!_canUserSendHeart(_currentUserId)) return true; // block
      if (_isRateLimited(_currentUserId)) return true; // block
      return await _callYourHeartMessageAPI(streamId);
    }
    return false;
  },
);
```

**Premium User Handling:**
```dart
IsmLiveApp.configureInterface(
  controlOptionCallback: (context, option, streamId, isHost, isCopublishing) async {
    if (option == IsmLiveStreamOption.heart) {
      return _isPremiumUser(_currentUserId)
          ? await _handlePremiumHeartMessage(streamId)
          : await _handleRegularHeartMessage(streamId);
    }
    return false;
  },
);
```

**Dynamic Updates:**
```dart
// Update via unified control callback at runtime
IsmLiveApp.updateControlOptionCallback((context, option, streamId, isHost, isCopublishing) async {
  if (option == IsmLiveStreamOption.heart) {
    return await _newHeartMessageHandler(streamId);
  }
  return false;
});
```

#### Stream Analytics API Handler Examples

**Basic Usage:**
```dart
IsmLiveApp.configureInterface(
  streamAnalyticsApiHandler: (streamId, isHost) async {
    // Replace SDK's analytics API with your own backend call
    final analyticsData = await myApi.getStreamAnalytics(streamId);
    
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
  streamAnalyticsApiHandler: (streamId, isHost) async {
    try {
      // Call your real-time analytics service
      final realTimeData = await myApi.getRealTimeAnalytics(streamId, isHost);
      
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
// Update analytics API handler at runtime
IsmLiveApp.updateStreamAnalyticsApiHandler(_newAnalyticsHandler);

// Disable custom analytics (use SDK default)
IsmLiveApp.updateStreamAnalyticsApiHandler(null);
```

#### Stream Analytics Viewers API Handler Examples

**Basic Usage:**
```dart
IsmLiveApp.configureInterface(
  streamAnalyticsViewersApiHandler: (streamId, skip, limit) async {
    // Replace SDK's analytics viewers API with your own backend call
    final viewersData = await myApi.getStreamViewers(
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
  streamAnalyticsViewersApiHandler: (streamId, skip, limit) async {
    try {
      // Call your real-time viewers analytics service
      final realTimeViewersData = await myApi.getRealTimeViewers(
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
// Update viewers analytics API handler at runtime
IsmLiveApp.updateStreamAnalyticsViewersApiHandler(_newViewersAnalyticsHandler);

// Disable custom viewers analytics (use SDK default)
IsmLiveApp.updateStreamAnalyticsViewersApiHandler(null);
```

#### Control Customization Examples

**Basic Control Widget Replacement:**
```dart
IsmLiveApp.configureInterface(
  controlWidgetBuilder: (context, option, onTap, isHost, isCopublishing, streamId) {
    // Replace gift button with custom widget
    if (option == IsmLiveStreamOption.gift) {
      return Container(
        width: 50,
        height: 50,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.pink,
          boxShadow: [
            BoxShadow(
              color: Colors.pink.withOpacity(0.3),
              blurRadius: 8,
              spreadRadius: 2,
            ),
          ],
        ),
        child: IconButton(
          onPressed: onTap,
          icon: Icon(Icons.favorite, color: Colors.white),
        ),
      );
    }
    
    // Replace share button with custom widget
    if (option == IsmLiveStreamOption.share) {
      return Container(
        width: 50,
        height: 50,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.blue,
        ),
        child: IconButton(
          onPressed: onTap,
          icon: Icon(Icons.share, color: Colors.white),
        ),
      );
    }
    
    // Return null to use default widget for other options
    return null;
  },
);
```

**Advanced Control Widget with Branding:**
```dart
IsmLiveApp.configureInterface(
  controlWidgetBuilder: (context, option, onTap, isHost, isCopublishing, streamId) {
    // Custom branded gift button
    if (option == IsmLiveStreamOption.gift) {
      return Container(
        width: 50,
        height: 50,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: LinearGradient(
            colors: [Colors.purple, Colors.pink],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Stack(
          children: [
            IconButton(
              onPressed: onTap,
              icon: Icon(Icons.card_giftcard, color: Colors.white),
            ),
            Positioned(
              top: 8,
              right: 8,
              child: Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: Colors.yellow,
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ],
        ),
      );
    }
    
    // Custom analytics button with count badge
    if (option == IsmLiveStreamOption.members) {
      return Container(
        width: 50,
        height: 50,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.orange,
        ),
        child: Stack(
          children: [
            IconButton(
              onPressed: onTap,
              icon: Icon(Icons.analytics, color: Colors.white),
            ),
            Positioned(
              top: 8,
              right: 8,
              child: Container(
                padding: EdgeInsets.all(2),
                decoration: BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                ),
                child: Text(
                  '5', // Your analytics count
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    }
    
    return null; // Use default for other options
  },
);
```

**Unified Control Option Callback:**
```dart
IsmLiveApp.configureInterface(
  controlOptionCallback: (context, option, streamId, isHost, isCopublishing) async {
    // Handle gift button with custom logic
    if (option == IsmLiveStreamOption.gift) {
      // Check if user has enough coins
      final userCoins = await _getUserCoins();
      if (userCoins < 10) {
        _showInsufficientCoinsDialog(context);
        return true; // Handled, don't show default behavior
      }
      
      // Show custom gift selection
      await _showCustomGiftSelection(context, streamId);
      return true; // Handled
    }
    
    // Handle share with custom share service
    if (option == IsmLiveStreamOption.share) {
      await _shareWithCustomService(context, streamId, isHost);
      return true; // Handled
    }
    
    // Handle analytics with custom analytics screen
    if (option == IsmLiveStreamOption.members) {
      await _showCustomAnalyticsScreen(context, streamId, isHost);
      return true; // Handled
    }
    
    // Handle multi-live with custom permission check
    if (option == IsmLiveStreamOption.multiLive) {
      final canJoin = await _checkMultiLivePermission(isHost, isCopublishing);
      if (!canJoin) {
        _showPermissionDeniedDialog(context);
        return true; // Handled
      }
      // Let default behavior handle the rest
      return false;
    }
    
    // For all other options, use default behavior
    return false;
  },
);
```

**Combined Widget and Callback Usage:**
```dart
IsmLiveApp.configureInterface(
  // Custom widgets for specific options
  controlWidgetBuilder: (context, option, onTap, isHost, isCopublishing, streamId) {
    if (option == IsmLiveStreamOption.gift) {
      return MyCustomGiftButton(
        onTap: onTap,
        isHost: isHost,
        streamId: streamId,
      );
    }
    
    if (option == IsmLiveStreamOption.share) {
      return MyCustomShareButton(
        onTap: onTap,
        isHost: isHost,
        streamId: streamId,
      );
    }
    
    return null; // Use default for other options
  },
  
  // Unified callback for all option taps
  controlOptionCallback: (context, option, streamId, isHost, isCopublishing) async {
    // Custom analytics handling
    if (option == IsmLiveStreamOption.members) {
      await _showCustomAnalytics(context, streamId, isHost);
      return true; // Handled
    }
    
    // Custom settings handling
    if (option == IsmLiveStreamOption.settings) {
      await _showCustomSettings(context, streamId, isHost);
      return true; // Handled
    }
    
    // For gift and share, the custom widgets will handle their own logic
    // So we don't need to handle them here
    return false; // Use default behavior
  },
);
```


**Dynamic Control Updates:**
```dart
// Update control widget builder at runtime
IsmLiveApp.updateControlWidgetBuilder((context, option, onTap, isHost, isCopublishing, streamId) {
  if (option == IsmLiveStreamOption.gift) {
    return NewCustomGiftWidget(onTap: onTap);
  }
  return null;
});

// Update control option callback at runtime
IsmLiveApp.updateControlOptionCallback((context, option, streamId, isHost, isCopublishing) async {
  if (option == IsmLiveStreamOption.share) {
    await _newShareHandler(context, streamId, isHost);
    return true;
  }
  return false;
});

// Disable custom control handling (use SDK default)
IsmLiveApp.updateControlWidgetBuilder(null);
IsmLiveApp.updateControlOptionCallback(null);
```

#### Unified Control System

The SDK now provides a unified control system that simplifies control button customization and interaction handling:

**Key Features:**
- **Single Callback**: Use `controlOptionCallback` to handle all control option taps
- **Custom Widgets**: Use `controlWidgetBuilder` to replace specific control buttons
- **Clean API**: No more individual callbacks for each control type
- **Backward Compatible**: Existing implementations continue to work

**Benefits:**
- **Simplified Code**: One callback handles all control interactions
- **Better Maintainability**: Single point of control for all options
- **Consistent Behavior**: All controls follow the same pattern
- **Easy Migration**: Simple to migrate from individual callbacks

#### E-commerce Callbacks

The SDK provides specialized callbacks for e-commerce functionality in product streams, allowing host apps to customize product navigation and purchase flows.

**Available E-commerce Callbacks:**

- **`pinItemCallback`**: Called when host arrow buttons (previous/next) are tapped
  - Parameters: `direction` (IsmLiveArrowDirection.previous or IsmLiveArrowDirection.next)
  - Useful for custom product navigation, content switching, analytics tracking, etc.
  - If not set, no action is taken

- **`buyNowCallback`**: Called when the "Buy now" button is tapped
  - No parameters required
  - Useful for custom purchase flows, e-commerce integration, analytics tracking, etc.
  - If not set, no action is taken

**E-commerce Callback Examples:**

**Basic Product Navigation:**
```dart
IsmLiveApp.configureInterface(
  ecomConfigure: IsmLiveEcomConfigure(
    pinItemCallback: (direction) {
      if (direction == IsmLiveArrowDirection.previous) {
        // Navigate to previous product
        print('Navigate to previous product');
        _navigateToPreviousProduct();
      } else if (direction == IsmLiveArrowDirection.next) {
        // Navigate to next product
        print('Navigate to next product');
        _navigateToNextProduct();
      }
    },
    buyNowCallback: () {
      // Handle "Buy now" button click
      print('Buy now button clicked');
      _showPurchaseDialog();
    },
  ),
);
```

**Advanced E-commerce Integration:**
```dart
IsmLiveApp.configureInterface(
  ecomConfigure: IsmLiveEcomConfigure(
    pinItemCallback: (direction) {
      // Track navigation analytics
      _analyticsService.trackEvent('product_navigation', {
        'direction': direction.name,
        'timestamp': DateTime.now().toIso8601String(),
      });
      
      // Update product state
      if (direction == IsmLiveArrowDirection.previous) {
        _productController.previousProduct();
      } else {
        _productController.nextProduct();
      }
      
      // Update UI
      _updateProductDisplay();
    },
    buyNowCallback: () {
      // Check user authentication
      if (!_userService.isAuthenticated) {
        _showLoginDialog();
        return;
      }
      
      // Track purchase intent
      _analyticsService.trackEvent('purchase_intent', {
        'product_id': _currentProduct.id,
        'timestamp': DateTime.now().toIso8601String(),
      });
      
      // Navigate to checkout
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => CheckoutScreen(
            product: _currentProduct,
          ),
        ),
      );
    },
  ),
);
```

**Integration with External E-commerce Systems:**
```dart
IsmLiveApp.configureInterface(
  ecomConfigure: IsmLiveEcomConfigure(
    pinItemCallback: (direction) {
      // Sync with external product catalog
      _externalCatalogService.navigateProduct(
        direction: direction,
        onSuccess: (product) {
          _updateCurrentProduct(product);
        },
        onError: (error) {
          _showErrorMessage('Failed to load product: $error');
        },
      );
    },
    buyNowCallback: () {
      // Integrate with external payment system
      _paymentService.initiatePurchase(
        product: _currentProduct,
        onSuccess: (transaction) {
          _showSuccessMessage('Purchase successful!');
        },
        onError: (error) {
          _showErrorMessage('Purchase failed: $error');
        },
      );
    },
  ),
);
```

**Dynamic E-commerce Updates:**
```dart
// Update e-commerce configuration at runtime
IsmLiveApp.configureInterface(
  ecomConfigure: IsmLiveEcomConfigure(
    pinItemCallback: _newNavigationHandler,
    buyNowCallback: _newPurchaseHandler,
  ),
);

// Disable e-commerce callbacks (use default behavior)
IsmLiveApp.configureInterface(
  ecomConfigure: IsmLiveEcomConfigure(
    pinItemCallback: null,
    buyNowCallback: null,
  ),
);
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
| Custom Disconnect API  | `streamDisconnectApiHandler` | Replace SDK's default disconnect endpoints with your own API |
| Custom Heart Messages  | `controlOptionCallback`    | Handle hearts via `IsmLiveStreamOption.heart` |
| Custom Analytics      | `streamAnalyticsApiHandler` | Replace SDK's analytics endpoint with your own API |
| Custom Viewers Analytics | `streamAnalyticsViewersApiHandler` | Replace SDK's analytics viewers endpoint with your own API |
| Custom Cart Widget       | `cartBuilder`             | Customize shopping cart icon/widget in stream header |
| Custom Attention Dialog  | `attentionDialogButtonCallback` | Handle attention dialog button clicks with your own implementation |
| Custom Control Widgets   | `controlWidgetBuilder`     | Replace specific control buttons with custom widgets |
| Unified Control Handling  | `controlOptionCallback`     | Handle all control option taps with unified callback |
| E-commerce Product Navigation | `pinItemCallback` | Handle host arrow button clicks for product navigation |
| E-commerce Purchase Flow | `buyNowCallback` | Handle "Buy now" button clicks for purchase flows |

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
