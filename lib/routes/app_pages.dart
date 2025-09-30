import 'package:get/get.dart';
import 'package:rent_car_app/data/models/booked_car.dart';
import 'package:rent_car_app/data/models/car.dart';
import 'package:rent_car_app/presentation/bindings/auth_binding.dart';
import 'package:rent_car_app/presentation/bindings/booking_binding.dart';
import 'package:rent_car_app/presentation/bindings/chat_binding.dart';
import 'package:rent_car_app/presentation/bindings/checkout_binding.dart';
import 'package:rent_car_app/presentation/bindings/discover_binding.dart';
import 'package:rent_car_app/presentation/bindings/edit_profile_binding.dart';
import 'package:rent_car_app/presentation/bindings/location_binding.dart';
import 'package:rent_car_app/presentation/bindings/onboarding_binding.dart';
import 'package:rent_car_app/presentation/bindings/pin_binding.dart';
import 'package:rent_car_app/presentation/bindings/pin_setup_binding.dart';
import 'package:rent_car_app/presentation/bindings/add_product_binding.dart';
import 'package:rent_car_app/presentation/bindings/top_up_binding.dart';
import 'package:rent_car_app/presentation/pages/about_app_page.dart';
import 'package:rent_car_app/presentation/pages/add_product_page.dart';
import 'package:rent_car_app/presentation/pages/auth_page.dart';
import 'package:rent_car_app/presentation/pages/booking_page.dart';
import 'package:rent_car_app/presentation/pages/chatting_page.dart';
import 'package:rent_car_app/presentation/pages/checkout_page.dart';
import 'package:rent_car_app/presentation/pages/complete_booking_page.dart';
import 'package:rent_car_app/presentation/pages/detail_order_page.dart';
import 'package:rent_car_app/presentation/pages/detail_page.dart';
import 'package:rent_car_app/presentation/pages/discover_page.dart';
import 'package:rent_car_app/presentation/pages/edit_profile_page.dart';
import 'package:rent_car_app/presentation/pages/location_page.dart';
import 'package:rent_car_app/presentation/pages/midtrans_web_view.dart';
import 'package:rent_car_app/presentation/pages/notification_page.dart';
import 'package:rent_car_app/presentation/pages/onboarding_page.dart';
import 'package:rent_car_app/presentation/pages/pin_page.dart';
import 'package:rent_car_app/presentation/pages/pin_setup_page.dart';
import 'package:rent_car_app/presentation/pages/saldo_page.dart';
import 'package:rent_car_app/presentation/pages/splash_screen.dart';
import 'package:rent_car_app/presentation/pages/top_up_page.dart';
import 'package:rent_car_app/presentation/viewModels/detail_order_view_model.dart';
import 'package:rent_car_app/presentation/viewModels/detail_view_model.dart';
import 'package:rent_car_app/presentation/viewModels/midtrans_web_view_model.dart';
import 'package:rent_car_app/routes/app_routes.dart';

class AppPages {
  AppPages._();

  static const initial = AppRoutes.splashScreen;

  static final routes = [
    GetPage(name: AppRoutes.splashScreen, page: () => const SplashScreen()),
    GetPage(
      name: AppRoutes.onboarding,
      page: () => OnBoardingPage(),
      binding: OnboardingBinding(),
    ),
    GetPage(
      name: AppRoutes.discover,
      page: () => DiscoverPage(),
      binding: DiscoverBinding(),
    ),
    GetPage(
      name: AppRoutes.auth,
      page: () => const AuthPage(),
      binding: AuthBinding(),
    ),
    GetPage(
      name: AppRoutes.detail,
      page: () => DetailPage(),
      binding: BindingsBuilder(() {
        final String productId = Get.arguments ?? "";
        Get.lazyPut<DetailViewModel>(() => DetailViewModel(productId));
      }),
    ),
    GetPage(
      name: AppRoutes.booking,
      page: () => BookingPage(),
      binding: BookingBinding(),
    ),
    GetPage(
      name: AppRoutes.checkout,
      page: () => CheckoutPage(),
      binding: CheckoutBinding(),
    ),
    GetPage(name: AppRoutes.pin, page: () => PinPage(), binding: PinBinding()),
    GetPage(
      name: AppRoutes.pinSetup,
      page: () => PinSetupPage(),
      binding: PinSetupBinding(),
    ),
    GetPage(
      name: AppRoutes.complete,
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
      name: AppRoutes.chatting,
      page: () => ChattingPage(),
      binding: ChatBinding(),
    ),
    GetPage(
      name: AppRoutes.editProfile,
      page: () => EditProfilePage(),
      binding: EditProfileBinding(),
    ),
    GetPage(
      name: AppRoutes.topUp,
      page: () => TopUpPage(),
      binding: TopUpBinding(),
    ),
    GetPage(
      name: AppRoutes.addProduct,
      page: () => AddProductPage(),
      binding: AddProductBinding(),
    ),
    GetPage(name: AppRoutes.notification, page: () => NotificationPage()),
    GetPage(name: AppRoutes.saldo, page: () => SaldoPage()),
    GetPage(
      name: AppRoutes.location,
      page: () => LocationPage(),
      binding: LocationBinding(),
    ),
    GetPage(
      name: AppRoutes.midtransWebView,
      page: () => const MidtransWebView(),
      binding: BindingsBuilder(() {
        Get.lazyPut<MidtransWebViewModel>(() => MidtransWebViewModel());
      }),
    ),
    GetPage(
      name: AppRoutes.detailOrder,
      page: () => DetailOrderPage(),
      binding: BindingsBuilder(() {
        final BookedCar? bookedCar = Get.arguments as BookedCar?;
        Get.lazyPut<DetailOrderViewModel>(
          () => DetailOrderViewModel(bookedCar),
        );
      }),
    ),
    GetPage(name: AppRoutes.aboutApp, page: () => const AboutAppPage()),
  ];
}
