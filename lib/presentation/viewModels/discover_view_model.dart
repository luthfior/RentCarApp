import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:rent_car_app/data/models/car.dart';
import 'package:rent_car_app/presentation/viewModels/auth_view_model.dart';
import 'package:rent_car_app/presentation/viewModels/browse_view_model.dart';
import 'package:rent_car_app/presentation/viewModels/favorite_view_model.dart';
import 'package:rent_car_app/presentation/viewModels/order_view_model.dart';
import 'package:rent_car_app/presentation/viewModels/seller_view_model.dart';

class DiscoverViewModel extends GetxController {
  final authVM = Get.find<AuthViewModel>();
  final fragmentIndex = 0.obs;
  final userId = ''.obs;
  final userName = ''.obs;
  final userRole = ''.obs;

  final hasNewMessage = false.obs;

  @override
  void onInit() {
    super.onInit();
    if (authVM.account.value != null) {
      userId.value = authVM.account.value!.uid;
      userName.value = authVM.account.value!.fullName;
      userRole.value = authVM.account.value!.role;
      listenUnreadMessages();
    }

    final arguments = Get.arguments;
    if (arguments != null) {
      final int? newIndex = arguments['fragmentIndex'];
      final Car? bookedCar = arguments['bookedCar'];

      if (newIndex != null) {
        setFragmentIndex(newIndex);
      }
      if (bookedCar != null) {
        final browseVM = Get.find<BrowseViewModel>();
        browseVM.bookedCar.value = bookedCar;
      }
    }
  }

  void setFragmentIndex(int index) {
    if (Get.isSnackbarOpen) {
      Get.back();
    }
    fragmentIndex.value = index;
    if (userRole.value == 'seller') {
      switch (index) {
        case 0:
          Get.find<SellerViewModel>().fetchMyProducts();
          break;
        case 1:
          Get.find<OrderViewModel>().startOrdersListener();
          break;
        case 2:
          break;
        case 3:
          Get.find<AuthViewModel>().loadUser();
          break;
      }
    } else if (userRole.value == 'admin') {
      switch (index) {
        case 0:
          Get.find<BrowseViewModel>().startCarListeners();
          break;
        case 1:
          Get.find<SellerViewModel>().fetchMyProducts();
          break;
        case 2:
          Get.find<OrderViewModel>().startOrdersListener();
          break;
        case 3:
          break;
        case 4:
          Get.find<AuthViewModel>().loadUser();
          break;
      }
    } else {
      switch (index) {
        case 0:
          Get.find<BrowseViewModel>().startCarListeners();
          break;
        case 1:
          Get.find<OrderViewModel>().startOrdersListener();
          break;
        case 2:
          break;
        case 3:
          Get.find<FavoriteViewModel>().fetchFavorites();
          break;
        case 4:
          Get.find<AuthViewModel>().loadUser();
          break;
      }
    }
  }

  void listenUnreadMessages() {
    final firestore = FirebaseFirestore.instance;

    firestore
        .collection('Services')
        .where(
          userRole.value == 'customer' ? 'customerId' : 'ownerId',
          isEqualTo: userId.value,
        )
        .snapshots()
        .listen((snapshot) {
          bool adaPesanBaru = false;

          for (var doc in snapshot.docs) {
            final data = doc.data();

            if (userRole.value == 'customer') {
              final unread = (data['unreadCountCustomer'] ?? 0) as int;
              if (unread > 0) {
                adaPesanBaru = true;
                break;
              }
            } else {
              final unread = (data['unreadCountOwner'] ?? 0) as int;
              if (unread > 0) {
                adaPesanBaru = true;
                break;
              }
            }
          }

          hasNewMessage.value = adaPesanBaru;
        });
  }
}
