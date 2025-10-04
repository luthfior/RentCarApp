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
    if (timestamp == null) return '';
    final dateTime = timestamp.toDate();
    return DateFormat('HH:mm').format(dateTime);
  }

  @override
  Widget build(BuildContext context) {
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
                    if (connectivity.isOnline.value) {
                      controller.handleBackNavigation();
                    } else {
                      const OfflineBanner();
                      return;
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

  Widget buildChat() {
    return Obx(() {
      if (controller.partnerStatus.value == 'loading') {
        return const Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Color(0xffFF5722)),
          ),
        );
      }
      if (controller.partnerStatus.value == 'error') {
        return const Center(child: Text('Terjadi kesalahan'));
      }
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
            if (controller.from == 'order' ||
                controller.from == 'favorite' ||
                controller.from == 'detail-order') {
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  children: [
                    snippetCar(controller.productDetail!),
                    const Gap(24),
                    DottedLine(
                      lineThickness: 2,
                      dashLength: 6,
                      dashGapLength: 6,
                      dashColor: Theme.of(Get.context!).colorScheme.secondary,
                    ),
                    const Expanded(
                      child: Center(
                        child: Text('Mulai percakapan pertama Anda'),
                      ),
                    ),
                  ],
                ),
              );
            }
            return const Center(child: Text('Terjadi kesalahan'));
          }

          final list = controller.filterChats(snapshot.data!.docs.toList());

          return RefreshIndicator(
            onRefresh: () async {
              if (connectivity.isOnline.value) {
                await controller.refreshChat();
              } else {
                const OfflineBanner();
                return;
              }
            },
            color: const Color(0xffFF5722),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  if (controller.productDetail != null) ...[
                    snippetCar(controller.productDetail!),
                    const Gap(24),
                    DottedLine(
                      lineThickness: 2,
                      dashLength: 6,
                      dashGapLength: 6,
                      dashColor: Theme.of(Get.context!).colorScheme.secondary,
                    ),
                  ] else ...[
                    const Center(child: Text('Terjadi kesalahan.')),
                  ],
                  Expanded(
                    child: Align(
                      alignment: Alignment.topCenter,
                      child: ListView.builder(
                        padding: const EdgeInsets.only(top: 12, bottom: 8),
                        reverse: true,
                        shrinkWrap: true,
                        itemCount: list.length,
                        itemBuilder: (context, index) {
                          final chat = list[index];
                          if (chat.productDetail != null) {
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                productSnippetInChat(chat.productDetail!),
                                if (chat.message.isNotEmpty)
                                  chatBubble(chat, index == list.length - 1),
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
    String displayName = "";
    if (partner != null) {
      if (currentUser?.role == 'seller' || currentUser?.role == 'admin') {
        if (isCurrentUser) {
          displayName = currentUser?.storeName ?? currentUser?.fullName ?? '';
        } else {
          if (partner.username.contains('#')) {
            final parts = partner.username.split('#');
            final rawName = parts[0].replaceAll('_', ' ');
            final suffix = parts[1];
            final capitalized = rawName
                .split(' ')
                .map(
                  (w) => w.isNotEmpty
                      ? "${w[0].toUpperCase()}${w.substring(1)}"
                      : w,
                )
                .join(' ');
            displayName = "$capitalized #$suffix";
          } else {
            displayName = partner.fullName;
          }
        }
      } else {
        if (isCurrentUser) {
          displayName = (currentUser?.fullName ?? currentUser?.username)!;
        } else {
          displayName = partner.storeName;
        }
      }
    }
    return Column(
      crossAxisAlignment: isCurrentUser
          ? CrossAxisAlignment.end
          : CrossAxisAlignment.start,
      children: [
        Container(
          margin: EdgeInsets.only(top: isFirstMessage ? 24 : 24),
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
            if (!isCurrentUser)
              CircleAvatar(
                radius: 14,
                backgroundImage: (partner?.photoUrl?.isNotEmpty ?? false)
                    ? NetworkImage(partner!.photoUrl!)
                    : const AssetImage('assets/profile.png') as ImageProvider,
              ),
            if (!isCurrentUser) const Gap(8),
            Text(
              displayName,
              style: GoogleFonts.poppins(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: Theme.of(Get.context!).colorScheme.onSurface,
              ),
            ),
            if (isCurrentUser) const Gap(8),
            if (isCurrentUser)
              CircleAvatar(
                radius: 14,
                backgroundImage: (partner?.photoUrl?.isNotEmpty ?? false)
                    ? NetworkImage(partner!.photoUrl!)
                    : const AssetImage('assets/profile.png') as ImageProvider,
              ),
          ],
        ),
      ],
    );
  }

  Widget inputChat(String uid) {
    return Container(
      height: 52,
      margin: const EdgeInsets.all(24),
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
              onSubmitted: (_) async {
                if (connectivity.isOnline.value) {
                  await controller.sendMessageWithNotification();
                } else {
                  const OfflineBanner();
                  return;
                }
              },
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 16,
                color: Theme.of(Get.context!).colorScheme.onSurface,
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
            onPressed: () async {
              if (connectivity.isOnline.value) {
                await controller.sendMessageWithNotification();
              } else {
                const OfflineBanner();
                return;
              }
            },
            icon: const Icon(
              Icons.send_rounded,
              size: 24,
              color: Color(0xffFF5722),
            ),
          ),
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
            fit: BoxFit.cover,
            loadStateChanged: (state) {
              switch (state.extendedImageLoadState) {
                case LoadState.loading:
                  return const SizedBox(
                    width: 80,
                    height: 80,
                    child: Center(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(
                          Color(0xffFF5722),
                        ),
                      ),
                    ),
                  );
                case LoadState.completed:
                  return ExtendedImage(
                    image: state.imageProvider,
                    width: 80,
                    height: 80,
                    fit: BoxFit.cover,
                  );
                case LoadState.failed:
                  return Image.asset(
                    'assets/splash_screen.png',
                    width: 80,
                    height: 80,
                  );
              }
            },
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
              Get.toNamed('/detail', arguments: car["id"]);
            },
            child: Text(
              'Detail',
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: const Color(0xffFF5722),
              ),
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

    final currentUser = controller.authVM.account.value!;

    return Container(
      margin: const EdgeInsets.fromLTRB(0, 12, 75, 0),
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
                loadStateChanged: (state) {
                  switch (state.extendedImageLoadState) {
                    case LoadState.loading:
                      return const SizedBox(
                        width: 60,
                        height: 60,
                        child: Center(
                          child: CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Color(0xffFF5722),
                            ),
                          ),
                        ),
                      );
                    case LoadState.completed:
                      return ExtendedImage(
                        image: state.imageProvider,
                        width: 60,
                        height: 60,
                        fit: BoxFit.cover,
                      );
                    case LoadState.failed:
                      return Image.asset(
                        'assets/splash_screen.png',
                        width: 60,
                        height: 60,
                      );
                  }
                },
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
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              if (currentUser.role == 'customer') ...[
                GestureDetector(
                  onTap: () {
                    Get.toNamed('/booking', arguments: car);
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
            ],
          ),
        ],
      ),
    );
  }
}
