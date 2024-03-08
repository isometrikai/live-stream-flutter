import 'package:appscrip_live_stream_component/appscrip_live_stream_component.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class IsmLiveTagProducts extends StatelessWidget {
  const IsmLiveTagProducts({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          actions: [
            TextButton(
              onPressed: () {},
              child: const Text('+Add'),
            ),
          ],
          title: Text(
            'Tag Products',
            style: context.textTheme.titleMedium
                ?.copyWith(fontWeight: FontWeight.bold),
          ),
          elevation: 0,
          centerTitle: true,
          iconTheme: const IconThemeData(color: Colors.black),
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
                hintText: 'Search',
                prefixIcon: const Icon(Icons.search),
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

class IsmLivePinItem extends StatelessWidget {
  const IsmLivePinItem({super.key});

  @override
  Widget build(BuildContext context) => Row(
        children: [
          SizedBox(
            width: IsmLiveDimens.seventy,
            height: IsmLiveDimens.seventy,
            child: IsmLiveImage.network(
              '',
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
                  style: context.textTheme.bodyLarge,
                  maxLines: 1,
                ),
                Row(
                  children: [
                    Text(
                      '\$ 779',
                      style: context.textTheme.bodySmall
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    IsmLiveDimens.boxWidth4,
                    const Text(
                      '\$ 839',
                      style: TextStyle(
                        color: IsmLiveColors.lightGray,
                        decoration: TextDecoration.lineThrough,
                        decorationColor: IsmLiveColors.lightGray,
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  height: IsmLiveDimens.thirty,
                  width: IsmLiveDimens.ninty,
                  child: const IsmLiveButton(
                    label: 'Pin Item',
                    small: true,
                  ),
                )
              ],
            ),
          )
        ],
      );
}
