import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:rent_car_app/data/models/car.dart';
import 'package:rent_car_app/presentation/bindings/auth_binding.dart';
import 'package:rent_car_app/presentation/bindings/booking_binding.dart';
import 'package:rent_car_app/presentation/bindings/chat_binding.dart';
import 'package:rent_car_app/presentation/bindings/checkout_binding.dart';
import 'package:rent_car_app/presentation/bindings/discover_binding.dart';
import 'package:rent_car_app/presentation/bindings/pin_binding.dart';
import 'package:rent_car_app/presentation/pages/auth_page.dart';
import 'package:rent_car_app/presentation/pages/booking_page.dart';
import 'package:rent_car_app/presentation/pages/chatting_page.dart';
import 'package:rent_car_app/presentation/pages/checkout_page.dart';
import 'package:rent_car_app/presentation/pages/complete_booking_page.dart';
import 'package:rent_car_app/presentation/pages/detail_page.dart';
import 'package:rent_car_app/presentation/pages/discover_page.dart';
import 'package:rent_car_app/presentation/pages/pin_page.dart';
import 'package:rent_car_app/presentation/pages/onboarding_page.dart';
import 'package:rent_car_app/presentation/pages/pin_setup_page.dart';
import 'package:rent_car_app/presentation/pages/splash_screen.dart';
import 'package:rent_car_app/data/services/connectivity_service.dart';
import 'package:rent_car_app/presentation/viewModels/auth_view_model.dart';
import 'package:rent_car_app/presentation/viewModels/detail_view_model.dart';
import 'core/firebase_options.dart';
import 'package:google_fonts/google_fonts.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await initializeDateFormatting('id_ID');
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
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: const Color(0xffEFEFF0),
        textTheme: GoogleFonts.poppinsTextTheme(),
      ),
      home: const SplashScreen(),
      getPages: [
        GetPage(name: '/onboarding', page: () => const OnBoardingPage()),
        GetPage(
          name: '/discover',
          page: () => DiscoverPage(),
          binding: DiscoverBinding(),
        ),
        GetPage(name: '/auth', page: () => AuthPage(), binding: AuthBinding()),
        GetPage(
          name: '/detail',
          page: () => DetailPage(),
          binding: BindingsBuilder(() {
            final String productId = Get.arguments as String;
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
        GetPage(
          name: '/pin-setup',
          page: () => PinSetupPage(),
          binding: PinBinding(),
        ),
        GetPage(name: '/pin', page: () => PinPage(), binding: PinBinding()),
        GetPage(
          name: '/complete',
          page: () {
            Car car = Get.arguments as Car;
            return CompleteBookingPage(car: car);
          },
        ),
        GetPage(
          name: '/chatting',
          page: () => ChattingPage(),
          binding: ChatBinding(),
        ),
      ],
    );
  }
}
