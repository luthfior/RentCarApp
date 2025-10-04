import 'dart:async';
import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:rent_car_app/core/constants/message.dart';
import 'package:rent_car_app/data/models/account.dart';
import 'package:rent_car_app/data/models/car.dart';
import 'package:rent_car_app/data/models/chat.dart';
import 'package:rent_car_app/data/services/notification_service.dart';
import 'package:rent_car_app/data/services/push_notification_service.dart';
import 'package:rent_car_app/data/sources/chat_source.dart';
import 'package:rent_car_app/data/sources/user_source.dart';
import 'package:rent_car_app/presentation/viewModels/auth_view_model.dart';
import 'package:uuid/uuid.dart';

class FavoriteViewModel extends GetxController {
  final firestore = FirebaseFirestore.instance;
  final authVM = Get.find<AuthViewModel>();
  final favoriteProducts = <Car>[].obs;
  final userSource = UserSource();

  final Rx<Car> _car = Car.empty.obs;
  Car get car => _car.value;
  set car(Car value) => _car.value = value;

  final Rx<Account?> _partner = Rx<Account?>(null);
  Account? get partner => _partner.value;
  set partner(Account? value) => _partner.value = value;

  final status = ''.obs;
  final hasShownTutorial = false.obs;
  StreamSubscription<QuerySnapshot>? _favoritesSubscription;
  final box = GetStorage();

  final _ownersMap = <String, Account>{}.obs;
  Map<String, Account> get ownersMap => _ownersMap;

  @override
  void onInit() {
    super.onInit();
    if (authVM.account.value != null) {
      fetchFavorites();
    } else {
      favoriteProducts.clear();
    }
  }

  @override
  void onClose() {
    _favoritesSubscription?.cancel();
    super.onClose();
  }

  void _checkAndShowTutorial() {
    final bool shouldShow =
        favoriteProducts.isNotEmpty &&
        !(box.read('hasShownSwipeTutorial') ?? false);
    hasShownTutorial.value = shouldShow;
  }

  void dismissTutorial() {
    box.write('hasShownSwipeTutorial', true);
    hasShownTutorial.value = false;
  }

  Future<void> _fetchAndAssignOwners(List<Car> cars) async {
    final ownerIds = cars.map((car) => car.ownerId).toSet().toList();
    if (ownerIds.isEmpty) return;
    final fetchedOwners = await UserSource.fetchAccountsByIds(ownerIds);
    _ownersMap.addAll(fetchedOwners);
    log('${fetchedOwners.length} data owner favorit berhasil diambil.');
  }

  Future<void> fetchFavorites() async {
    status.value = 'loading';
    final userId = authVM.account.value!.uid;

    await _favoritesSubscription?.cancel();
    _favoritesSubscription = firestore
        .collection('Users')
        .doc(userId)
        .collection('favProducts')
        .orderBy('timeStamp', descending: true)
        .snapshots()
        .listen(
          (snapshot) async {
            if (snapshot.docs.isEmpty) {
              favoriteProducts.clear();
              status.value = 'empty';
              _checkAndShowTutorial();
              return;
            }

            final List<String> carIds = snapshot.docs
                .map((doc) => doc.id)
                .toList();

            if (carIds.isNotEmpty) {
              try {
                final carsSnapshot = await firestore
                    .collection('Cars')
                    .where(FieldPath.documentId, whereIn: carIds)
                    .get();

                final List<Car> updatedCars = carsSnapshot.docs
                    .map((doc) => Car.fromJson(doc.data()))
                    .toList();

                final Map<String, Car> carMap = {
                  for (var car in updatedCars) car.id: car,
                };
                final List<Car> sortedCars = snapshot.docs.map((doc) {
                  return carMap[doc.id]!;
                }).toList();

                favoriteProducts.value = sortedCars;
                await _fetchAndAssignOwners(sortedCars);
                status.value = 'success';
              } catch (e) {
                log('Gagal fetch data mobil: $e');
                status.value = 'error';
              }
            } else {
              favoriteProducts.clear();
              status.value = 'empty';
            }

            _checkAndShowTutorial();
          },
          onError: (error) {
            favoriteProducts.clear();
            log('Gagal fetch favorit: $error');
            status.value = 'error';
            _checkAndShowTutorial();
          },
        );
  }

  Future<void> deleteFavorite(Car car) async {
    status.value = 'loading';
    final userId = authVM.account.value!.uid;
    try {
      await userSource.deleteFavoriteProduct(userId, car.id);
      Message.success('Produk berhasil dihapus dari Favorit');
    } catch (e) {
      log('Failed to toggle favorite status: $e');
      Message.error('Gagal menambahkan Produk ke Favorit');
    }
  }

  Future<void> fetchPartner(String id, String role) async {
    final collection = (role == 'admin') ? 'Admin' : 'Users';
    final doc = await firestore.collection(collection).doc(id).get();

    if (doc.exists) {
      partner = Account.fromJson(doc.data()!);
    }
  }

  Future<void> openChat(Car selectedCar) async {
    car = selectedCar;
    final currentUser = authVM.account.value!;
    final String roomId = '${currentUser.uid}_${car.ownerId}';

    final String partnerId = car.ownerId;
    final String partnerRole = car.ownerType;

    await fetchPartner(partnerId, partnerRole);
    if (partner == null) {
      Message.error('Gagal memulai chat.');
      return;
    }

    Get.dialog(
      const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Color(0xffFF5722)),
        ),
      ),
      barrierDismissible: false,
    );

    if (authVM.account.value != null && _partner.value != null) {
      try {
        Chat chat = Chat(
          chatId: const Uuid().v4(),
          message:
              'Halo, saya tertarik dengan mobil ${car.nameProduct} ${car.releaseProduct}.',
          receiverId: partner!.uid,
          senderId: currentUser.uid,
          productDetail: car.toJson(),
          timeStamp: Timestamp.now(),
        );
        await ChatSource.send(
          chat,
          roomId,
          buyerId: authVM.account.value!.uid,
          ownerId: car.ownerId,
          ownerType: car.ownerType,
          currentUser: currentUser,
          partner: partner!,
        );

        Get.back();
        Get.toNamed(
          '/chatting',
          arguments: {
            'roomId': roomId,
            'customerId': authVM.account.value!.uid,
            'ownerId': car.ownerId,
            'ownerType': car.ownerType,
            'from': 'favorite',
          },
        );

        final tokens = partner?.fcmTokens ?? [];
        if (tokens.isNotEmpty) {
          await PushNotificationService.sendToMany(
            tokens,
            "Chat Baru",
            "Kamu mendapat Chat baru dari ${currentUser.fullName.capitalizeFirst}",
            data: {'type': 'chat', 'referenceId': car.id},
          );
        }

        await NotificationService.addNotification(
          userId: partner!.uid,
          title: "Chat Baru",
          body: "Kamu mendapatkan Chat baru dari ${currentUser.fullName}",
          type: "chat",
          referenceId: roomId,
        );
      } catch (e) {
        Get.back();
        log('Gagal membuka chat: $e');
        Message.error('Gagal membuka chat. Coba lagi.');
      }
    } else {
      Get.back();
      log('Data Akun yang login & Data Partner tidak ada');
      Message.error('Gagal membuka chat. Coba lagi.');
    }
  }
}
