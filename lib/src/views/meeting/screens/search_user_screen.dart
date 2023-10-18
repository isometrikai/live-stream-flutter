import 'package:appscrip_live_stream_component/appscrip_live_stream_component.dart';
import 'package:flutter/material.dart';

class SearchUserScreen extends StatelessWidget {
  const SearchUserScreen({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          elevation: 0,
          backgroundColor: IsmLiveColors.white,
          title: Text(
            'Search User',
            style: IsmLiveStyles.black16,
          ),
          centerTitle: true,
        ),
        body: Column(
          children: [
            IsmLiveInputField(
              prefixIcon: const Icon(Icons.search),
              controller: TextEditingController(),
              onchange: (value) {},
            ),
            const Divider(),
            ListView.separated(
                padding: IsmLiveDimens.edgeInsets8_4,
                shrinkWrap: true,
                itemBuilder: (context, index) => const Text('search'),
                separatorBuilder: (context, index) => const Divider(),
                itemCount: 10)
          ],
        ),
      );
}
