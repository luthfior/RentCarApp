import 'package:get/get.dart';

class DiscoverViewModel extends GetxController {
  final fragmentIndex = 0.obs;

  void setFragmentIndex(int index) {
    fragmentIndex.value = index;
  }
}
