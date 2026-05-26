/*import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'Auth/splashscreen.dart';
import 'Controller/theme_controller.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  /// ✅ STATUS BAR STYLE
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark, // Android
      statusBarBrightness: Brightness.light, // iOS
    ),
  );

  /// ✅ SHOW STATUS BAR
  SystemChrome.setEnabledSystemUIMode(
    SystemUiMode.edgeToEdge,
  );

  Get.put(ThemeController());

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ThemeController>();

    return GetMaterialApp(
      title: 'Kaf8',
      debugShowCheckedModeBanner: false,

      /// ✅ LIGHT THEME
      theme: ThemeData(
        brightness: Brightness.light,
        scaffoldBackgroundColor: Colors.white,
        colorScheme: const ColorScheme.light(
          primary: Colors.black,
          secondary: Colors.orange,
        ),
      ),

      /// ✅ DARK THEME
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: Colors.black,
        colorScheme: const ColorScheme.dark(
          primary: Colors.white,
          secondary: Colors.orange,
        ),
      ),

      /// ✅ INITIAL MODE
      themeMode: controller.themeMode.value,

      home: const Splashscreen(),
    );
  }
}*/

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import 'Auth/splashscreen.dart';
import 'Controller/theme_controller.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      statusBarBrightness: Brightness.light,
    ),
  );

  SystemChrome.setEnabledSystemUIMode(
    SystemUiMode.edgeToEdge,
  );

  Get.put(ThemeController());

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ThemeController>();

    return GetMaterialApp(
      title: 'Kaf8',
      debugShowCheckedModeBanner: false,

      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        scaffoldBackgroundColor: Colors.white,
        cardColor: Colors.white,
        dividerColor: Colors.grey.shade300,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          elevation: 0,
          centerTitle: true,
          iconTheme: IconThemeData(color: Colors.black),
          titleTextStyle: TextStyle(color: Colors.black, fontSize: 18, fontWeight: FontWeight.bold),
        ),
        textTheme: const TextTheme(
          bodyLarge: TextStyle(color: Colors.black),
          bodyMedium: TextStyle(color: Colors.black87),
          titleLarge: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
      ),

      darkTheme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF121212),
        cardColor: const Color(0xFF1E1E1E),
        dividerColor: Colors.white24,
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF121212),
          foregroundColor: Colors.white,
          elevation: 0,
          centerTitle: true,
          iconTheme: IconThemeData(color: Colors.white),
          titleTextStyle: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
        ),
        textTheme: const TextTheme(
          bodyLarge: TextStyle(color: Colors.white),
          bodyMedium: TextStyle(color: Colors.white70),
          titleLarge: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),

      themeMode: controller.themeMode.value,

      /// ✅ GLOBAL KEYBOARD HIDE
      builder: (context, child) {
        return Listener(
          behavior: HitTestBehavior.translucent,
          onPointerDown: (_) {
            FocusManager.instance.primaryFocus?.unfocus();
          },
          child: child!,
        );
      },

      home: Builder(
        builder: (context) {

          WidgetsBinding.instance.addPostFrameCallback((_) {
            FocusManager.instance.primaryFocus?.unfocus();
            SystemChannels.textInput.invokeMethod('TextInput.hide');
          });

          return const Splashscreen();
        },
      ),
    );
  }
}

// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:kaf8/small-widgets/app_colors.dart';
//
// import 'core/navigator_service/navigator_service.dart';
// import 'core/routes/route_manager.dart';
// import 'core/routes/routes.dart';
// import 'module/splash/splashScreen.dart';
//
// Future<void> main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//
//   await SystemChrome.setPreferredOrientations([
//     DeviceOrientation.portraitUp,
//     DeviceOrientation.portraitDown,
//   ]);
//
//   runApp((MyDeliveryApp()));
// }
//
//
// class MyDeliveryApp extends StatefulWidget {
//   const MyDeliveryApp({super.key});
//
//   @override
//   State<MyDeliveryApp> createState() => _MyDeliveryAppState();
// }
//
// class _MyDeliveryAppState extends State<MyDeliveryApp> {
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//         title: 'MyDeliveryApp',
//         debugShowCheckedModeBanner: false,
//         navigatorKey: NavigatorService.navigatorKey,
//         //initialRoute: AppRoutes.SplashScreen,
//         initialRoute: AppRoutes.SplashScreen,
//         routes: RouteManager.routes,
//         theme: ThemeData(
//           scaffoldBackgroundColor: AppColors.white,
//           useMaterial3: true,
//         )
//     );
//   }
// }
