import 'package:appscrip_live_stream_component/appscrip_live_stream_component.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class IsmLiveListSheet extends StatelessWidget {
  const IsmLiveListSheet({
    super.key,
    this.title,
    required this.items,
    this.trailing,
    this.scrollController,
    this.onViewerProfileTap,
  });

  final String? title;
  final List<IsmLiveViewerModel> items;
  final ViewerBuilder? trailing;
  final ScrollController? scrollController;
  final Function(IsmLiveViewerModel, int)? onViewerProfileTap;

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final bgColor = context.liveTheme?.backgroundColor ??
        (isDarkMode ? const Color(0xFF121212) : Colors.white);
    final textColor = isDarkMode ? Colors.white : Colors.black;
    final subtitleColor = context.liveTheme?.unselectedTextColor ??
        (isDarkMode ? const Color(0xFFB0B0B0) : Colors.grey);
    final iconColor = isDarkMode ? Colors.white : Colors.black;

    return Container(
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(
            IsmLiveDelegate.bottomSheetBorderRadius?.topLeft.x ??
                IsmLiveDimens.thirty,
          ),
        ),
      ),
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.7,
      ),
      child: SingleChildScrollView(
        controller: scrollController,
        padding: IsmLiveDimens.edgeInsets20,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: MediaQuery.of(context).size.width,
              alignment: Alignment.centerLeft,
              child: Text(
                title ?? IsmLiveStrings.topViewers,
                textAlign: TextAlign.left,
                style: context.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: textColor,
                ),
              ),
            ),
            if (items.isEmpty) ...[
              const IsmLiveImage.svg(
                IsmLiveAssetConstants.viewer_placeholder,
              ),
              IsmLiveDimens.boxHeight2,
              Text(
                IsmLiveStrings.noViewers,
                style: TextStyle(color: subtitleColor),
              ),
            ] else
              ListView.builder(
                padding: IsmLiveDimens.edgeInsets0,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: items.length,
                itemBuilder: (context, index) {
                  var viewer = items[index];
                  return ListTile(
                    onTap: onViewerProfileTap != null
                        ? () => onViewerProfileTap!(items[index], index)
                        : null,
                    contentPadding: IsmLiveDimens.edgeInsets0,
                    leading: InkWell(
                      child: IsmLiveImage.network(
                        IsmLiveDelegate.getUserProfileUrl
                                ?.call(viewer.imageUrl ?? '') ??
                            viewer.imageUrl ??
                            '',
                        name: viewer.userName,
                        dimensions: IsmLiveDimens.forty,
                        isProfileImage: true,
                      ),
                    ),
                    title: Text(
                      '@${viewer.userName}',
                      style: context.textTheme.titleMedium?.copyWith(
                        color: textColor,
                      ),
                    ),
                    subtitle: Text(
                      viewer.userName,
                      style: context.textTheme.bodySmall?.copyWith(
                        color: subtitleColor,
                      ),
                    ),
                    trailing: trailing?.call(context, viewer),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }
}

class IsmLiveListSheetTwo extends StatelessWidget {
  const IsmLiveListSheetTwo({
    super.key,
    this.title,
    required this.items,
    this.trailing,
    this.scrollController,
  });

  final String? title;
  final List<IsmLiveAnalyticViewerModel> items;
  final ViewerBuilder? trailing;
  final ScrollController? scrollController;

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final bgColor = context.liveTheme?.backgroundColor ??
        (isDarkMode ? const Color(0xFF121212) : Colors.white);
    final textColor = isDarkMode ? Colors.white : Colors.black;
    final subtitleColor = context.liveTheme?.unselectedTextColor ??
        (isDarkMode ? const Color(0xFFB0B0B0) : Colors.grey);

    return Container(
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(
            IsmLiveDelegate.bottomSheetBorderRadius?.topLeft.x ??
                IsmLiveDimens.thirty,
          ),
        ),
      ),
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.7,
      ),
      child: SingleChildScrollView(
        controller: scrollController,
        padding: IsmLiveDimens.edgeInsets20,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: MediaQuery.of(context).size.width,
              alignment: Alignment.centerLeft,
              child: Text(
                title ?? IsmLiveStrings.topViewers,
                textAlign: TextAlign.left,
                style: context.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: textColor,
                ),
              ),
            ),
            if (items.isEmpty) ...[
              const IsmLiveImage.svg(
                IsmLiveAssetConstants.viewer_placeholder,
              ),
              IsmLiveDimens.boxHeight2,
              Text(
                IsmLiveStrings.noViewers,
                style: TextStyle(color: subtitleColor),
              ),
            ] else
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.3,
                child: ListView.builder(
                  padding: IsmLiveDimens.edgeInsets0,
                  shrinkWrap: true,
                  // physics: const NeverScrollableScrollPhysics(),
                  itemCount: items.length,
                  itemBuilder: (context, index) {
                    var viewer = items[index];
                    return ListTile(
                      contentPadding: IsmLiveDimens.edgeInsets0,
                      leading: IsmLiveImage.network(
                        viewer.profilePic ?? '',
                        name: viewer.userName ?? '',
                        dimensions: IsmLiveDimens.forty,
                        isProfileImage: true,
                      ),
                      title: Text(
                        '${viewer.firstName} ${viewer.lastName}',
                        style: context.textTheme.titleMedium?.copyWith(
                          color: textColor,
                        ),
                      ),
                      subtitle: Text(
                        '@${viewer.userName}',
                        style: context.textTheme.bodySmall?.copyWith(
                          color: subtitleColor,
                        ),
                      ),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}
