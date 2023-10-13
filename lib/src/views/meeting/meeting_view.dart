import 'package:appscrip_live_stream_component/appscrip_live_stream_component.dart';
import 'package:flutter/material.dart';

class MyMeetingsView extends StatelessWidget {
  const MyMeetingsView({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: const Center(
            child: Text(
              'LogOut',
              style: TextStyle(color: Colors.black),
            ),
          ),
          title: Text(
            'My Meetings',
            style: IsmLiveStyles.whiteBold16,
          ),
          centerTitle: true,
          actions: [
            IconButton(
              onPressed: () {},
              icon: const Icon(
                Icons.add,
                color: Colors.blue,
              ),
            ),
          ],
        ),
        body: Padding(
          padding: IsmLiveDimens.edgeInsets8_4,
          child: ListView.separated(
              itemBuilder: (context, index) => Container(
                    color: IsmLiveColors.white,
                    height: IsmLiveDimens.fifty,
                    child: Row(
                      children: [
                        const Text('team meet'),
                        const Spacer(),
                        IsmLiveButton(
                          onTap: () {},
                          label: 'Join',
                        ),
                      ],
                    ),
                  ),
              separatorBuilder: (context, index) => const Divider(),
              itemCount: 5),
        ),
      );
}
