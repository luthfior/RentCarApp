import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:rent_car_app/data/models/car.dart';
import 'package:rent_car_app/data/services/theme_service.dart';
import 'package:rent_car_app/presentation/bindings/auth_binding.dart';
import 'package:rent_car_app/presentation/bindings/booking_binding.dart';
import 'package:rent_car_app/presentation/bindings/chat_binding.dart';
import 'package:rent_car_app/presentation/bindings/checkout_binding.dart';
import 'package:rent_car_app/presentation/bindings/discover_binding.dart';
import 'package:rent_car_app/presentation/bindings/edit_profile_binding.dart';
import 'package:rent_car_app/presentation/bindings/pin_binding.dart';
import 'package:rent_car_app/presentation/bindings/pin_setup_binding.dart';
import 'package:rent_car_app/presentation/pages/auth_page.dart';
import 'package:rent_car_app/presentation/pages/booking_page.dart';
import 'package:rent_car_app/presentation/pages/chatting_page.dart';
import 'package:rent_car_app/presentation/pages/checkout_page.dart';
import 'package:rent_car_app/presentation/pages/complete_booking_page.dart';
import 'package:rent_car_app/presentation/pages/detail_page.dart';
import 'package:rent_car_app/presentation/pages/discover_page.dart';
import 'package:rent_car_app/presentation/pages/edit_profile_page.dart';
import 'package:rent_car_app/presentation/pages/pin_page.dart';
import 'package:rent_car_app/presentation/pages/onboarding_page.dart';
import 'package:rent_car_app/presentation/pages/pin_setup_page.dart';
import 'package:rent_car_app/presentation/pages/splash_screen.dart';
import 'package:rent_car_app/data/services/connectivity_service.dart';
import 'package:rent_car_app/presentation/viewModels/auth_view_model.dart';
import 'package:rent_car_app/presentation/viewModels/detail_view_model.dart';
import 'core/firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await initializeDateFormatting('id_ID');
  await GetStorage.init();

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
    return Obx(() {
      return GetMaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeService.lightTheme,
        darkTheme: ThemeService.darkTheme,
        themeMode: themeService.themeMode,
        home: const SplashScreen(),
        getPages: [
          GetPage(name: '/onboarding', page: () => OnBoardingPage()),
          GetPage(
            name: '/discover',
            page: () => DiscoverPage(),
            binding: DiscoverBinding(),
          ),
          GetPage(
            name: '/auth',
            page: () => AuthPage(),
            binding: AuthBinding(),
          ),
          GetPage(
            name: '/detail',
            page: () => DetailPage(),
            binding: BindingsBuilder(() {
              final String productId = Get.arguments;
              Get.put(DetailViewModel(productId));
            }),
          ),
          GetPage(
            name: '/booking',
            page: () => BookingPage(),
            binding: BookingBinding(),
          ),
          GetPage(
            name: '/checkout',
            page: () => CheckoutPage(),
            binding: CheckoutBinding(),
          ),
          GetPage(name: '/pin', page: () => PinPage(), binding: PinBinding()),
          GetPage(
            name: '/pin-setup',
            page: () => PinSetupPage(),
            binding: PinSetupBinding(),
          ),
          GetPage(
            name: '/complete',
            page: () {
              final arguments = Get.arguments;
              if (arguments is Map && arguments.containsKey('bookedCar')) {
                final Car car = arguments['bookedCar'] as Car;
                return CompleteBookingPage(car: car);
              }
              return DiscoverPage();
            },
          ),
          GetPage(
            name: '/chatting',
            page: () => ChattingPage(),
            binding: ChatBinding(),
          ),
          GetPage(
            name: '/edit-profile',
            page: () => EditProfilePage(),
            binding: EditProfileBinding(),
          ),
        ],
      );
    });
  }
}
