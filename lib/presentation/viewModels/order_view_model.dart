import 'dart:async';
import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:rent_car_app/data/models/booked_car.dart';
import 'package:rent_car_app/data/models/car.dart';
import 'package:rent_car_app/data/sources/user_source.dart';
import 'package:rent_car_app/presentation/viewModels/auth_view_model.dart';

class OrderViewModel extends GetxController {
  final firestore = FirebaseFirestore.instance;
  final authVM = Get.find<AuthViewModel>();
  final userSource = UserSource();

  final status = ''.obs;
  final bookedProducts = <BookedCar>[].obs;
  StreamSubscription<QuerySnapshot>? _ordersSubscription;

  @override
  void onInit() {
    super.onInit();
    if (authVM.account.value != null) {
      fetchBookedCars();
    } else {
      bookedProducts.clear();
    }
  }

  @override
  void onClose() {
    _ordersSubscription?.cancel();
    super.onClose();
  }

  Future<void> fetchBookedCars() async {
    status.value = 'loading';
    final userId = authVM.account.value!.uid;
    await _ordersSubscription?.cancel();

    _ordersSubscription = firestore
        .collection('Users')
        .doc(userId)
        .collection('bookedProducts')
        .orderBy('timeStamp', descending: true)
        .snapshots()
        .listen(
          (snapshot) async {
            if (snapshot.docs.isEmpty) {
              bookedProducts.clear();
              status.value = 'empty';
              return;
            }

            final List<String> carIds = snapshot.docs
                .map((doc) => doc.id)
                .toList();

            if (carIds.isNotEmpty) {
              final carsSnapshot = await firestore
                  .collection('Cars')
                  .where(FieldPath.documentId, whereIn: carIds)
                  .get();

              final Map<String, Car> carMap = {
                for (var doc in carsSnapshot.docs)
                  doc.id: Car.fromJson(doc.data()),
              };

              final List<BookedCar> updatedBookedCars = snapshot.docs.map((
                doc,
              ) {
                final car = carMap[doc.id];
                final orderStatus = doc.data()['status'] as String;
                return BookedCar(car: car!, status: orderStatus);
              }).toList();

              bookedProducts.value = updatedBookedCars;
              status.value = 'success';
            } else {
              bookedProducts.clear();
              status.value = 'empty';
            }
          },
          onError: (error) {
            log('Gagal fetch order: $error');
            status.value = 'error';
          },
        );
  }
}
