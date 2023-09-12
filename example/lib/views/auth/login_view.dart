import 'package:appscrip_live_stream_component/appscrip_live_stream_component.dart';
import 'package:appscrip_live_stream_component_example/controllers/controllers.dart';
import 'package:appscrip_live_stream_component_example/res/res.dart';
import 'package:appscrip_live_stream_component_example/utils/utils.dart';
import 'package:appscrip_live_stream_component_example/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class LoginView extends StatelessWidget {
  const LoginView({super.key});

  static const String route = AppRoutes.login;

  @override
  Widget build(BuildContext context) => GetX<AuthController>(
        builder: (controller) => Scaffold(
          resizeToAvoidBottomInset: false,
          appBar: AppBar(
            title: Text(
              TranslationKeys.login.tr,
              style: const TextStyle(color: Colors.white),
            ),
            backgroundColor: ColorsValue.primary,
            centerTitle: true,
            elevation: 0,
          ),
          body: Form(
            key: controller.loginFormKey,
            child: Padding(
              padding: Dimens.edgeInsets16,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Hero(
                      tag: const ValueKey('logo_isometrik'),
                      child: Center(
                        child: Image.asset(
                          IsmLiveAssetConstants.isometrik,
                          package: 'appscrip_live_stream_component',
                        ),
                      ),
                    ),
                    Dimens.boxHeight32,
                    Hero(
                      tag: const ValueKey('email_label'),
                      child: IsmLiveAnimatedText(TranslationKeys.email.tr),
                    ),
                    Dimens.boxHeight8,
                    Hero(
                      tag: const ValueKey('email_field'),
                      child: InputField.email(
                          controller: controller.emailController),
                    ),
                    Dimens.boxHeight16,
                    Hero(
                      tag: const ValueKey('password_label'),
                      child: IsmLiveAnimatedText(TranslationKeys.password.tr),
                    ),
                    Dimens.boxHeight8,
                    Hero(
                      tag: const ValueKey('password_field'),
                      child: InputField.password(
                          suffixIcon: IconButton(
                            icon: Icon(!controller.showPassward
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined),
                            onPressed: () {
                              controller.showPassward =
                                  !controller.showPassward;
                            },
                          ),
                          obscureText: controller.showPassward,
                          obscureCharacter: '*',
                          controller: controller.passwordController),
                    ),
                    Dimens.boxHeight32,
                    Hero(
                      tag: const ValueKey('login-signup'),
                      child: IsmLiveButton(
                        onTap: controller.validateLogin,
                        label: TranslationKeys.login.tr,
                      ),
                    ),
                    Dimens.boxHeight20,
                    Hero(
                      tag: const ValueKey('login-signup-change'),
                      child: IsmLiveButton.text(
                        onTap: RouteManagement.goToSignUp,
                        label: TranslationKeys.signup.tr,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
}
