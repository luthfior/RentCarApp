import 'dart:async';
import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloudinary_public/cloudinary_public.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:rent_car_app/core/constants/message.dart';
import 'package:rent_car_app/data/models/car.dart';
import 'package:rent_car_app/data/services/notification_service.dart';
import 'package:rent_car_app/data/services/push_notification_service.dart';
import 'package:rent_car_app/data/sources/seller_source.dart';
import 'package:rent_car_app/data/sources/user_source.dart';
import 'package:rent_car_app/presentation/viewModels/auth_view_model.dart';
import 'package:rent_car_app/presentation/viewModels/discover_view_model.dart';
import 'package:rent_car_app/presentation/viewModels/seller_view_model.dart';
import 'package:uuid/uuid.dart';

class AddProductViewModel extends GetxController {
  final authVM = Get.find<AuthViewModel>();
  final sellerVM = Get.find<SellerViewModel>();
  final discoverVM = Get.find<DiscoverViewModel>();
  final sellerSource = SellerSource();
  final arguments = Get.arguments;
  final firestore = FirebaseFirestore.instance;

  final RxBool isLoading = false.obs;
  final RxBool isEditMode = false.obs;
  final Rx<Car?> editingCar = Rx<Car?>(null);
  final Rx<String?> imageUrl = Rx<String?>(null);
  Timestamp? createdAt;

  final TextEditingController nameProductController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController priceController = TextEditingController();
  final TextEditingController locationController = TextEditingController();
  final TextEditingController phoneNumberController = TextEditingController();
  final TextEditingController customCategoryController =
      TextEditingController();
  final TextEditingController customBrandController = TextEditingController();

  final FocusNode nameFocus = FocusNode();
  final FocusNode descriptionFocus = FocusNode();
  final FocusNode priceFocus = FocusNode();
  final FocusNode locationFocus = FocusNode();
  final FocusNode releaseYearFocus = FocusNode();
  final FocusNode categoryFocus = FocusNode();
  final FocusNode brandFocus = FocusNode();
  final FocusNode energySourceFocus = FocusNode();
  final FocusNode transmissionFocus = FocusNode();
  final FocusNode provinceFocus = FocusNode();
  final FocusNode cityFocus = FocusNode();
  final FocusNode districtFocus = FocusNode();
  final FocusNode villageFocus = FocusNode();
  final FocusNode phoneNumberFocus = FocusNode();
  final FocusNode customCategoryFocus = FocusNode();
  final FocusNode customBrandFocus = FocusNode();

  final Rx<String?> nameError = Rx<String?>(null);
  final Rx<String?> descriptionError = Rx<String?>(null);
  final Rx<String?> priceError = Rx<String?>(null);
  final Rx<String?> locationError = Rx<String?>(null);
  final Rx<String?> categoryError = Rx<String?>(null);
  final Rx<String?> brandError = Rx<String?>(null);
  final Rx<String?> energySourceError = Rx<String?>(null);
  final Rx<String?> transmissionError = Rx<String?>(null);
  final Rx<String?> releaseYearError = Rx<String?>(null);
  final Rx<String?> phoneNumberError = Rx<String?>(null);
  final Rx<String?> customCategoryError = Rx<String?>(null);
  final Rx<String?> customBrandError = Rx<String?>(null);

  final Rx<String?> selectedBrand = Rx<String?>(null);
  final Rx<String?> selectedEnergySource = Rx<String?>(null);
  final Rx<String?> selectedCategory = Rx<String?>(null);
  final Rx<String?> selectedStreet = Rx<String?>(null);
  final Rx<double?> selectedLatLocation = Rx<double?>(null);
  final Rx<double?> selectedLongLocation = Rx<double?>(null);
  final Rx<String?> selectedProvinceName = Rx<String?>(null);
  final Rx<String?> selectedCityName = Rx<String?>(null);
  final Rx<String?> selectedSubDistrictName = Rx<String?>(null);
  final Rx<String?> selectedVillageName = Rx<String?>(null);
  final Rx<String?> selectedTransmission = Rx<String?>(null);
  final Rx<String?> selectedReleaseYear = Rx<String?>(null);
  final Rx<XFile?> pickedImage = Rx<XFile?>(null);

  final RxList<String> availableBrands = RxList<String>([]);
  final RxList<String> availableEnergySources = RxList<String>([]);
  final RxList<String> availableTransmissions = RxList<String>([]);

