# Flutter specific rules
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.**  { *; }
-keep class io.flutter.util.**  { *; }
-keep class io.flutter.view.**  { *; }
-keep class io.flutter.**  { *; }
-keep class io.flutter.plugins.**  { *; }

# Keep LiveKit classes
-keep class livekit.** { *; }
-keep class io.livekit.** { *; }

# Keep your custom classes
-keep class com.dubly.androidapp.** { *; }
-keep class com.flutterISMStream.** { *; }

# Keep native methods
-keepclassmembers class * {
    native <methods>;
}

# Keep enum values
-keepclassmembers enum * {
    public static **[] values();
    public static ** valueOf(java.lang.String);
}

# Keep serializable classes
-keepclassmembers class * implements java.io.Serializable {
    static final long serialVersionUID;
    private static final java.io.ObjectStreamField[] serialPersistentFields;
    private void writeObject(java.io.ObjectOutputStream);
    private void readObject(java.io.ObjectInputStream);
    java.lang.Object writeReplace();
    java.lang.Object readResolve();
}

# Keep WebRTC related classes
-keep class org.webrtc.** { *; }
-keep class org.webrtc.** { *; }

# Keep JSON related classes
-keep class com.google.gson.** { *; }
-keep class * implements com.google.gson.TypeAdapterFactory
-keep class * implements com.google.gson.JsonSerializer
-keep class * implements com.google.gson.JsonDeserializer

# Keep MQTT related classes
-keep class org.eclipse.paho.** { *; }

# Keep camera and media related classes
-keep class android.hardware.camera2.** { *; }
-keep class android.media.** { *; }

# Keep network related classes
-keep class okhttp3.** { *; }
-keep class retrofit2.** { *; }

# Keep WebSocket related classes
-keep class okio.** { *; }

# Keep reflection
-keepattributes *Annotation*
-keepattributes Signature
-keepattributes Exceptions

# Keep source file names for better crash reports
-keepattributes SourceFile,LineNumberTable

# Keep inner classes
-keep class * {
    public <init>(android.content.Context, android.util.AttributeSet);
    public <init>(android.content.Context, android.util.AttributeSet, int);
}

# Keep native libraries
-keep class **.R$* {
    public static <fields>;
} 