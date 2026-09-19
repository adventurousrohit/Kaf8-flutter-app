import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../components/delivery_button.dart';
import '../components/delivery_textWidget.dart';
import '../small-widgets/app_assets.dart';
import '../small-widgets/app_colors.dart';
import 'RoleSelectionScreen.dart';

class OnBoardings extends StatelessWidget {
  const OnBoardings({super.key});

  @override
  Widget build(BuildContext context) {

    final controller = Get.put(OnBoardingController());
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 20),
            Image.asset(AppAssets.logo, width: 91, height: 89),
            Expanded(
              child: GetBuilder<OnBoardingController>(
                builder: (controller) {
                  return PageView.builder(
                    controller: controller.pageController,
                    itemCount: controller.onBoarding.length,
                    onPageChanged: controller.onPageChange,
                    itemBuilder: (context, pageIndex) {
                      OnBoardingModel onBoardingData = controller.onBoarding[pageIndex];
                      return Column(
                        children: [
                          const SizedBox(height: 20),
                          Image.asset(
                            onBoardingData.image,
                            fit: BoxFit.contain,
                            width: MediaQuery.of(context).size.width,
                            height: 300,
                          ),
                          const SizedBox(height: 30),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: BahamasTextWidget(
                              text: onBoardingData.heading ?? "",
                              textAlign: TextAlign.center,
                              fontSize: 24,
                              fontWeight: FontWeight.w700,
                              color: theme.textTheme.titleLarge?.color,
                            ),
                          ),
                          const SizedBox(height: 15),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 40),
                            child: BahamasTextWidget(
                              text: onBoardingData.title,
                              textAlign: TextAlign.center,
                              fontSize: 14,
                              fontWeight: FontWeight.w400,
                              color: theme.textTheme.bodyMedium?.color,
                              height: 1.5,
                            ),
                          ),
                        ],
                      );
                    },
                  );
                },
              ),
            ),
            GetBuilder<OnBoardingController>(
              builder: (controller) {
                return Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(
                        controller.onBoarding.length,
                            (index) => AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          margin: const EdgeInsets.only(right: 5),
                          height: 6,
                          width: controller.currentPage == index ? 6 : 7,
                          decoration: BoxDecoration(
                            color: controller.currentPage == index
                                ? const Color(0XFF00C853)
                                : (isDark ? Colors.white24 : Colors.grey.shade300),
                            borderRadius: BorderRadius.circular(5),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 40),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                      child: Row(
                        children: [
                          Expanded(
                            child: BahamasButton(
                              height: 52,
                              buttonColor: isDark ? Colors.white10 : const Color(0XFFECF1E8),
                              onTap: () => Get.to(const RoleSelectionScreen()),
                              buttonText: "Skip",
                              radius: BorderRadius.circular(12), textColor: const Color(0XFF00C853),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            flex: 2,
                            child: BahamasButton(
                              buttonColor: const Color(0XFF00C853),
                              height: 52,
                              radius: BorderRadius.circular(12),
                              onTap: () => controller.onNextClicked(),
                              buttonText: controller.currentPage == 2 ? "Get Started" : "Next",
                              textColor: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

/// ================= CONTROLLER =================
class OnBoardingController extends GetxController {
  int currentPage = 0;

  final PageController pageController = PageController();

  void onPageChange(int page) {
    currentPage = page;
    update();
  }

  void onNextClicked() {
    if (currentPage != 2) {
      pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeIn,
      );
    } else {
      Get.to(RoleSelectionScreen());
    }
  }

  @override
  void onClose() {
    pageController.dispose();
    super.onClose();
  }

  /// DATA
  final List<OnBoardingModel> onBoarding = [
    OnBoardingModel(
      image: AppAssets.first,
      title: 'Schedule pickup and drop in seconds',
      heading: 'Book your drop easily',
    ),
    OnBoardingModel(
      image: AppAssets.second,
      title: "Follow your goods in real time.",
      heading: 'Track Your Shipment Live',
    ),
    OnBoardingModel(
      image: AppAssets.third,
      title: "Professional drivers and secure handling for every delivery.",
      heading: 'Safe & Secure Transport',
    ),
  ];
}

/// ================= MODEL =================
class OnBoardingModel {
  String image;
  String title;
  String? heading;

  OnBoardingModel({
    required this.image,
    required this.title,
    this.heading,
  });
}