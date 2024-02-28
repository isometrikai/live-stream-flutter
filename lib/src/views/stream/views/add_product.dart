import 'package:appscrip_live_stream_component/appscrip_live_stream_component.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class IsmLiveAddProduct extends StatelessWidget {
  const IsmLiveAddProduct({super.key});
  final bool productList = false;
  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: Text(
            'Add Products',
            style: context.textTheme.titleMedium
                ?.copyWith(fontWeight: FontWeight.bold),
          ),
          elevation: 0,
          centerTitle: true,
        ),
        body: productList
            ? const Center(
                child: Text(
                  'There are no products available to tag',
                ),
              )
            : Padding(
                padding: IsmLiveDimens.edgeInsets16_0,
                child: Column(
                  children: [
                    IsmLiveInputField(
                      contentPadding: IsmLiveDimens.edgeInsets0,
                      borderColor: Colors.transparent,
                      fillColor: Colors.purple[50],
                      controller: TextEditingController(),
                      hintText: 'Search',
                      prefixIcon: const Icon(Icons.search),
                      onchange: (value) {},
                    ),
                    ListView.separated(
                      shrinkWrap: true,
                      itemBuilder: (context, index) => const IsmLiveProduct(),
                      itemCount: 4,
                      separatorBuilder: (context, index) => const Divider(
                        thickness: 1,
                      ),
                    ),
                  ],
                ),
              ),
        bottomSheet: Container(
          color: IsmLiveColors.white,
          padding: IsmLiveDimens.edgeInsets16,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('selected'),
              SizedBox(
                height: IsmLiveDimens.seventy,
                child: ListView.builder(
                  shrinkWrap: true,
                  itemBuilder: (context, index) => Container(
                    width: IsmLiveDimens.seventy,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(
                        IsmLiveDimens.eight,
                      ),
                    ),
                    child: const IsmLiveImage.network(''),
                  ),
                  itemCount: 2,
                  scrollDirection: Axis.horizontal,
                ),
              ),
              IsmLiveDimens.boxHeight10,
              const IsmLiveButton(
                label: 'Continue',
              ),
            ],
          ),
        ),
      );
}
