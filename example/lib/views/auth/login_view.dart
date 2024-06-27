import 'package:appscrip_live_stream_component/appscrip_live_stream_component.dart';
import 'package:appscrip_live_stream_component_example/controllers/controllers.dart';
import 'package:appscrip_live_stream_component_example/res/res.dart';
import 'package:appscrip_live_stream_component_example/utils/utils.dart';
import 'package:appscrip_live_stream_component_example/utils/validator.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class LoginView extends StatelessWidget {
  const LoginView({super.key});

  static const String route = AppRoutes.login;

  static const List<Map<String, String>> userList = [
    {'user': '6583075c0308465abfea17fe', 'password': ' 6583075c0308Da\$'},
    {'user': '64df4c2c768dfe8eec21d5ce', 'password': '64df4c2c768dDa\$'},
    {'user': '654b37e21b05bd7a84c763b4', 'password': '654b37e21b05Da\$'},
    {'user': '61fb7c4a2835ede6283c77f4', 'password': '61fb7c4a2835Da\$'}
  ];

  @override
  Widget build(BuildContext context) => GetBuilder<AuthController>(
        initState: (_) {
          IsmLiveUtility.updateLater(() {
            Get.find<AuthController>()
              ..emailController.clear()
              ..passwordController.clear()
              ..showPassward = false;
          });
        },
        builder: (controller) => Scaffold(
          resizeToAvoidBottomInset: false,
          body: SingleChildScrollView(
            child: Form(
              key: controller.loginFormKey,
              child: Padding(
                padding: IsmLiveDimens.edgeInsets16,
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      IsmLiveDimens.boxHeight50,
                      const Hero(
                        tag: ValueKey('logo_isometrik'),
                        child: Center(
                          child: IsmLiveImage.svg(AssetConstants.isometrik),
                        ),
                      ),
                      IsmLiveDimens.boxHeight32,
                      Hero(
                        tag: const ValueKey('email_label'),
                        child: IsmLiveAnimatedText(TranslationKeys.email.tr),
                      ),
                      IsmLiveDimens.boxHeight8,
                      Hero(
                        tag: const ValueKey('email_field'),
                        child: IsmLiveInputField.email(
                          hintText: 'Enter Email',
                          onchange: (value) {
                            controller.update();
                          },
                          controller: controller.emailController,
                          // validator: AppValidator.emailValidator,
                        ),
                      ),
                      IsmLiveDimens.boxHeight16,
                      Hero(
                        tag: const ValueKey('password_label'),
                        child: IsmLiveAnimatedText(TranslationKeys.password.tr),
                      ),
                      IsmLiveDimens.boxHeight8,
                      Hero(
                        tag: const ValueKey('password_field'),
                        child: Obx(
                          () => IsmLiveInputField.password(
                            hintText: 'Enter Password',
                            onchange: (value) {
                              // if (value.length == 1 ||
                              //     value.isEmpty ||
                              //     (controller.loginFormKey.currentState
                              //             ?.validate() ??
                              //         false)) {
                              //   controller.update();
                              // }
                              controller.update();
                            },
                            maxLines: 1,
                            suffixIcon: controller.passwordController.text
                                    .trim()
                                    .isNotEmpty
                                ? IconButton(
                                    icon: Icon(!controller.showPassward
                                        ? Icons.visibility_outlined
                                        : Icons.visibility_off_outlined),
                                    onPressed: () {
                                      controller.showPassward =
                                          !controller.showPassward;
                                    },
                                  )
                                : null,
                            obscureText: !controller.showPassward,
                            obscureCharacter: '*',
                            controller: controller.passwordController,
                            validator: AppValidator.passwordValidator,
                          ),
                        ),
                      ),
                      IsmLiveDimens.boxHeight32,
                      Hero(
                        tag: const ValueKey('login-signup'),
                        child: IsmLiveButton(
                          onTap:
                              //  controller.loginFormKey.currentState
                              //             ?.validate() ??
                              //         false
                              //     ?
                              controller.validateLogin
                          // : null
                          ,
                          label: TranslationKeys.login.tr,
                        ),
                      ),
                      IsmLiveDimens.boxHeight20,
                      Hero(
                        tag: const ValueKey('login-signup-change'),
                        child: IsmLiveButton.secondary(
                          onTap: RouteManagement.goToSignUp,
                          label: TranslationKeys.signup.tr,
                        ),
                      ),

                      ///TODO remove later
                      SizedBox(
                        height: 200,
                        child: ListView.builder(
                          itemBuilder: (context, index) => IsmLiveTapHandler(
                            onTap: () {
                              controller.emailController.text =
                                  userList[index]['user'] ?? '';
                              controller.passwordController.text =
                                  userList[index]['password'] ?? '';
                            },
                            child: Padding(
                              padding: const EdgeInsets.all(20),
                              child:
                                  Text('UserId = ${userList[index]['user']}'),
                            ),
                          ),
                          itemCount: userList.length,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      );
}
