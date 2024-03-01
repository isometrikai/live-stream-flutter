import 'package:appscrip_live_stream_component/appscrip_live_stream_component.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class IsmLiveAddProduct extends StatelessWidget {
  const IsmLiveAddProduct({super.key});
  final bool productList = false;
  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: Text(
            'Add Products',
            style: context.textTheme.titleMedium
                ?.copyWith(fontWeight: FontWeight.bold),
          ),
          elevation: 0,
          centerTitle: true,
          iconTheme: const IconThemeData(color: Colors.black),
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
                      fillColor: IsmLiveColors.fieldColor,
                      controller: TextEditingController(),
                      hintText: 'Search',
                      prefixIcon: const Icon(Icons.search),
                      onchange: (value) {},
                    ),
                    IsmLiveDimens.boxHeight20,
                    SizedBox(
                      height: Get.height * 0.53,
                      child: ListView.separated(
                        shrinkWrap: true,
                        itemBuilder: (context, index) => const IsmLiveProduct(),
                        itemCount: 4,
                        separatorBuilder: (context, index) => const Divider(
                          thickness: 1,
                        ),
                      ),
                    ),
                    const Expanded(child: IsmLiveProductBottom()),
                  ],
                ),
              ),
      );
}
