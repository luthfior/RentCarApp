import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:rent_car_app/data/models/car.dart';
import 'package:rent_car_app/presentation/pages/booking_page.dart';
import 'package:rent_car_app/presentation/pages/chatting_page.dart';
import 'package:rent_car_app/presentation/pages/checkout_page.dart';
import 'package:rent_car_app/presentation/pages/complete_booking_page.dart';
import 'package:rent_car_app/presentation/pages/detail_page.dart';
import 'package:rent_car_app/presentation/pages/discover_page.dart';
import 'package:rent_car_app/presentation/bindings/login_binding.dart';
import 'package:rent_car_app/presentation/pages/login_page.dart';
import 'package:rent_car_app/presentation/pages/pin_page.dart';
import 'package:rent_car_app/presentation/bindings/register_binding.dart';
import 'package:rent_car_app/presentation/pages/register_page.dart';
import 'package:rent_car_app/presentation/pages/onboarding_page.dart';
import 'package:rent_car_app/presentation/pages/splash_screen.dart';
import 'package:rent_car_app/data/services/connectivity_service.dart';
import 'package:rent_car_app/presentation/viewModels/auth_view_model.dart';
import 'core/firebase_options.dart';
import 'package:google_fonts/google_fonts.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  Get.put(ConnectivityService());
  Get.put(AuthViewModel());
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
        GetPage(name: '/discover', page: () => DiscoverPage()),
        GetPage(
          name: '/register',
          page: () => const RegisterPage(),
          binding: RegisterBinding(),
        ),
        GetPage(
          name: '/login',
          page: () => const LoginPage(),
          binding: LoginBinding(),
        ),
        GetPage(
          name: '/detail',
          page: () {
            String idCar = Get.arguments as String;
            return DetailPage(idProduct: idCar);
          },
        ),
        GetPage(
          name: '/booking',
          page: () {
            Car idProduct = Get.arguments as Car;
            return BookingPage(car: idProduct);
          },
        ),
        GetPage(
          name: '/checkout',
          page: () {
            Map data = Get.arguments as Map;
            Car product = data['product'];
            String startDate = data['startDate'];
            String endDate = data['endDate'];
            return CheckoutPage(
              car: product,
              startDate: startDate,
              endDate: endDate,
            );
          },
        ),
        GetPage(
          name: '/pin',
          page: () {
            Car idProduct = Get.arguments as Car;
            return PinPage(car: idProduct);
          },
        ),
        GetPage(
          name: '/complete',
          page: () {
            Car idProduct = Get.arguments as Car;
            return CompleteBookingPage(car: idProduct);
          },
        ),
        GetPage(
          name: '/chatting',
          page: () {
            Map data = Get.arguments as Map;
            Car car = data['product'];
            String uid = data['uid'];
            String username = data['username'];
            return ChattingPage(product: car, uid: uid, username: username);
          },
        ),
      ],
    );
  }
}