  final List<String> newCategories = [
    'Truk',
    'Mobil',
    'Motor',
    'Sepeda',
    'Lainnya',
  ];
  final Map<String, List<String>> brandsData = {
    'Truk': [
      'Mitsubishi Fuso',
      'Hino',
      'Isuzu',
      'UD Trucks',
      'Scania',
      'Volvo',
      'Lainnya',
    ],
    'Mobil': [
      'Toyota',
      'Daihatsu',
      'Honda',
      'Suzuki',
      'Mitsubishi',
      'Nissan',
      'Lainnya',
    ],
    'Motor': ['Honda', 'Yamaha', 'Suzuki', 'Kawasaki', 'Vespa', 'Lainnya'],
    'Sepeda': ['Polygon', 'United', 'Thrill', 'Pacific', 'Element', 'Lainnya'],
  };
  final Map<String, List<String>> energySourcesData = {
    'Truk': ['Diesel', 'Bensin', 'Listrik', 'Hybrid'],
    'Mobil': ['Bensin', 'Diesel', 'Listrik', 'Hybrid'],
    'Motor': ['Bensin', 'Listrik', 'Hybrid'],
    'Sepeda': ['Non-Listrik', 'Listrik'],
  };
  final Map<String, List<String>> transmissionsData = {
    'Truk': ['Manual', 'Automatic'],
    'Mobil': ['Manual', 'Automatic'],
    'Motor': ['Automatic', 'Gigi', 'Kopling'],
    'Sepeda': ['Multi-Speed', 'Single-Speed', 'Automatic'],
  };
  List<String> get releaseYears {
    final int currentYear = DateTime.now().year;
    const int startYear = 1885;
    return List<String>.generate(
      currentYear - startYear + 1,
      (index) => (startYear + index).toString(),
    ).reversed.toList();
  }

  @override
  void onInit() {
    super.onInit();
    if (authVM.account.value != null) {
      final acc = authVM.account.value!;
      if ((acc.phoneNumber ?? '').isEmpty ||
          (acc.street ?? '').isEmpty ||
          (acc.province ?? '').isEmpty ||
          (acc.city ?? '').isEmpty ||
          (acc.district ?? '').isEmpty ||
          (acc.village ?? '').isEmpty ||
          acc.latLocation == null ||
          acc.longLocation == null ||
          acc.latLocation.toString().isEmpty ||
          acc.longLocation.toString().isEmpty) {
        Message.neutral(
          'Data Profil Anda belum lengkap. Silahkan lengkapi terlebih dahulu untuk melanjutkan',
        );
        Get.toNamed('/edit-profile', arguments: {'from': 'add-product'});
      } else {
        locationController.text = acc.fullAddress ?? '';
        phoneNumberController.text = acc.phoneNumber ?? '';
        selectedStreet.value = acc.street ?? '';
        selectedProvinceName.value = acc.province ?? '';
        selectedCityName.value = acc.city ?? '';
        selectedSubDistrictName.value = acc.district ?? '';
        selectedVillageName.value = acc.village ?? '';
        selectedLatLocation.value = acc.latLocation?.toDouble() ?? -6.200000;
        selectedLongLocation.value = acc.longLocation?.toDouble() ?? 106.816666;
      }
    } else {
      return;
    }
    ever(selectedEnergySource, (String? energySource) {
      _updateTransmissionOptions(energySource);
    });
    ever(selectedCategory, _updateDependentFields);
    _initProductData();
  }

  @override
  void onClose() {
    nameProductController.dispose();
    descriptionController.dispose();
    priceController.dispose();
    locationController.dispose();
    nameFocus.dispose();
    descriptionFocus.dispose();
    priceFocus.dispose();
    releaseYearFocus.dispose();
    categoryFocus.dispose();
    transmissionFocus.dispose();
    locationFocus.dispose();
    provinceFocus.dispose();
    cityFocus.dispose();
    districtFocus.dispose();
    villageFocus.dispose();
    phoneNumberController.dispose();
    phoneNumberFocus.dispose();
    nameError.value = null;
    descriptionError.value = null;
    priceError.value = null;
    locationError.value = null;
    categoryError.value = null;
    transmissionError.value = null;
    releaseYearError.value = null;
    phoneNumberError.value = null;
    pickedImage.value = null;
    customBrandController.dispose();
    customBrandFocus.dispose();
    customBrandError.value = null;
    customCategoryController.dispose();
    customCategoryFocus.dispose();
    customCategoryError.value = null;
    super.onClose();
  }

