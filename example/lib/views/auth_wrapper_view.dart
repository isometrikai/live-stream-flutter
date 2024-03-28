import 'package:appscrip_live_stream_component/appscrip_live_stream_component.dart';
import 'package:appscrip_live_stream_component_example/utils/navigators/app_pages.dart';
import 'package:appscrip_live_stream_component_example/utils/navigators/routes_management.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  static const String route = AppRoutes.authWrapper;

  @override
  Widget build(BuildContext context) => Scaffold(
        body: Padding(
          padding: IsmLiveDimens.edgeInsets16,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Join as user or agent',
                style: context.textTheme.bodyLarge,
              ),
              IsmLiveDimens.boxHeight32,
              const IsmLiveButton(
                label: 'Agent',
                onTap: RouteManagement.goToAgentPhoneLogin,
              ),
              IsmLiveDimens.boxHeight20,
              const IsmLiveButton(
                label: 'User',
                onTap: RouteManagement.goToLogin,
              ),
            ],
          ),
        ),
      );
}
