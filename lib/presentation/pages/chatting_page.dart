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
  final discoverVM = Get.find<DiscoverViewModel>();

  String formatTime(Timestamp? timestamp) {
    if (timestamp == null) {
      return '';
    }
    final dateTime = timestamp.toDate();
    return DateFormat('HH:mm').format(dateTime);
  }

  @override
  Widget build(BuildContext context) {
    final args = Get.arguments as Map<String, dynamic>;
    final from = args['from'] as String? ?? 'listchat';
    final currentUser = controller.authVM.account.value;
    if (currentUser == null) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Color(0xffFF5722)),
          ),
        ),
      );
    }

    return Scaffold(
      body: Stack(
        children: [
          SafeArea(
            child: Column(
              children: [
                CustomHeader(
                  title: 'Chat',
                  onBackTap: () {
                    if (from == 'detail') {
                      Get.back();
                    } else {
                      Get.until((route) => route.settings.name == '/discover');
                      discoverVM.setFragmentIndex(2);
                    }
                  },
                ),
                Expanded(child: buildChat()),
                inputChat(currentUser.uid),
              ],
            ),
          ),
          const OfflineBanner(),
        ],
      ),
    );
  }

  Widget snippetCar(Map car) {
    final String productName = car['nameProduct'].length > 16
        ? '${car['nameProduct'].substring(0, 14)}...'
        : car['nameProduct'];

    return Container(
      height: 80,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      margin: const EdgeInsets.only(top: 8),
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
              'Booking',
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: const Color(0xffFF5722),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildChat() {
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
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('Chat kosong'));
          }

          final list = snapshot.data!.docs.toList();
          final Set<String> skippedIds = {};

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
                  snippetCar(firstChatWithProduct.productDetail!),
                  const Gap(16),
                  const DottedLine(
                    lineThickness: 2,
                    dashLength: 6,
                    dashGapLength: 6,
                    dashColor: Color(0xff393e52),
                  ),
                ],
                Expanded(
                  child: Align(
                    alignment: Alignment.topCenter,
                    child: ListView.builder(
                      padding: EdgeInsets.only(
                        top: (firstChatWithProduct != null) ? 12 : 0,
                        bottom: 8,
                      ),
                      reverse: true,
                      shrinkWrap: true,
                      itemCount: list.length,
                      itemBuilder: (context, index) {
                        Chat chat = Chat.fromJson(list[index].data());

                        if (skippedIds.contains(chat.chatId)) {
                          return const SizedBox.shrink();
                        }

                        if (chat.productDetail != null) {
                          Chat? nextChat;
                          if (index + 1 < list.length) {
                            nextChat = Chat.fromJson(list[index + 1].data());
                          }

                          if (nextChat != null &&
                              nextChat.senderId == controller.ownerId &&
                              nextChat.message.isNotEmpty) {
                            skippedIds.add(nextChat.chatId);
                          }

                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              productSnippetInChat(chat.productDetail!),
                              const SizedBox(height: 8),

                              if (chat.message.isNotEmpty)
                                chatBubble(chat, index == list.length - 1),

                              if (nextChat != null &&
                                  nextChat.message.isNotEmpty)
                                chatBubble(nextChat, false),
                            ],
                          );
                        }

                        return chatBubble(chat, index == list.length - 1);
                      },
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      );
    });
  }

  Widget chatBubble(Chat chat, bool isFirstMessage) {
    final currentUser = controller.authVM.account.value;
    final isCurrentUser = chat.senderId == currentUser?.uid;

    final partner = isCurrentUser ? currentUser : controller.partner;

    return Column(
      crossAxisAlignment: isCurrentUser
          ? CrossAxisAlignment.end
          : CrossAxisAlignment.start,
      children: [
        Container(
          margin: EdgeInsets.only(top: isFirstMessage ? 0 : 24),
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: isCurrentUser
                ? const Color(0xffFF5722).withAlpha(50)
                : Theme.of(Get.context!).colorScheme.surface,
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
              const Gap(8),
              Text(
                formatTime(chat.timeStamp),
                style: GoogleFonts.poppins(
                  fontSize: 10,
                  color: Theme.of(
                    Get.context!,
                  ).colorScheme.onSurface.withAlpha(128),
                ),
              ),
            ],
          ),
        ),
        const Gap(6),
        Row(
          mainAxisAlignment: isCurrentUser
              ? MainAxisAlignment.end
              : MainAxisAlignment.start,
          children: [
            if (!isCurrentUser) ...[
              CircleAvatar(
                radius: 14,
                backgroundImage: (partner?.photoUrl?.isNotEmpty ?? false)
                    ? NetworkImage(partner!.photoUrl!)
                    : const AssetImage('assets/ic_profile.png')
                          as ImageProvider,
              ),
              const Gap(8),
            ],
            Text(
              partner?.name ?? "Loading...",
              style: GoogleFonts.poppins(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: Theme.of(Get.context!).colorScheme.onSurface,
              ),
            ),
            if (isCurrentUser) ...[
              const Gap(8),
              CircleAvatar(
                radius: 14,
                backgroundImage: (partner?.photoUrl?.isNotEmpty ?? false)
                    ? NetworkImage(partner!.photoUrl!)
                    : const AssetImage('assets/ic_profile.png')
                          as ImageProvider,
              ),
            ],
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

  Widget productSnippetInChat(Map car) {
    final String productName = car['nameProduct'].length > 16
        ? '${car['nameProduct'].substring(0, 14)}...'
        : car['nameProduct'];

    return Container(
      margin: const EdgeInsets.fromLTRB(0, 12, 80, 0),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Theme.of(Get.context!).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Kamu bertanya tentang produk ini",
            style: GoogleFonts.poppins(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: Theme.of(Get.context!).colorScheme.secondary,
            ),
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              ExtendedImage.network(
                car['imageProduct'],
                width: 60,
                height: 60,
                fit: BoxFit.cover,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
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
                        color: Theme.of(Get.context!).colorScheme.secondary,
                      ),
                    ),
                    Text(
                      car['categoryProduct'],
                      style: GoogleFonts.poppins(
                        fontSize: 12,
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
                  'Lihat',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xffFF5722),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
