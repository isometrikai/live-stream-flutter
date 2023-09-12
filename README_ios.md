# Appscrip Chat Component

## iOS

### Make these changes to your `info.plist`

Camera and microphone usage need to be declared in your Info.plist file.

Path: `ios` > `Runner` > `info.plist`

```plist
<dict>
  ...
  <key>NSCameraUsageDescription</key>
  <string>$(PRODUCT_NAME) uses your camera</string>
  <key>NSMicrophoneUsageDescription</key>
  <string>$(PRODUCT_NAME) uses your microphone</string>
  <key>UIBackgroundModes</key>
  <array>
    <string>audio</string>
  </array>
```

If background mode is enabled, your application can still run the voice call when it is shifted to the background.

Select the app target in Xcode, click the Capabilities tab, enable Background Modes, and check Audio, AirPlay, and Picture in Picture.

---

### Make these changes in `podfile`

Path: `ios` > `Podfile`

```podfile
platform :ios, '12.1'

post_install do |installer|
  installer.pods_project.targets.each do |target|
    flutter_additional_ios_build_settings(target)

    target.build_configurations.each do |config|

      # Workaround for https://github.com/flutter/flutter/issues/64502
      config.build_settings['ONLY_ACTIVE_ARCH'] = 'YES' # <= this line

    end
  end
end
```

On iOS, a broadcast extension is needed in order to capture screen content from other apps. See [setup guide](https://github.com/flutter-webrtc/flutter-webrtc/wiki/iOS-Screen-Sharing#broadcast-extension-quick-setup) for instructions.

iOS Setup is done

Setup other platforms

- [Android](./README_android.md)
<!-- - [Web](./README_web.md) -->

[Go back to main](./README.md)
