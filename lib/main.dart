import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:rent_car_app/data/services/theme_service.dart';
import 'package:rent_car_app/data/services/connectivity_service.dart';
import 'package:rent_car_app/presentation/pages/auth_page.dart';
import 'package:rent_car_app/presentation/pages/splash_screen.dart';
import 'package:rent_car_app/presentation/viewModels/auth_view_model.dart';
import 'package:rent_car_app/routes/app_pages.dart';
import 'core/firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await initializeDateFormatting('id_ID');
  await GetStorage.init();
  await dotenv.load(fileName: ".env");

  Get.put(ThemeService());
  Get.put(ConnectivityService(), permanent: true);
  Get.put(AuthViewModel(), permanent: true);

  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]).then((_) => runApp(const MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeService = Get.find<ThemeService>();
    final authVM = Get.find<AuthViewModel>();
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeService.lightTheme,
      darkTheme: ThemeService.darkTheme,
      themeMode: themeService.themeMode,
      getPages: AppPages.routes,
      home: FutureBuilder(
        future: authVM.checkSession(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const SplashScreen();
          }
          if (snapshot.hasError) {
            return const AuthPage();
          }
          return Container();
        },
      ),
    );
  }
}