  Future<void> _initProductData() async {
    if (arguments != null && arguments['isEdit'] == true) {
      isEditMode.value = true;
      final Car car = arguments['car'] as Car;
      editingCar.value = car;

      nameProductController.text = car.nameProduct;
      descriptionController.text = car.descriptionProduct;
      priceController.text = car.priceProduct.toString();
      selectedCategory.value = car.categoryProduct;
      selectedReleaseYear.value = car.releaseProduct.toString();
      imageUrl.value = car.imageProduct;
      phoneNumberController.text = car.ownerPhoneNumber;
      locationController.text = car.fullAddress;

      if (newCategories.contains(car.categoryProduct)) {
        selectedCategory.value = car.categoryProduct;
        selectedBrand.value = car.brandProduct;
      } else {
        selectedCategory.value = 'Lainnya';
        customCategoryController.text = car.categoryProduct;
        customBrandController.text = car.brandProduct;
      }

      final brandListForCategory = brandsData[car.categoryProduct];
      if (brandListForCategory != null &&
          brandListForCategory.contains(car.brandProduct)) {
        selectedBrand.value = car.brandProduct;
      } else {
        selectedBrand.value = 'Lainnya';
        customBrandController.text = car.brandProduct;
      }

      selectedEnergySource.value = car.energySourceProduct;
      selectedTransmission.value = car.transmissionProduct;
      createdAt = car.createdAt;
    } else {
      isEditMode.value = false;
      locationController.text = authVM.account.value?.fullAddress ?? '';
    }
  }

  void _updateDependentFields(String? category) {
    selectedBrand.value = null;
    selectedEnergySource.value = null;
    selectedTransmission.value = null;
    customBrandController.clear();

    availableBrands.clear();
    availableEnergySources.clear();
    availableTransmissions.clear();

    if (category == null) return;

    if (brandsData.containsKey(category)) {
      availableBrands.assignAll(brandsData[category]!);
    }
    if (energySourcesData.containsKey(category)) {
      availableEnergySources.assignAll(energySourcesData[category]!);
    }
    if (transmissionsData.containsKey(category)) {
      availableTransmissions.assignAll(transmissionsData[category]!);
    }
  }

  Future<void> updateExistingProduct(Car oldCar) async {
    try {
      final userAccount = authVM.account.value;
      if (userAccount == null) {
        return;
      }

      String finalImageUrl = oldCar.imageProduct;
      if (pickedImage.value != null) {
        try {
          final cloudinaryResponse = await sellerSource.cloudinary.uploadFile(
            CloudinaryFile.fromFile(
              pickedImage.value!.path,
              resourceType: CloudinaryResourceType.Image,
            ),
          );
          finalImageUrl = cloudinaryResponse.secureUrl;
        } catch (e) {
          log("Upload gagal, pakai gambar lama: $e");
          finalImageUrl = oldCar.imageProduct;
        }
      }

      final carToEdit = editingCar.value!;

      final updatedCar = Car(
        categoryProduct: selectedCategory.value == 'Lainnya'
            ? customCategoryController.text
            : selectedCategory.value ?? '',
        descriptionProduct: descriptionController.text,
        id: carToEdit.id,
        imageProduct: finalImageUrl,
        nameProduct: nameProductController.text,
        priceProduct: int.parse(
          priceController.text.replaceAll('.', ''),
        ).round(),
        ratingAverage: carToEdit.ratingAverage,
        reviewCount: carToEdit.reviewCount,
        releaseProduct: int.parse(selectedReleaseYear.value ?? ''),
        purchasedProduct: carToEdit.purchasedProduct,
        brandProduct: (selectedCategory.value == 'Lainnya')
            ? customBrandController.text
            : (selectedBrand.value == 'Lainnya')
            ? customBrandController.text
            : selectedBrand.value ?? '',
        energySourceProduct: selectedEnergySource.value,
        transmissionProduct: selectedTransmission.value,
        ownerId: userAccount.uid,
        ownerType: userAccount.role,
        ownerUsername: userAccount.username,
        ownerStoreName: userAccount.storeName,
        ownerFullName: userAccount.fullName,
        ownerEmail: userAccount.email,
        ownerPhotoUrl: userAccount.photoUrl!,
        ownerPhoneNumber: userAccount.phoneNumber!,
        fullAddress: userAccount.fullAddress!,
        street: userAccount.street!,
        province: userAccount.province!,
        city: userAccount.city!,
        district: userAccount.district!,
        village: userAccount.village!,
        latLocation: userAccount.latLocation!,
        longLocation: userAccount.longLocation!,
        createdAt: createdAt,
        updatedAt: Timestamp.now(),
      );

      await sellerSource.updateProduct(updatedCar);
      sellerVM.fetchMyProducts();
    } catch (e) {
      log('Gagal memperbarui Produk $e');
      Message.error('Gagal memperbarui Produk. Coba lagi');
    }
  }

