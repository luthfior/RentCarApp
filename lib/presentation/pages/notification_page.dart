import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:rent_car_app/data/services/connectivity_service.dart';
import 'package:rent_car_app/presentation/viewModels/discover_view_model.dart';
import 'package:rent_car_app/presentation/viewModels/notification_view_model.dart';
import 'package:rent_car_app/presentation/widgets/custom_header.dart';
import 'package:rent_car_app/presentation/widgets/offline_banner.dart';

class NotificationPage extends GetView<NotificationViewModel> {
  NotificationPage({super.key});
  final discoverVM = Get.find<DiscoverViewModel>();
  final connectivity = Get.find<ConnectivityService>();

  String formatNotifTime(Timestamp? timestamp) {
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
    return Scaffold(
      body: Stack(
        children: [
          SafeArea(
            child: Column(
              children: [
                CustomHeader(title: 'Notifikasi'),
                const Gap(20),
                Expanded(
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      return Obx(() {
                        if (controller.notifications.isEmpty) {
                          return Center(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 40,
                              ),
                              child: Text(
                                "Kamu tidak memiliki Notifikasi",
                                style: GoogleFonts.poppins(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.secondary,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          );
                        }
                        final containerHeight = constraints.maxHeight * 0.95;
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
                            child: RefreshIndicator(
                              onRefresh: () async {
                                if (connectivity.isOnline.value) {
                                  await controller.refreshNotifications();
                                } else {
                                  const OfflineBanner();
                                  return;
                                }
                              },
                              color: const Color(0xffFF5722),
                              child: ListView.separated(
                                padding: EdgeInsets.zero,
                                itemCount: controller.notifications.length,
                                separatorBuilder: (_, __) => Divider(
                                  height: 1,
                                  thickness: 0.8,
                                  color: Colors.grey.shade300,
                                  indent: 72,
                                ),
                                itemBuilder: (context, index) {
                                  final notif = controller.notifications[index];
                                  final formattedTime = formatNotifTime(
                                    notif.createdAt,
                                  );
                                  return ListTile(
                                    leading: Icon(
                                      notif.type == 'chat'
                                          ? Icons.chat
                                          : notif.type == 'order'
                                          ? Icons.shopping_bag
                                          : Icons.info,
                                      color: const Color(0xffFF5722),
                                    ),
                                    title: Text(
                                      notif.title,
                                      style: GoogleFonts.poppins(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        color: Theme.of(
                                          Get.context!,
                                        ).colorScheme.onSurface,
                                      ),
                                    ),
                                    subtitle: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          notif.body,
                                          style: GoogleFonts.poppins(
                                            fontSize: 13,
                                            fontWeight: FontWeight.w400,
                                            color: Theme.of(
                                              context,
                                            ).colorScheme.onSurface,
                                          ),
                                        ),
                                        const Gap(4),
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
                                    trailing: notif.isRead
                                        ? null
                                        : const Icon(
                                            Icons.circle,
                                            color: Color(0xffFF2056),
                                            size: 10,
                                          ),
                                    onTap: () {
                                      controller.markAsRead(notif.id);

                                      if (notif.type == 'chat') {
                                        if (controller
                                                .authVM
                                                .account
                                                .value
                                                ?.role ==
                                            'admin') {
                                          Get.until(
                                            (route) =>
                                                route.settings.name ==
                                                '/discover',
                                          );
                                          discoverVM.setFragmentIndex(3);
                                        } else {
                                          Get.until(
                                            (route) =>
                                                route.settings.name ==
                                                '/discover',
                                          );
                                          discoverVM.setFragmentIndex(2);
                                        }
                                      } else if (notif.type == 'order') {
                                        if (controller
                                                .authVM
                                                .account
                                                .value
                                                ?.role ==
                                            'admin') {
                                          Get.until(
                                            (route) =>
                                                route.settings.name ==
                                                '/discover',
                                          );
                                          discoverVM.setFragmentIndex(2);
                                        } else {
                                          Get.until(
                                            (route) =>
                                                route.settings.name ==
                                                '/discover',
                                          );
                                          discoverVM.setFragmentIndex(1);
                                        }
                                      } else {
                                        if (controller
                                                .authVM
                                                .account
                                                .value
                                                ?.role ==
                                            'admin') {
                                          Get.until(
                                            (route) =>
                                                route.settings.name ==
                                                '/discover',
                                          );
                                          discoverVM.setFragmentIndex(0);
                                        } else {
                                          Get.until(
                                            (route) =>
                                                route.settings.name ==
                                                '/discover',
                                          );
                                          discoverVM.setFragmentIndex(0);
                                        }
                                      }
                                    },
                                  );
                                },
                              ),
                            ),
                          ),
                        );
                      });
                    },
                  ),
                ),
              ],
            ),
          ),
          const OfflineBanner(),
        ],
      ),
    );
  }
}
