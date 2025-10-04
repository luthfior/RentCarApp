import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:rent_car_app/data/models/account.dart';
import 'package:rent_car_app/data/services/connectivity_service.dart';
import 'package:rent_car_app/presentation/widgets/chat_list_item.dart';
import 'package:rent_car_app/presentation/widgets/offline_banner.dart';

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

  final Rx<Account?> _partner = Rx<Account?>(null);
  Account? get partner => _partner.value;
  set partner(Account? value) => _partner.value = value;

  Future<void> fetchPartner(String id, String role) async {
    final collection = (role == 'admin') ? 'Admin' : 'Users';
    final doc = await FirebaseFirestore.instance
        .collection(collection)
        .doc(id)
        .get();

    if (doc.exists) {
      partner = Account.fromJson(doc.data()!);
    }
  }

  Future<void> handleRefresh() async {
    await Future.delayed(const Duration(milliseconds: 500));
  }

  @override
  Widget build(BuildContext context) {
    final firestore = FirebaseFirestore.instance;
    final servicesRef = firestore.collection('Services');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Gap(20 + MediaQuery.of(context).padding.top),
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
                          .orderBy('lastMessageTime', descending: true)
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
                          "Kamu belum memiliki Chat. Mulai Chat dengan menanyakan Produk yang ingin Anda pesan",
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Theme.of(context).colorScheme.secondary,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    );
                  }

                  final containerHeight = constraints.maxHeight * 0.80;

                  return RefreshIndicator(
                    onRefresh: () async {
                      if (connectivity.isOnline.value) {
                        return handleRefresh();
                      } else {
                        const OfflineBanner();
                        return;
                      }
                    },
                    color: const Color(0xffFF5722),
                    child: Align(
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
                            final serviceData = docs[index].data();

                            return ChatListItem(
                              serviceData: serviceData,
                              currentUserRole: role,
                              currentUserId: uid,
                              formatChatTime: formatChatTime,
                            );
                          },
                        ),
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
        const Gap(20),
        const OfflineBanner(),
      ],
    );
  }
}