  Future<void> addNewProduct() async {
    final userAccount = authVM.account.value;
    if (userAccount == null) {
      return;
    }
    final XFile imageFile = pickedImage.value!;
    try {
      final cloudinaryResponse = await sellerSource.cloudinary.uploadFile(
        CloudinaryFile.fromFile(
          imageFile.path,
          resourceType: CloudinaryResourceType.Image,
        ),
      );
      final imageUrl = cloudinaryResponse.secureUrl;
      final newCar = Car(
        categoryProduct: selectedCategory.value == 'Lainnya'
            ? customCategoryController.text
            : selectedCategory.value ?? '',
        descriptionProduct: descriptionController.text,
        id: const Uuid().v4(),
        imageProduct: imageUrl,
        nameProduct: nameProductController.text,
        priceProduct: int.parse(
          priceController.text.replaceAll('.', ''),
        ).round(),
        ratingAverage: 0,
        reviewCount: 0,
        releaseProduct: int.parse(selectedReleaseYear.value ?? ''),
        purchasedProduct: 0,
        brandProduct: (selectedCategory.value == 'Lainnya')
            ? customBrandController.text
            : (selectedBrand.value == 'Lainnya')
            ? customBrandController.text
            : selectedBrand.value ?? '',
        energySourceProduct: selectedEnergySource.value,
        transmissionProduct: selectedTransmission.value,
        ownerId: userAccount.uid,
        ownerType: userAccount.role,
        ownerUsername: userAccount.username,
        ownerStoreName: userAccount.storeName,
        ownerFullName: userAccount.fullName,
        ownerEmail: userAccount.email,
        ownerPhotoUrl: userAccount.photoUrl!,
        ownerPhoneNumber: userAccount.phoneNumber!,
        fullAddress: userAccount.fullAddress!,
        street: userAccount.street!,
        province: userAccount.province!,
        city: userAccount.city!,
        district: userAccount.district!,
        village: userAccount.village!,
        latLocation: userAccount.latLocation!,
        longLocation: userAccount.longLocation!,
        createdAt: Timestamp.now(),
      );

      await sellerSource.createProduct(
        newCar,
        userAccount.uid,
        userAccount.role,
      );
      await sendNotification(newCar);
      sellerVM.fetchMyProducts();
    } catch (e) {
      log('Gagal Menambahkan Produk $e');
      Message.error('Gagal Menambahkan Produk. Coba lagi');
    }
  }

