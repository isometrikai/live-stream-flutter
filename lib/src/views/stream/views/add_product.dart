import 'package:appscrip_live_stream_component/appscrip_live_stream_component.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class IsmLiveAddProduct extends StatelessWidget {
  const IsmLiveAddProduct({super.key});

  static const String updateId = 'add-product';

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
        body: GetBuilder<IsmLiveStreamController>(
          id: updateId,
          initState: (state) {
            var control = Get.find<IsmLiveStreamController>();
            control.searchProductFieldController.clear();
            control.productsList.clear();
            control.fetchProducts();
          },
          builder: (controller) => controller.productsList.isEmpty
              ? const Center(
                  child: Text(
                    'There are no products available to tag',
                  ),
                )
              : Padding(
                  padding: IsmLiveDimens.edgeInsets16_0,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      IsmLiveInputField(
                        contentPadding: IsmLiveDimens.edgeInsets0,
                        borderColor: Colors.transparent,
                        fillColor: IsmLiveColors.fieldColor,
                        controller: controller.searchProductFieldController,
                        hintText: 'Search',
                        prefixIcon: const Icon(Icons.search),
                        onchange: (value) {
                          controller.productsList.clear();
                          controller.fetchProducts(
                            limit: 10,
                            skip: 0,
                            searchTag: value,
                          );
                        },
                      ),
                      IsmLiveDimens.boxHeight20,
                      Expanded(
                        child: ListView.separated(
                          controller: controller.productListController,
                          shrinkWrap: true,
                          itemBuilder: (context, index) {
                            var product = controller.productsList[index];

                            return IsmLiveProduct(
                              imageUrl: product.metadata.productImageUrl ?? '',
                              isSelected: controller.selectedProductsList
                                  .contains(product),
                              onChanged: (value) {
                                if (value ?? false) {
                                  controller.selectedProductsList.add(product);
                                } else {
                                  controller.selectedProductsList
                                      .remove(product);
                                }
                                controller.update([updateId]);
                                controller.update([IsmGoLiveView.updateId]);
                              },
                              productName: product.productName,
                              productDiscription:
                                  product.metadata.description ?? '',
                              productPrice: product.metadata.price ?? 0,
                              symbol: product.metadata.currencySymbol ?? '',
                            );
                          },
                          itemCount: controller.productsList.length,
                          separatorBuilder: (context, index) => const Divider(
                            thickness: 0.5,
                          ),
                        ),
                      ),
                      if (controller.selectedProductsList.isNotEmpty) ...[
                        IsmLiveDimens.boxHeight10,
                        Text(
                            'Selected (${controller.selectedProductsList.length})'),
                        IsmLiveDimens.boxHeight10,
                        SizedBox(
                          height: IsmLiveDimens.sixty,
                          child: ListView.builder(
                            shrinkWrap: true,
                            itemBuilder: (context, index) => Container(
                              margin: IsmLiveDimens.edgeInsetsR10,
                              width: IsmLiveDimens.sixty,
                              height: IsmLiveDimens.sixty,
                              child: Stack(
                                children: [
                                  IsmLiveImage.network(
                                    controller.selectedProductsList[index]
                                            .metadata.productImageUrl ??
                                        '',
                                    name: controller.selectedProductsList[index]
                                        .productName,
                                    radius: IsmLiveDimens.ten,
                                  ),
                                  Positioned(
                                    top: -15,
                                    right: -15,
                                    child: IconButton(
                                      padding: IsmLiveDimens.edgeInsets0,
                                      onPressed: () {
                                        controller.selectedProductsList
                                            .removeAt(index);
                                        controller.update([updateId]);
                                        controller
                                            .update([IsmGoLiveView.updateId]);
                                      },
                                      icon: const Icon(
                                        Icons.cancel,
                                        size: 15,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            itemCount: controller.selectedProductsList.length,
                            scrollDirection: Axis.horizontal,
                          ),
                        ),
                      ],
                      IsmLiveDimens.boxHeight10,
                      IsmLiveButton(
                        label: 'Continue',
                        onTap: Get.back,
                      ),
                      IsmLiveDimens.boxHeight10,
                    ],
                  ),
                ),
        ),
      );
}
