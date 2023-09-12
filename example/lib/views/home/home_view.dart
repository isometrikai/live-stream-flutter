import 'package:appscrip_live_stream_component_example/utils/utils.dart';
import 'package:flutter/material.dart';

class HomeView extends StatelessWidget {
  const HomeView({super.key});

  static const String route = AppRoutes.home;

  @override
  Widget build(BuildContext context) => const Scaffold(
        body: Center(
          child: Text('Home View'),
        ),
      );
}
