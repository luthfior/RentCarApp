import 'package:get/get.dart';
import 'package:rent_car_app/presentation/viewModels/chat_view_model.dart';

class ChatBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ChatViewModel>(() => ChatViewModel());
  }
}
