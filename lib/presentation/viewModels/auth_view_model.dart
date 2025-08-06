import 'package:get/get.dart';
import 'package:rent_car_app/data/models/account.dart';
import 'package:d_session/d_session.dart';

class AuthViewModel extends GetxController {
  Rx<Account?> account = Rx<Account?>(null);

  Future<void> loadUser() async {
    final user = await DSession.getUser();
    if (user != null) {
      account.value = Account.fromJson(Map.from(user));
    } else {
      account.value = null;
    }
  }
}
