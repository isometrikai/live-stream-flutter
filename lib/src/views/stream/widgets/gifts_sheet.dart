import 'package:appscrip_live_stream_component/appscrip_live_stream_component.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

class IsmLiveGiftsSheet extends StatelessWidget {
  const IsmLiveGiftsSheet({
    super.key,
    required this.list,
    required this.onTap,
  });
  final List<String> list;
  final void Function(String body) onTap;

  @override
  Widget build(BuildContext context) => Padding(
        padding: IsmLiveDimens.edgeInsets16,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            IsmLiveDimens.boxHeight32,
            const Text('My Balance'),
            IsmLiveDimens.boxHeight16,
            Expanded(
              child: MasonryGridView.count(
                crossAxisSpacing: IsmLiveDimens.eight,
                crossAxisCount: 4,
                itemBuilder: (context, index) => CustomIconButton(
                  dimension: IsmLiveDimens.hundred,
                  radius: IsmLiveDimens.ten,
                  icon: IsmLiveImage.asset(
                    list[index],
                  ),
                  onTap: () async {
                    onTap(list[index]);
                  },
                  color: IsmLiveColors.grey,
                ),
                itemCount: list.length,
              ),
            ),
          ],
        ),
      );
}
