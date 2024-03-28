import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

/// A class that represents an image showed in a preview widget.
@immutable
class PreviewImage extends Equatable {
  /// Creates a preview image.
  const PreviewImage({
    required this.messageId,
    required this.payload,
  });

  /// Equatable props
  @override
  List<Object> get props => [messageId, payload];

  /// Unique ID of the image
  final String messageId;

  /// Image's URI
  final String payload;
}
