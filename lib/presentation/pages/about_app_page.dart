import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:rent_car_app/presentation/widgets/custom_header.dart';

class AboutAppPage extends StatelessWidget {
  const AboutAppPage({super.key});

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            CustomHeader(title: 'Tentang'),
            const Gap(20),
            Expanded(
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    children: [
                      Image.asset(
                        isDarkMode
                            ? 'assets/logo_text_16_9_dark_mode.png'
                            : 'assets/logo_text_16_9.png',
                        height: 90,
                      ),
                      const Gap(20),
                      RichText(
                        textAlign: TextAlign.justify,
                        text: TextSpan(
                          text: 'Rental+',
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                          children: [
                            TextSpan(
                              text:
                                  ' merupakan Aplikasi pribadi bersifat non-commercial yang dikembangkan oleh Developer sebagai bentuk untuk mengembangkan skill Mobile Development dan Portofolio sebagai Android Developer. \nAplikasi ',
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: Theme.of(context).colorScheme.onSurface,
                              ),
                            ),
                            TextSpan(
                              text: 'Rental+',
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: Theme.of(context).colorScheme.onSurface,
                              ),
                            ),
                            TextSpan(
                              text:
                                  " adalah aplikasi untuk melakukan sewa dan **menyewakan berbagai jenis barang dan kendaraan dari berbagai kategori.** dengan demo pembayaran menggunakan Midtrans Sandbox (untuk berbagai metode pembayaran seperti Gopay, Shopee, Dana, dsb), e-wallet buatan bernama 'DompetKu', dan pembayaran Tunai. \nAdapun Aplikasi ini memiliki dibuat menggunakan Flutter dan teknologi atau tools lain yang akan dijelaskan dibawah.",
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: Theme.of(context).colorScheme.onSurface,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Gap(8),
                      Text(
                        'Aplikasi ini memiliki beberapa fitur yaitu diantaranya sebagai berikut:',
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                      const Gap(8),
                      _buildFeatureItem(
                        context,
                        title: 'Rental Barang',
                        description:
                            'Sewa dan sewakan berbagai jenis produk, mulai dari mobil, truk, motor, sepeda, hingga kategori lainnya yang bisa Anda tentukan sendiri.',
                      ),
                      _buildFeatureItem(
                        context,
                        title: 'Dua Peran Pengguna',
                        description:
                            'Berperan sebagai Penyewa (Customer) untuk mencari barang, atau sebagai Penyedia (Seller) untuk membuka lapak rental Anda sendiri.',
                      ),
                      _buildFeatureItem(
                        context,
                        title: 'Push Notifikasi',
                        description:
                            'Menampilkan Notifikasi Aplikasi ketika terdapat Chat baru, Produk Baru (untuk Customer), Pesanan Baru (untuk Seller), Status Pesanan (untuk Customer)',
                      ),
                      _buildFeatureItem(
                        context,
                        title: 'Chat Real-Time',
                        description:
                            'Berkomunikasi langsung antara penyewa dan penyedia melalui fitur chat di dalam aplikasi.',
                      ),
                      _buildFeatureItem(
                        context,
                        title:
                            'Sistem Booking dan Pembayaran (Khusus Tampilan Customer)',
                        description:
                            "Alur pemesanan lengkap dengan integrasi pembayaran demo Midtrans Sandbox (untuk berbagai metode pembayaran seperti Gopay, Shopee, Dana, dsb), opsi e-wallet buatan bernama 'DompetKu', dan opsi pembayaran Tunai.",
                      ),
                      _buildFeatureItem(
                        context,
                        title:
                            'Upload, Sunting, dan Hapus Produk (Khusus Tampilan Seller)',
                        description:
                            "Menambahkan, sunting, dan hapus produk di halaman Seller",
                      ),
                      _buildFeatureItem(
                        context,
                        title: 'Cari Produk',
                        description:
                            'Melakukan pencarian produk untuk mempermudah pengguna dalam menampilkan produk yang ingin dicari',
                      ),
                      _buildFeatureItem(
                        context,
                        title: 'Notifikasi UI',
                        description:
                            'Menampilkan Notifikasi yang tersimpan didalam Aplikasi',
                      ),
                      _buildFeatureItem(
                        context,
                        title: 'Detail Produk',
                        description:
                            "Menampilkan detail produk secara lengkap dengan tombol Booking untuk melakukan pesanan dan tombol Chat untuk menanyakan produk terkait.",
                      ),
                      _buildFeatureItem(
                        context,
                        title: 'Pesanan Produk',
                        description:
                            "Menampilkan item produk yang telah di pesan, dengan informasi Resi, waktu dan tanggal pemesanan, dan status pemesanan. Dapat melakukan konfirmasi dan pembatalan pesanan (tampilan Seller)",
                      ),
                      _buildFeatureItem(
                        context,
                        title: 'Detail Pesanan',
                        description:
                            "Menampilkan detail informasi lengkap terkaitt pemesanan",
                      ),
                      _buildFeatureItem(
                        context,
                        title: 'Favorit Produk (Khusus Tampilan Customer)',
                        description: 'Menyimpan produk favorit pengguna',
                      ),
                      _buildFeatureItem(
                        context,
                        title: 'Edit Profil',
                        description:
                            'Mengubah informasi Profil seperti Nama, No.Telp, dan Lokasi',
                      ),
                      _buildFeatureItem(
                        context,
                        title: 'Tampilan Malam',
                        description:
                            'Tema Aplikasi yang dapat diubah menjadi Tampilan Malam atau Terang',
                      ),
                      _buildFeatureItem(
                        context,
                        title: 'Top Up Saldo (Khusus Tampilan Customer)',
                        description:
                            "Simulasi untuk menambahkan saldo e-wallet buatan 'DompetKu' untuk melakukan pemesanan",
                      ),
                      _buildFeatureItem(
                        context,
                        title: "Saldo 'DompetKu' (Khusus Tampilan Seller)",
                        description:
                            "Simulasi saldo pendapatan Penyedia (Seller) untuk produk yang telah disewakan",
                      ),
                      _buildFeatureItem(
                        context,
                        title:
                            "Buat atau Ganti Pin 'DompetKu' (Khusus Tampilan Customer)",
                        description:
                            "Simulasi membuat atau mengganti PIN untuk e-wallet buatan 'DompetKu'",
                      ),
                      _buildFeatureItem(
                        context,
                        title: 'Mode Admin',
                        description:
                            'Terdapat peran Admin yang memiliki hak akses untuk mengelola semua produk dan pengguna di dalam aplikasi.',
                      ),
                      const Gap(8),
                      Text(
                        'Aplikasi ini dibangun dengan menggunakan beberapa teknologi dan tools sebagai berikut:',
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                      const Gap(8),
                      _buildFeatureItem(
                        context,
                        title: 'Flutter',
                        description:
                            'Framework UI untuk membangun Aplikasi Mobile (Android & IOS), Website, dan Aplikasi Desktop',
                      ),
                      _buildFeatureItem(
                        context,
                        title: 'Dart',
                        description:
                            'Bahasa Pemrograman untuk membangun antarmuka pengguna (UI) untuk Flutter',
                      ),
                      _buildFeatureItem(
                        context,
                        title: 'Node.js',
                        description:
                            'BackEnd untuk melakukan Push Notifikasi dengan FCM (Firebase Cloud Messaging) dan snap Midtrans',
                      ),
                      _buildFeatureItem(
                        context,
                        title: 'Firebase',
                        description: 'Autentikasi, Database, dan FCM',
                      ),
                      _buildFeatureItem(
                        context,
                        title: 'api.kirimin.id',
                        description:
                            'Api Wilayah Indonesia dibuat oleh: Maftuh Ichsan',
                      ),
                      _buildFeatureItem(
                        context,
                        title: 'LocationIQ',
                        description:
                            'Menampilkan Maps dan rekomendasi pencarian lokasi',
                      ),
                      _buildFeatureItem(
                        context,
                        title: 'Railway',
                        description:
                            'Platform yang digunakan untuk deploy BackEnd',
                      ),
                      _buildFeatureItem(
                        context,
                        title: 'Cloudinary',
                        description:
                            'Platform untuk menyimpan foto produk dan foto profil pengguna',
                      ),
                      _buildFeatureItem(
                        context,
                        title: 'Git',
                        description:
                            'Sistem kontrol versi (version control system) untuk melacak perubahan pada kode selama pengembangan',
                      ),
                      _buildFeatureItem(
                        context,
                        title: 'GitHub',
                        description:
                            'Untuk repositori Git, digunakan untuk manajemen dan menyimpan kode',
                      ),
                      const Gap(16),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureItem(
    BuildContext context, {
    required String title,
    required String description,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '•',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          const Gap(8),
          Expanded(
            child: RichText(
              textAlign: TextAlign.justify,
              text: TextSpan(
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  height: 1.5,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
                children: [
                  TextSpan(
                    text: '$title: ',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  TextSpan(
                    text: description,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
