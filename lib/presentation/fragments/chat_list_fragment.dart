import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:rent_car_app/core/constants/message.dart';
import 'package:rent_car_app/data/services/connectivity_service.dart';

class ChatListFragment extends StatelessWidget {
  final String uid;
  final String role;
  ChatListFragment({super.key, required this.uid, required this.role});

  final connectivity = Get.find<ConnectivityService>();

  String formatChatTime(Timestamp? timestamp) {
    if (timestamp == null) return '';
    final now = DateTime.now();
    final date = timestamp.toDate();
    final diff = now.difference(date);

    if (diff.inDays == 0) {
      return DateFormat('HH:mm').format(date);
    } else if (diff.inDays == 1) {
      return "Kemarin";
    } else if (diff.inDays < 7) {
      return DateFormat.E('id_ID').format(date);
    } else {
      return DateFormat('dd/MM/yy').format(date);
    }
  }

  @override
  Widget build(BuildContext context) {
    final firestore = FirebaseFirestore.instance;
    final servicesRef = firestore.collection('Services');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Gap(30 + MediaQuery.of(context).padding.top),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Text(
            'Chat',
            style: GoogleFonts.poppins(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
        ),
        const Gap(20),
        Expanded(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                stream: (role == 'customer')
                    ? servicesRef
                          .where('customerId', isEqualTo: uid)
                          .snapshots()
                    : servicesRef.where('ownerId', isEqualTo: uid).snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(
                          Color(0xffFF5722),
                        ),
                      ),
                    );
                  }
                  final docs = snapshot.data!.docs;
                  if (docs.isEmpty) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 40),
                        child: Text(
                          "Kamu tidak memiliki Chat",
                          style: GoogleFonts.poppins(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: Theme.of(context).colorScheme.secondary,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    );
                  }

                  final containerHeight = constraints.maxHeight * 0.85;

                  return Align(
                    alignment: Alignment.topCenter,
                    child: Container(
                      height: containerHeight,
                      margin: const EdgeInsets.symmetric(horizontal: 24),
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surface,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: ListView.separated(
                        padding: EdgeInsets.zero,
                        itemCount: docs.length,
                        separatorBuilder: (_, __) => Divider(
                          height: 1,
                          thickness: 0.8,
                          color: Colors.grey.shade300,
                          indent: 72,
                        ),
                        itemBuilder: (context, index) {
                          final data = docs[index].data();
                          final roomId = data['roomId'] as String;
                          final lastMessage =
                              data['lastMessage'] as String? ?? '';
                          final ownerStoreName =
                              data['ownerStoreName'] as String? ??
                              'Tidak diketahui';
                          final ownerEmail =
                              data['ownerEmail'] as String? ??
                              'Tidak diketahui';
                          final ownerPhotoUrl =
                              data['ownerPhotoUrl'] as String? ?? '';
                          final ownerType = data['ownerType'] as String? ?? '';

                          String customerUsername;
                          if (data['customerUsername'] != null &&
                              (data['customerUsername'] as String).contains(
                                '#',
                              )) {
                            final parts = (data['customerUsername'] as String)
                                .split('#');
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
                            customerUsername = "$capitalized #$suffix";
                          } else {
                            customerUsername =
                                data['customerFullname'] ?? 'Tidak diketahui';
                          }

                          final customerEmail =
                              data['customerEmail'] as String? ??
                              'Tidak diketahui';
                          final customerPhotoUrl =
                              data['customerPhotoUrl'] as String? ?? '';

                          final lastTimestamp =
                              data['lastMessageTime'] as Timestamp?;
                          final formattedTime = formatChatTime(lastTimestamp);

                          final parts = roomId.split('_');
                          final buyerId = parts[0];
                          final ownerId = parts.length > 1 ? parts[1] : '';

                          final chatName = (role == 'customer')
                              ? ownerStoreName
                              : customerUsername;
                          final chatEmail = (role == 'customer')
                              ? ownerEmail
                              : customerEmail;
                          final chatPhotoUrl = (role == 'customer')
                              ? ownerPhotoUrl
                              : customerPhotoUrl;

                          final unreadCount = (role == 'customer')
                              ? (data['unreadCountCustomer'] as int? ?? 0)
                              : (data['unreadCountOwner'] as int? ?? 0);

                          return ListTile(
                            dense: true,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            leading: CircleAvatar(
                              radius: 22,
                              backgroundImage:
                                  (chatPhotoUrl.isNotEmpty
                                          ? NetworkImage(chatPhotoUrl)
                                          : const AssetImage(
                                              'assets/profile.png',
                                            ))
                                      as ImageProvider,
                            ),
                            title: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    chatName,
                                    style: GoogleFonts.poppins(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.onSurface,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                Text(
                                  formattedTime,
                                  style: GoogleFonts.poppins(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w400,
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.secondary,
                                  ),
                                ),
                              ],
                            ),
                            subtitle: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    lastMessage,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: GoogleFonts.poppins(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w400,
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.secondary,
                                    ),
                                  ),
                                ),
                                if (unreadCount > 0) ...[
                                  const SizedBox(height: 4),
                                  Container(
                                    padding: const EdgeInsets.all(6),
                                    decoration: const BoxDecoration(
                                      color: Color(0xffFF5722),
                                      shape: BoxShape.circle,
                                    ),
                                    child: Text(
                                      unreadCount.toString(),
                                      style: const TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                            onTap: () async {
                              if (connectivity.isOnline.value) {
                                Get.dialog(
                                  const Center(
                                    child: CircularProgressIndicator(
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        Color(0xffFF5722),
                                      ),
                                    ),
                                  ),
                                  barrierDismissible: false,
                                );
                                try {
                                  final partnerInfo = {
                                    'id': (role == 'customer')
                                        ? ownerId
                                        : buyerId,
                                    'type': (role == 'customer')
                                        ? ownerType
                                        : 'user',
                                    'fullName': chatName,
                                    'username': (role == 'customer')
                                        ? ownerStoreName
                                        : customerUsername,
                                    'storeName': (role == 'customer')
                                        ? ownerStoreName
                                        : '',
                                    'email': chatEmail,
                                    'photoUrl': chatPhotoUrl,
                                  };

                                  final roomRef = FirebaseFirestore.instance
                                      .collection('Services')
                                      .doc(roomId);

                                  await roomRef.update({
                                    if (role == 'customer')
                                      'unreadCountCustomer': 0,
                                    if (role != 'customer')
                                      'unreadCountOwner': 0,
                                  });

                                  Get.back();

                                  Get.toNamed(
                                    '/chatting',
                                    arguments: {
                                      'roomId': roomId,
                                      'uid': buyerId,
                                      'ownerId': ownerId,
                                      'ownerType': ownerType,
                                      'partner': partnerInfo,
                                      'from': 'listchat',
                                    },
                                  );
                                } catch (e) {
                                  Get.back();
                                  log('Gagal membuka chat: $e');
                                  Message.error(
                                    'Gagal membuka chat. Coba lagi.',
                                  );
                                }
                              } else {
                                null;
                              }
                            },
                          );
                        },
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
        const Gap(20),
      ],
    );
  }
}