  Future<void> pickImage() async {
    final ImagePicker picker = ImagePicker();
    try {
      final XFile? image = await picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        pickedImage.value = image;
        log('Gambar dipilih: ${image.path}');
      } else {
        Message.neutral('Tidak ada gambar dipilih');
        return;
      }
    } catch (e) {
      log('Gagal memilih gambar: $e');
    }
  }

  bool validateForm() {
    nameError.value = null;
    priceError.value = null;
    releaseYearError.value = null;
    locationError.value = null;
    descriptionError.value = null;
    categoryError.value = null;
    brandError.value = null;
    energySourceError.value = null;
    transmissionError.value = null;
    phoneNumberError.value = null;
    nameError.value = null;
    priceError.value = null;
    releaseYearError.value = null;
    locationError.value = null;
    descriptionError.value = null;
    categoryError.value = null;
    transmissionError.value = null;
    phoneNumberError.value = null;
    customCategoryError.value = null;

    if (nameProductController.text.isEmpty) {
      Message.error('Mohon masukkan nama produk Anda');
      nameError.value = 'Mohon masukkan Nama Produk Anda';
      nameFocus.requestFocus();
      return false;
    }
    if (priceController.text.isEmpty) {
      Message.error('Mohon masukkan harga produk Anda');
      priceError.value = 'Mohon masukkan Harga Produk Anda';
      priceFocus.requestFocus();
      return false;
    }
    final cleanedPriceText = priceController.text.replaceAll('.', '');
    if (int.tryParse(cleanedPriceText) == null) {
      Message.error(
        'Format harga tidak valid. Harap masukkan angka saja.',
        fontSize: 12,
      );
      priceError.value = 'Format Harga Produk tidak valid';
      priceFocus.requestFocus();
      return false;
    }
    if (selectedReleaseYear.value == null) {
      Message.error('Mohon masukkan Tahun Rilis Produk Anda');
      releaseYearError.value = 'Mohon masukkan Tahun Rilis produk Anda';
      releaseYearFocus.requestFocus();
      return false;
    }
    if (selectedCategory.value == null) {
      Message.error('Mohon pilih Kategori Produk Anda');
      categoryError.value = 'Mohon pilih Kategori Produk Anda';
      categoryFocus.requestFocus();
      return false;
    }
    final category = selectedCategory.value!;
    if (category == 'Lainnya') {
      if (customCategoryController.text.isEmpty) {
        Message.error('Mohon masukkan Jenis Kategori Produk');
        customCategoryError.value = 'Mohon masukkan Jenis Kategori Produk Anda';
        customCategoryFocus.requestFocus();
        return false;
      }
    }
    if (category == 'Lainnya') {
      if (customBrandController.text.isEmpty) {
        Message.error('Mohon masukkan Brand Produk Anda');
        customBrandError.value = 'Mohon masukkan Brand Produk Anda';
        customBrandFocus.requestFocus();
        return false;
      }
    } else if (availableBrands.isNotEmpty) {
      if (selectedBrand.value == null) {
        Message.error('Mohon pilih Brand Produk Anda');
        brandError.value = 'Mohon pilih Brand Produk Anda';
        brandFocus.requestFocus();
        return false;
      }
      if (selectedBrand.value == 'Lainnya' &&
          customBrandController.text.isEmpty) {
        Message.error('Mohon masukkan nama Brand Produk');
        customBrandError.value = 'Nama Brand wajib diisi';
        customBrandFocus.requestFocus();
        return false;
      }
    }
    if (availableEnergySources.isNotEmpty &&
        selectedEnergySource.value == null) {
      Message.error('Mohon pilih Sumber Energi Produk Anda');
      energySourceError.value = 'Mohon pilih Sumber Energi Produk Anda';
      energySourceFocus.requestFocus();
      return false;
    }
    if (locationController.text.isEmpty) {
      Message.error('Alamat Toko Anda wajib diisi');
      locationError.value = 'Alamat Toko Anda wajib diisi';
      locationFocus.requestFocus();
      return false;
    }
    if (descriptionController.text.isEmpty) {
      Message.error('Mohon masukkan Deskripsi Produk Anda');
      descriptionError.value = 'Mohon masukkan Deskripsi Produk Anda';
      descriptionFocus.requestFocus();
      return false;
    }
    if (selectedCategory.value == null) {
      Message.error('Mohon pilih Kategori Produk Anda');
      categoryError.value = 'Mohon pilih Kategori Produk Anda';
      categoryFocus.requestFocus();
      return false;
    }
    if (availableTransmissions.isNotEmpty &&
        selectedTransmission.value == null) {
      Message.error('Mohon pilih Transmisi Produk Anda');
      transmissionError.value = 'Mohon pilih Transmisi Produk Anda';
      transmissionFocus.requestFocus();
      return false;
    }
    if (phoneNumberController.text.isEmpty) {
      Message.error('Mohon masukkan No.Telp/WhatsApp Anda');
      phoneNumberError.value = 'Mohon masukkan No.Telp/WhatsApp Anda';
      phoneNumberFocus.requestFocus();
      return false;
    }
    if (!isEditMode.value && pickedImage.value == null) {
      Message.error('Mohon masukkan Gambar Produk Anda');
      return false;
    }
    return true;
  }

  Future<void> handleAddProduct() async {
    if (!validateForm()) return;
    if (isLoading.value) return;

    bool? confirm = await showConfirmationDialog(
      context: Get.context!,
      title: (isEditMode.value && editingCar.value != null)
          ? 'Sunting Produk'
          : 'Tambah Produk',
      content:
          'Apakah Anda yakin ingin ${isEditMode.value && editingCar.value != null ? 'Sunting' : 'Tambah'} produk ini?',
      confirmText:
          'Ya, ${isEditMode.value && editingCar.value != null ? 'Sunting' : 'Tambah'}',
    );
    if (confirm != true) {
      return;
    }

    isLoading.value = true;
    try {
      if (isEditMode.value && editingCar.value != null) {
        await updateExistingProduct(editingCar.value!);
        await UserSource().updateUserAddress(
          authVM.account.value!.uid,
          authVM.account.value!.role,
          locationController.text,
          selectedStreet.value ?? '',
          selectedVillageName.value ?? '',
          selectedSubDistrictName.value ?? '',
          selectedCityName.value ?? '',
          selectedProvinceName.value ?? '',
          selectedLatLocation.value ?? -6.200000,
          selectedLongLocation.value ?? 106.816666,
        );
        await UserSource().updatePhoneNumber(
          authVM.account.value!.uid,
          authVM.account.value!.role,
          phoneNumberController.text,
        );
        await authVM.loadUser();
      } else {
        await addNewProduct();
        await UserSource().updateUserAddress(
          authVM.account.value!.uid,
          authVM.account.value!.role,
          locationController.text,
          selectedStreet.value ?? '',
          selectedVillageName.value ?? '',
          selectedSubDistrictName.value ?? '',
          selectedCityName.value ?? '',
          selectedProvinceName.value ?? '',
          selectedLatLocation.value ?? -6.200000,
          selectedLongLocation.value ?? 106.816666,
        );
        await UserSource().updatePhoneNumber(
          authVM.account.value!.uid,
          authVM.account.value!.role,
          phoneNumberController.text,
        );
        await authVM.loadUser();
      }

      Message.success(
        isEditMode.value
            ? 'Produk berhasil diperbarui!'
            : 'Produk berhasil ditambahkan!',
      );
      if (authVM.account.value!.role == 'admin') {
        Get.until((route) => route.settings.name == '/discover');
        discoverVM.setFragmentIndex(1);
      }
      Get.until((route) => route.settings.name == '/discover');
      discoverVM.setFragmentIndex(0);
    } catch (e) {
      log("error handleAddProduct $e");
      Message.error('Terjadi kesalahan, mohon coba lagi');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> sendNotification(Car car) async {
    final userRole = authVM.account.value?.role ?? '';
    const title = "Produk Baru";
    final body = "Cek Produk Baru dari ${authVM.account.value!.storeName}";
    List<String> targetRoles = [];
    if (userRole == 'admin') {
      targetRoles.add("customer");
    } else {
      targetRoles.addAll(["customer", "admin"]);
    }

    if (targetRoles.isNotEmpty) {
      await PushNotificationService.sendToRoles(
        targetRoles,
        title,
        body,
        data: {'type': 'product', 'referenceId': car.id},
      );
    }

    for (var role in targetRoles) {
      await NotificationService.addNotificationForRole(
        role: role,
        title: title,
        body: body,
        type: "product",
        referenceId: car.id,
      );
    }
  }

  Future<bool> showConfirmationDialog({
    required BuildContext context,
    required String title,
    required String content,
    required String confirmText,
  }) async {
    return await Get.dialog<bool>(
          AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: Text(
              title,
              style: GoogleFonts.poppins(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Theme.of(Get.context!).colorScheme.onSurface,
              ),
            ),
            content: Text(
              content,
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Theme.of(Get.context!).colorScheme.onSurface,
              ),
            ),
            actions: <Widget>[
              TextButton(
                child: Text(
                  'Batal',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(Get.context!).colorScheme.onSurface,
                  ),
                ),
                onPressed: () {
                  Get.back(result: false);
                },
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xffFF5722),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  confirmText,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                onPressed: () {
                  Get.back(result: true);
                },
              ),
            ],
          ),
        ) ??
        false;
  }

  void _updateTransmissionOptions(String? energySource) {
    final category = selectedCategory.value;
    if (category == null) return;

    List<String> originalTransmissions = transmissionsData[category] ?? [];

    if (energySource?.toLowerCase() == 'listrik') {
      selectedTransmission.value = 'Automatic';
      availableTransmissions.assignAll(['Automatic']);
    } else if (category == 'Sepeda' &&
        energySource?.toLowerCase() == 'non-listrik') {
      List<String> filteredTransmissions = List.from(originalTransmissions);
      filteredTransmissions.remove('Automatic');
      availableTransmissions.assignAll(filteredTransmissions);

      if (selectedTransmission.value == 'Automatic') {
        selectedTransmission.value = null;
      }
    } else {
      availableTransmissions.assignAll(originalTransmissions);
    }
  }
}
