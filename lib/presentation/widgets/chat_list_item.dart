import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:rent_car_app/data/services/connectivity_service.dart';

class ChatListItem extends StatelessWidget {
  final Map<String, dynamic> serviceData;
  final String currentUserRole;
  final String currentUserId;
  final String Function(Timestamp?) formatChatTime;

  const ChatListItem({
    super.key,
    required this.serviceData,
    required this.currentUserRole,
    required this.currentUserId,
    required this.formatChatTime,
  });

  Future<DocumentSnapshot> _fetchPartnerData(
    String partnerId,
    String partnerCollection,
  ) {
    return FirebaseFirestore.instance
        .collection(partnerCollection)
        .doc(partnerId)
        .get();
  }

  @override
  Widget build(BuildContext context) {
    final ownerId = serviceData['ownerId'] as String;
    final customerId = serviceData['customerId'] as String;
    final ownerType = serviceData['ownerType'] as String;

    final bool isUserCustomer = currentUserRole == 'customer';
    final String partnerId = isUserCustomer ? ownerId : customerId;
    final String partnerCollection = isUserCustomer
        ? ((ownerType == 'admin') ? 'Admin' : 'Users')
        : 'Users';
    return FutureBuilder<DocumentSnapshot>(
      future: _fetchPartnerData(partnerId, partnerCollection),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const ListTile(
            leading: CircleAvatar(radius: 22, backgroundColor: Colors.grey),
            title: Text('Memuat...'),
            subtitle: Text('...'),
          );
        }
        if (!snapshot.hasData || snapshot.hasError || !snapshot.data!.exists) {
          return ListTile(
            leading: const CircleAvatar(
              radius: 22,
              backgroundImage:
                  AssetImage('assets/profile.png') as ImageProvider,
            ),
            title: const Text('Gagal memuat data'),
            subtitle: Text(
              isUserCustomer
                  ? 'Penjual tidak ditemukan'
                  : 'Pelanggan tidak ditemukan',
            ),
          );
        }

        final partnerData = snapshot.data!.data() as Map<String, dynamic>;
        String customerUsername;
        if (partnerData['username'] != null &&
            (partnerData['username'] as String).contains('#')) {
          final parts = (partnerData['username'] as String).split('#');
          final rawName = parts[0].replaceAll('_', ' ');
          final suffix = parts[1];
          final capitalized = rawName
              .split(' ')
              .map(
                (w) =>
                    w.isNotEmpty ? "${w[0].toUpperCase()}${w.substring(1)}" : w,
              )
              .join(' ');
          customerUsername = "$capitalized #$suffix";
        } else {
          customerUsername =
              partnerData['customerFullname'] ?? 'Tidak diketahui';
        }
        final String chatName = isUserCustomer
            ? (partnerData['storeName'] ?? 'Tidak diketahui')
            : customerUsername;
        final String chatPhotoUrl = partnerData['photoUrl'] ?? '';

        final roomId = serviceData['roomId'] as String;
        final lastMessage = serviceData['lastMessage'] as String? ?? '';
        final lastTimestamp = serviceData['lastMessageTime'] as Timestamp?;
        final formattedTime = formatChatTime(lastTimestamp);

        final unreadCount = isUserCustomer
            ? (serviceData['unreadCountCustomer'] as int? ?? 0)
            : (serviceData['unreadCountOwner'] as int? ?? 0);

        final connectivity = Get.find<ConnectivityService>();

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
                        : const AssetImage('assets/profile.png'))
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
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Text(
                formattedTime,
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                  color: Theme.of(context).colorScheme.secondary,
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
                    color: Theme.of(context).colorScheme.secondary,
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
                final roomRef = FirebaseFirestore.instance
                    .collection('Services')
                    .doc(roomId);
                await roomRef.update({
                  if (isUserCustomer) 'unreadCountCustomer': 0,
                  if (!isUserCustomer) 'unreadCountOwner': 0,
                });
                Get.back();
                Get.toNamed(
                  '/chatting',
                  arguments: {
                    'roomId': roomId,
                    'customerId': customerId,
                    'ownerId': ownerId,
                    'ownerType': ownerType,
                    'from': 'listchat',
                  },
                );
              } catch (e) {
                Get.back();
              }
            }
          },
        );
      },
    );
  }
}
