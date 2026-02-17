import 'package:appscrip_live_stream_component/appscrip_live_stream_component.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class IsmLiveTagProducts extends StatelessWidget {
  const IsmLiveTagProducts({super.key});

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final bgColor = context.liveTheme?.backgroundColor ??
        (isDarkMode ? const Color(0xFF121212) : Colors.white);
    final textColor = context.liveTheme?.primaryColor ??
        (isDarkMode ? Colors.white : Colors.black);
    final iconColor = context.liveTheme?.primaryColor ??
        (isDarkMode ? Colors.white : Colors.black);

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: bgColor,
        actions: [
          TextButton(
            onPressed: () {},
            child: Text(
              '+${IsmLiveStrings.add}',
              style: TextStyle(color: textColor),
            ),
          ),
        ],
        title: Text(
          IsmLiveStrings.tagProducts,
          style: context.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: textColor,
          ),
        ),
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: iconColor),
      ),
      body: Padding(
        padding: IsmLiveDimens.edgeInsets16_0,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            IsmLiveInputField(
              contentPadding: IsmLiveDimens.edgeInsets0,
              borderColor: Colors.transparent,
              fillColor: IsmLiveColors.fieldColor,
              controller: TextEditingController(),
              hintText: IsmLiveStrings.search,
              prefixIcon: Icon(Icons.search, color: iconColor),
              onchange: (value) {},
            ),
            IsmLiveDimens.boxHeight20,
            Expanded(
              child: ListView.separated(
                shrinkWrap: true,
                itemBuilder: (context, index) => const IsmLivePinItem(),
                itemCount: 4,
                separatorBuilder: (context, index) => const Divider(
                  thickness: 0.5,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class IsmLivePinItem extends StatelessWidget {
  const IsmLivePinItem({super.key});

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final textColor = context.liveTheme?.primaryColor ??
        (isDarkMode ? Colors.white : Colors.black);
    final subtitleColor = context.liveTheme?.unselectedTextColor ??
        (isDarkMode ? const Color(0xFFB0B0B0) : IsmLiveColors.lightGray);

    return Row(
      children: [
        SizedBox(
          width: IsmLiveDimens.seventy,
          height: IsmLiveDimens.seventy,
          child: IsmLiveImage.network(
            '',
            name: 'U',
            radius: IsmLiveDimens.ten,
          ),
        ),
        IsmLiveDimens.boxWidth10,
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'sdfsdjhfkjdskjdfjdkjflkd',
                overflow: TextOverflow.ellipsis,
                style: context.textTheme.bodyLarge?.copyWith(
                  color: textColor,
                ),
                maxLines: 1,
              ),
              Row(
                children: [
                  Text(
                    '\$ 779',
                    style: context.textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                  ),
                  IsmLiveDimens.boxWidth4,
                  Text(
                    '\$ 839',
                    style: TextStyle(
                      color: subtitleColor,
                      decoration: TextDecoration.lineThrough,
                      decorationColor: subtitleColor,
                    ),
                  ),
                ],
              ),
              SizedBox(
                height: IsmLiveDimens.thirty,
                width: IsmLiveDimens.ninty,
                child: IsmLiveButton(
                  label: IsmLiveStrings.pinItem,
                  small: true,
                ),
              )
            ],
          ),
        )
      ],
    );
  }
}
