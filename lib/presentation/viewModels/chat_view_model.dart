import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:rent_car_app/data/models/account.dart';
import 'package:rent_car_app/presentation/viewModels/auth_view_model.dart';

class ChatViewModel extends GetxController {
  final authVM = Get.find<AuthViewModel>();

  final Rx<String?> _uid = Rx<String?>(null);
  String? get uid => _uid.value;
  set uid(String? value) => _uid.value = value;

  final Rx<String?> _username = Rx<String?>(null);
  String? get username => _username.value;
  set username(String? value) => _username.value = value;

  final _firestore = FirebaseFirestore.instance;
  final Rx<Stream<QuerySnapshot<Map<String, dynamic>>>?> _streamChat =
      Rx<Stream<QuerySnapshot<Map<String, dynamic>>>?>(null);
  Stream<QuerySnapshot<Map<String, dynamic>>>? get streamChat =>
      _streamChat.value;

  @override
  void onInit() {
    super.onInit();
    authVM.loadUser();
    ever(authVM.account, (Account? account) {
      if (account != null) {
        uid = account.uid;
        username = account.name;

        _streamChat.value = _firestore
            .collection('Services')
            .doc(uid)
            .collection('chats')
            .snapshots();
      }
    });
  }
}
