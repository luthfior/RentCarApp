import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dotted_line/dotted_line.dart';
import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:rent_car_app/data/models/chat.dart';
import 'package:rent_car_app/data/services/connectivity_service.dart';
import 'package:rent_car_app/presentation/viewModels/chat_view_model.dart';
import 'package:rent_car_app/presentation/viewModels/discover_view_model.dart';
import 'package:rent_car_app/presentation/widgets/custom_header.dart';
import 'package:rent_car_app/presentation/widgets/offline_banner.dart';

class ChattingPage extends GetView<ChatViewModel> {
  ChattingPage({super.key});

  final connectivity = Get.find<ConnectivityService>();

  String _formatTime(Timestamp? timestamp) {
    if (timestamp == null) {
      return '';
    }
    final dateTime = timestamp.toDate();
    return DateFormat('HH:mm').format(dateTime);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Column(
            children: [
              Gap(20 + MediaQuery.of(context).padding.top),
              CustomHeader(
                title: 'Chat',
                onBackTap: () {
                  Get.until((route) => route.settings.name == '/discover');
                  Get.find<DiscoverViewModel>().setFragmentIndex(0);
                },
              ),
              Expanded(child: _buildChat()),
              inputChat(controller.authVM.account.value!.uid),
            ],
          ),
          const OfflineBanner(),
        ],
      ),
    );
  }

  Widget _snippetCar(Map car) {
    final String productName = car['nameProduct'].length > 16
        ? '${car['nameProduct'].substring(0, 14)}...'
        : car['nameProduct'];

    return Container(
      height: 80,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      margin: const EdgeInsets.only(top: 24),
      decoration: BoxDecoration(
        color: Theme.of(Get.context!).colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          ExtendedImage.network(
            car['imageProduct'],
            width: 80,
            height: 80,
            fit: BoxFit.contain,
          ),
          const Gap(5),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  productName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(Get.context!).colorScheme.onSurface,
                  ),
                ),
                Text(
                  car['transmissionProduct'],
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    color: Theme.of(Get.context!).colorScheme.secondary,
                  ),
                ),
                Text(
                  car['categoryProduct'],
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    color: Theme.of(Get.context!).colorScheme.secondary,
                  ),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: () {
              Get.toNamed('/detail', arguments: car['id'].toString());
            },
            child: Text(
              'Lihat Detail',
              style: GoogleFonts.poppins(
                decorationThickness: 1,
                decoration: TextDecoration.underline,
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Theme.of(Get.context!).colorScheme.onSurface,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChat() {
    return Obx(() {
      if (controller.streamChat == null) {
        return const Center(child: Text('Memuat Chat...'));
      }
      return StreamBuilder(
        stream: controller.streamChat,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xffFF5722)),
              ),
            );
          }
          if (snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('Chat kosong'));
          }
          final list = snapshot.data!.docs.toList();
          Chat? firstChatWithProduct;
          for (var doc in list) {
            final chat = Chat.fromJson(doc.data());
            if (chat.productDetail != null) {
              firstChatWithProduct = chat;
              break;
            }
          }
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              children: [
                if (firstChatWithProduct != null) ...[
                  _snippetCar(firstChatWithProduct.productDetail!),
                  const Gap(16),
                  const DottedLine(
                    lineThickness: 1,
                    dashLength: 6,
                    dashGapLength: 6,
                    dashColor: Color(0xff393e52),
                  ),
                ],
                Expanded(
                  child: ListView.builder(
                    padding: EdgeInsets.only(
                      top: (firstChatWithProduct != null) ? 12 : 0,
                    ),
                    reverse: true,
                    itemCount: list.length,
                    itemBuilder: (context, index) {
                      Chat chat = Chat.fromJson(list[index].data());
                      final isFirstMessageOnScreen = index == list.length - 1;
                      if (chat.senderId == 'customerService') {
                        return _chatAdmin(chat);
                      } else {
                        return _chatUser(chat, isFirstMessageOnScreen);
                      }
                    },
                  ),
                ),
              ],
            ),
          );
        },
      );
    });
  }

  Widget _chatUser(Chat chat, bool isFirstMessage) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          margin: EdgeInsets.only(top: isFirstMessage ? 18 : 14),
          decoration: BoxDecoration(
            color: Theme.of(Get.context!).colorScheme.surface,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Flexible(
                child: Text(
                  chat.message,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(Get.context!).colorScheme.onSurface,
                  ),
                ),
              ),
              const Gap(12),
              Text(
                _formatTime(chat.timeStamp),
                style: GoogleFonts.poppins(
                  fontSize: 10,
                  color: Theme.of(
                    Get.context!,
                  ).colorScheme.onSurface.withAlpha(127),
                ),
              ),
            ],
          ),
        ),
        const Gap(12),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Expanded(
              child: Text(
                controller.username.toString(),
                textAlign: TextAlign.end,
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Theme.of(Get.context!).colorScheme.onSurface,
                ),
              ),
            ),
            const Gap(8),
            Image.asset('assets/chat_profile.png', width: 30, height: 30),
          ],
        ),
      ],
    );
  }

  Widget _chatAdmin(Chat chat) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          margin: const EdgeInsets.only(top: 12),
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Theme.of(Get.context!).colorScheme.surface,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Flexible(
                child: Text(
                  chat.message,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(Get.context!).colorScheme.onSurface,
                  ),
                ),
              ),
              const Gap(12),
              Text(
                _formatTime(chat.timeStamp),
                style: GoogleFonts.poppins(
                  fontSize: 10,
                  color: Theme.of(
                    Get.context!,
                  ).colorScheme.onSurface.withAlpha(127),
                ),
              ),
            ],
          ),
        ),
        const Gap(12),
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(50),
              ),
              child: Image.asset('assets/logo_app.png', width: 25, height: 25),
            ),
            const Gap(8),
            Expanded(
              child: Text(
                chat.senderId,
                textAlign: TextAlign.start,
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Theme.of(Get.context!).colorScheme.onSurface,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget inputChat(String uid) {
    return Container(
      height: 52,
      margin: const EdgeInsets.fromLTRB(24, 24, 24, 30),
      padding: const EdgeInsets.only(left: 16),
      decoration: BoxDecoration(
        color: Theme.of(Get.context!).colorScheme.surface,
        borderRadius: BorderRadius.circular(50),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: controller.edtInput,
              onSubmitted: (_) => controller.sendMessage(),
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 16,
                color: Color(0xff070623),
              ),
              decoration: InputDecoration(
                contentPadding: const EdgeInsets.all(0),
                isDense: true,
                border: InputBorder.none,
                hintText: 'Kirim pesan Anda...',
                hintStyle: TextStyle(
                  fontWeight: FontWeight.w400,
                  fontSize: 16,
                  color: Theme.of(Get.context!).colorScheme.onSurface,
                ),
              ),
            ),
          ),
          IconButton(
            onPressed: () => controller.sendMessage(),
            icon: ColorFiltered(
              colorFilter: const ColorFilter.mode(
                Color(0xffFF5722),
                BlendMode.srcIn,
              ),
              child: Image.asset('assets/ic_send.png', height: 24, width: 24),
            ),
          ),
        ],
      ),
    );
  }
}
