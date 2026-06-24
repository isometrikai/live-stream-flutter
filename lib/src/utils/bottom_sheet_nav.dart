import 'dart:math' show max;

import 'package:flutter/material.dart';
import 'package:get/get.dart';

const double _androidNavBarInsetThreshold = 40.0;

/// Raw 3-button navigation bar height from [MediaQuery.viewPadding].
double ismLiveBottomSheetSystemNavHeight(BuildContext context) {
  if (!GetPlatform.isAndroid) {
    return 0;
  }
  final viewBottom = MediaQuery.viewPaddingOf(context).bottom;
  if (viewBottom < _androidNavBarInsetThreshold) {
    return 0;
  }
  return viewBottom;
}

/// Extra clearance for list/menu sheets when the modal route has not already
/// lifted content above the nav bar.
///
/// Modal bottom sheets can report [MediaQuery.padding.bottom] equal to
/// [MediaQuery.viewPadding.bottom] even though only the route is inset; list
/// sheets with a solid [backgroundColor] then need design padding only.
double ismLiveBottomSheetNavClearance(BuildContext context) {
  final systemNav = ismLiveBottomSheetSystemNavHeight(context);
  if (systemNav <= 0) {
    return 0;
  }
  final layoutPadding = MediaQuery.paddingOf(context).bottom;
  if (layoutPadding >= systemNav - 1) {
    return 0;
  }
  return systemNav - layoutPadding;
}

/// Bottom inset for list/menu bottom sheets (e.g. Settings, Take photo).
double ismLiveBottomSheetBottomInset(
  BuildContext context, {
  double designBottom = 20.0,
}) {
  final clearance = ismLiveBottomSheetNavClearance(context);
  if (clearance <= 0) {
    return designBottom;
  }
  return max(designBottom, clearance);
}

/// Bottom inset for sheets with primary actions on the bottom edge (buttons).
///
/// Always merges [designBottom] with the system nav height because these sheets
/// (including transparent modals like [YourLiveSheet]) still draw behind the
/// navigation bar.
double ismLiveBottomSheetActionBottomInset(
  BuildContext context, {
  double designBottom = 20.0,
}) {
  final systemNav = ismLiveBottomSheetSystemNavHeight(context);
  if (systemNav <= 0) {
    return designBottom;
  }
  return max(designBottom, systemNav);
}
