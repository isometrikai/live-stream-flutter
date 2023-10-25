import 'package:appscrip_live_stream_component/appscrip_live_stream_component.dart';
import 'package:appscrip_live_stream_component_example/controllers/controllers.dart';
import 'package:appscrip_live_stream_component_example/res/res.dart';
import 'package:appscrip_live_stream_component_example/utils/utils.dart';
import 'package:appscrip_live_stream_component_example/widgets/image.dart';
import 'package:appscrip_live_stream_component_example/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

/// The view part of the [SignupView], which will be used to
/// show the Signup view page
class SignupView extends StatelessWidget {
  const SignupView({Key? key}) : super(key: key);

  static const String route = AppRoutes.signup;

  @override
  Widget build(BuildContext context) => GetBuilder<AuthController>(
      builder: (controller) => SafeArea(
            bottom: false,
            top: false,
            child: Scaffold(
              appBar: AppBar(
                centerTitle: true,
                elevation: 0,
                automaticallyImplyLeading: false,
                backgroundColor: ColorsValue.primary,
                title: Text(
                  TranslationKeys.signup.tr,
                  style: const TextStyle(
                    color: ColorsValue.white,
                  ),
                ),
              ),
              body: SingleChildScrollView(
                child: Form(
                  key: controller.signFormKey,
                  child: Padding(
                    padding:
                        const EdgeInsets.only(top: 20, left: 20, right: 20),
                    child: Center(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Hero(
                            tag: const ValueKey('logo_isometrik'),
                            child: Center(
                              child: Image.asset(
                                IsmLiveAssetConstants.logos.isometrik,
                                package: 'appscrip_live_stream_component',
                              ),
                            ),
                          ),
                          Center(
                            child: GestureDetector(
                              onTap: () {
                                Get.bottomSheet<void>(
                                  const _PickImageBottomSheet(),
                                  elevation: 25,
                                  enableDrag: true,
                                  backgroundColor: Colors.white,
                                  shape: const RoundedRectangleBorder(
                                    borderRadius: BorderRadius.vertical(
                                      top: Radius.circular(25),
                                    ),
                                  ),
                                );
                              },
                              child: Obx(
                                () => Stack(
                                  children: [
                                    controller.profileImage.trim().isEmpty
                                        ? AppImage.asset(
                                            width: 100,
                                            height: 100,
                                            IsmLiveAssetConstants
                                                .images.noImage,
                                            isProfileImage: true,
                                          )
                                        : AppImage.network(
                                            width: 100,
                                            height: 100,
                                            controller.profileImage,
                                            isProfileImage: true,
                                          ),
                                    Positioned(
                                      bottom: 10,
                                      right: 0,
                                      child: GetUtils.isEmail(
                                              controller.emailController.text)
                                          ? Container(
                                              alignment: Alignment.center,
                                              decoration: BoxDecoration(
                                                  color: Colors.white,
                                                  borderRadius:
                                                      BorderRadius.circular(50),
                                                  border: Border.all(
                                                      color: Colors.grey)),
                                              width: 30,
                                              height: 30,
                                              child: const Icon(
                                                Icons.edit,
                                                color: Colors.grey,
                                                size: 15,
                                              ),
                                            )
                                          : const SizedBox.shrink(),
                                    )
                                  ],
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(
                            height: 20,
                          ),
                          Text(TranslationKeys.userName.tr),
                          IsmLiveDimens.boxHeight8,
                          InputField.userName(
                              controller: controller.userNameController),
                          IsmLiveDimens.boxHeight16,
                          Hero(
                            tag: const ValueKey('email_label'),
                            child: IsmLiveAnimatedText(
                              TranslationKeys.email.tr,
                            ),
                          ),
                          IsmLiveDimens.boxHeight8,
                          Hero(
                            tag: const ValueKey('email_field'),
                            child: InputField.email(
                              controller: controller.emailController,
                              onchange: (value) {
                                if (GetUtils.isEmail(value)) {
                                  controller.isEmailValid = true;
                                } else {
                                  controller.isEmailValid = false;
                                }
                              },
                            ),
                          ),
                          IsmLiveDimens.boxHeight16,
                          Hero(
                            tag: const ValueKey('password_label'),
                            child: IsmLiveAnimatedText(
                                TranslationKeys.password.tr),
                          ),
                          IsmLiveDimens.boxHeight8,
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
                                    controller.update();
                                  },
                                ),
                                obscureText: controller.showPassward,
                                obscureCharacter: '*',
                                controller: controller.passwordController),
                          ),
                          IsmLiveDimens.boxHeight16,
                          Text(TranslationKeys.confirmPassword.tr),
                          IsmLiveDimens.boxHeight8,
                          InputField.password(
                              suffixIcon: IconButton(
                                icon: Icon(!controller.showConfirmPasswared
                                    ? Icons.visibility_outlined
                                    : Icons.visibility_off_outlined),
                                onPressed: () {
                                  controller.showConfirmPasswared =
                                      !controller.showConfirmPasswared;
                                  controller.update();
                                },
                              ),
                              obscureText: controller.showConfirmPasswared,
                              obscureCharacter: '*',
                              validator: (value) {
                                if (controller.passwordController.text ==
                                    value) {
                                  return null;
                                }
                                return 'Should be same with Password';
                              },
                              controller: controller.confirmPasswordController),
                          IsmLiveDimens.boxHeight32,
                          Hero(
                            tag: const ValueKey('login-signup'),
                            child: IsmLiveButton(
                              label: TranslationKeys.signup.tr,
                              onTap: controller.profileImage.isNotEmpty
                                  ? controller.validateSignUp
                                  : () {
                                      Get.dialog(
                                        AlertDialog(
                                          title: const Text('Alert message...'),
                                          content: const Text(
                                              'All fields must be filled with Profile image'),
                                          actions: [
                                            TextButton(
                                              onPressed: Get.back,
                                              child: const Text(
                                                'Okay',
                                                style: TextStyle(fontSize: 20),
                                              ),
                                            )
                                          ],
                                        ),
                                      );
                                    },
                            ),
                          ),
                          const SizedBox(
                            height: 20,
                          ),
                          Hero(
                            tag: const ValueKey('login-signup-change'),
                            child: IsmLiveButton.text(
                              onTap: () {
                                controller.passwordController.clear();
                                controller.showPassward = false;
                                controller.showConfirmPasswared = false;
                                RouteManagement.goToLogin(true);
                              },
                              label: TranslationKeys.login.tr,
                            ),
                          ),
                          IsmLiveDimens.boxHeight16
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ));
}

class _PickImageBottomSheet extends StatelessWidget {
  const _PickImageBottomSheet();

  @override
  Widget build(BuildContext context) => GetBuilder<AuthController>(
        builder: (controller) => Container(
          padding: const EdgeInsets.all(20),
          height: 180,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              InkWell(
                onTap: () {
                  Get.back<void>();
                  controller.uploadImage(ImageSource.camera);
                },
                child: Row(
                  children: [
                    Container(
                      // padding: IsmIsmLiveDimens.edgeInsets8,
                      decoration: const BoxDecoration(
                          borderRadius: BorderRadius.all(Radius.circular(50)),
                          color: Colors.blueAccent),
                      width: 50,
                      height: 50,
                      child: const Icon(
                        Icons.camera_alt,
                        color: Colors.white,
                        size: 25,
                      ),
                    ),
                    const SizedBox(
                      width: 10,
                    ),
                    const Text(
                      'Camera',
                      style: TextStyle(color: Colors.black, fontSize: 20),
                    )
                  ],
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              InkWell(
                onTap: () {
                  Get.back<void>();
                  controller.uploadImage(ImageSource.gallery);
                },
                child: Row(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(50),
                          color: Colors.purpleAccent),
                      width: 50,
                      height: 50,
                      child: const Icon(
                        Icons.photo,
                        color: Colors.white,
                        size: 25,
                      ),
                    ),
                    const SizedBox(
                      width: 10,
                    ),
                    const Text(
                      'Gallery',
                      style: TextStyle(color: Colors.black, fontSize: 20),
                    )
                  ],
                ),
              ),
            ],
          ),
        ),
      );
}
