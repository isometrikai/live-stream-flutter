import 'package:appscrip_live_stream_component/appscrip_live_stream_component.dart';
import 'package:flutter/material.dart';

/// LiveCustomInputField widget for live stream chat input
///
/// This widget provides a rectangular curved input field with white border
/// for live stream chat functionality.
class LiveCustomInputField extends StatefulWidget {
  const LiveCustomInputField({
    super.key,
    required this.defaultMessageField,
  });

  /// The default message field widget to customize
  final Widget defaultMessageField;

  @override
  State<LiveCustomInputField> createState() => _LiveCustomInputFieldState();
}

class _LiveCustomInputFieldState extends State<LiveCustomInputField> {
  @override
  Widget build(BuildContext context) => _buildCustomizedMessageField(context);

  Widget _buildCustomizedMessageField(BuildContext context) {
    // Get the stream controller to extract streamId and isHost
    final streamController = IsmLiveApp.getStreamController();

    // Create a custom message field with transparent background and white border
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.3), // Background color
        borderRadius: BorderRadius.circular(12), // Rectangular curved design
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.8), // White border
          width: 1.5,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: IsmLiveMessageField(
          streamId: streamController.streamId ?? '',
          isHost: streamController.isHost,
          customFillColor: Colors.transparent, // Transparent inner background
          customBorderColor: Colors.transparent, // No inner border
          customRadius: 10, // Match the clipping radius
          customStyle: const TextStyle(
            color: Colors.white,
            fontSize: 14, // Increased font size
          ),
          customHintStyle: TextStyle(
            color: Colors.white.withValues(alpha: 0.7),
            fontSize: 14, // Increased hint font size
          ),
          customContentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16, // Increased height
          ),
        ),
      ),
    );
  }
}
