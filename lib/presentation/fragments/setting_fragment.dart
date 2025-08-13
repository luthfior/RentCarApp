import 'package:d_session/d_session.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:rent_car_app/data/models/account.dart';
import 'package:rent_car_app/presentation/viewModels/auth_view_model.dart';

class SettingFragment extends StatelessWidget {
  SettingFragment({super.key});

  final authVM = Get.find<AuthViewModel>();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(0),
      children: [
        Gap(30 + MediaQuery.of(context).padding.top),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Text(
            'Pengaturan',
            style: GoogleFonts.poppins(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: const Color(0xff070623),
            ),
          ),
        ),
        const Gap(20),
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 24),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            children: [
              buildProfile(),
              const Gap(40),
              buildDarkMode(),
              const Gap(20),
              buildItemSettings(
                icon: 'assets/ic_profile.png',
                title: 'Sunting Profil',
                onTap: () {},
              ),
              const Gap(20),
              buildItemSettings(
                icon: 'assets/ic_wallet.png',
                title: 'Dompet Digital',
                onTap: null,
              ),
              const Gap(20),
              buildItemSettings(
                icon: 'assets/ic_key.png',
                title: 'Ganti Kata Sandi',
                onTap: null,
              ),
              const Gap(20),
              buildItemSettings(
                icon: 'assets/ic_logout.png',
                title: 'Keluar',
                onTap: () => authVM.logout(),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget buildProfile() {
    return FutureBuilder(
      future: DSession.getUser(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        Account account = Account.fromJson(Map.from(snapshot.data!));
        return Row(
          children: [
            Image.asset('assets/profile.png', width: 50, height: 50),
            const Gap(20),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  account.name,
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xff070623),
                  ),
                ),
                Text(
                  account.email,
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                    color: const Color(0xff838384),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  Widget buildItemSettings({
    required String icon,
    required String title,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 52,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(50),
          border: Border.all(color: const Color(0xffEFEEF7), width: 1),
        ),
        child: Row(
          children: [
            Image.asset(icon, width: 24, height: 24),
            const Gap(10),
            Expanded(
              child: Text(
                title,
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                  color: const Color(0xff070623),
                ),
              ),
            ),
            Image.asset('assets/ic_arrow_next.png', width: 20, height: 20),
          ],
        ),
      ),
    );
  }

  Widget buildDarkMode() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Mode Gelap',
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: const Color(0xff070623),
            ),
          ),
          Image.asset('assets/ic_dark.png', width: 24),
        ],
      ),
    );
  }
}
