part of '../live_delegate.dart';

/// Builder for screen / AppBar back navigation controls.
///
/// [onBackPressed] invokes the default navigation (`IsmLiveRoute.pop`) when
/// the custom widget should pop the current route.
typedef IsmLiveBackButtonBuilder = Widget Function(
  BuildContext context,
  VoidCallback onBackPressed,
);

/// Resolves the back button for SDK screens, using [IsmLiveDelegate.backButtonBuilder]
/// when set via [IsmLiveApp.configureInterface].
Widget ismLiveBuildBackButton(
  BuildContext context, {
  Color? color,
  VoidCallback? onBackPressed,
}) {
  final onBack = onBackPressed ?? IsmLiveRoute.pop;
  final customBuilder = IsmLiveDelegate.backButtonBuilder;
  if (customBuilder != null) {
    return customBuilder(context, onBack);
  }
  return BackButton(
    color: color ?? Colors.black,
    onPressed: onBack,
  );
}