import 'dart:async';
import 'dart:developer';
import 'package:cloudinary_public/cloudinary_public.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:rent_car_app/core/constants/message.dart';
import 'package:rent_car_app/data/models/car.dart';
import 'package:rent_car_app/data/sources/seller_source.dart';
import 'package:rent_car_app/data/sources/user_source.dart';
import 'package:rent_car_app/presentation/viewModels/address_view_model.dart';
import 'package:rent_car_app/presentation/viewModels/auth_view_model.dart';
import 'package:rent_car_app/presentation/viewModels/discover_view_model.dart';
import 'package:rent_car_app/presentation/viewModels/seller_view_model.dart';
import 'package:uuid/uuid.dart';

class AddProductViewModel extends GetxController {
  final authVM = Get.find<AuthViewModel>();
  final sellerVM = Get.find<SellerViewModel>();
  final discoverVM = Get.find<DiscoverViewModel>();
  final addressVM = Get.find<AddressViewModel>();
  final sellerSource = SellerSource();

  final RxBool isEditMode = false.obs;
  final Rxn<Car> productToEdit = Rxn<Car>();
  final Rx<String?> imageUrl = Rx<String?>(null);

  final TextEditingController nameController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController priceController = TextEditingController();
  final TextEditingController streetController = TextEditingController();

  final FocusNode nameFocus = FocusNode();
  final FocusNode descriptionFocus = FocusNode();
  final FocusNode priceFocus = FocusNode();
  final FocusNode streetFocus = FocusNode();
  final FocusNode releaseYearFocus = FocusNode();
  final FocusNode categoryFocus = FocusNode();
  final FocusNode transmissionFocus = FocusNode();
  final FocusNode provinceFocus = FocusNode();
  final FocusNode cityFocus = FocusNode();
  final FocusNode districtFocus = FocusNode();
  final FocusNode villageFocus = FocusNode();

  final Rx<String?> nameError = Rx<String?>(null);
  final Rx<String?> descriptionError = Rx<String?>(null);
  final Rx<String?> priceError = Rx<String?>(null);
  final Rx<String?> streetError = Rx<String?>(null);
  final Rx<String?> categoryError = Rx<String?>(null);
  final Rx<String?> transmissionError = Rx<String?>(null);
  final Rx<String?> releaseYearError = Rx<String?>(null);
  final Rx<String?> provinceError = Rx<String?>(null);
  final Rx<String?> cityError = Rx<String?>(null);
  final Rx<String?> districtError = Rx<String?>(null);
  final Rx<String?> villageError = Rx<String?>(null);

  final Rx<String?> selectedCategory = Rx<String?>(null);
  final Rx<String?> selectedTransmission = Rx<String?>(null);
  final Rx<String?> selectedReleaseYear = Rx<String?>(null);
  final Rx<XFile?> pickedImage = Rx<XFile?>(null);

  final List<String> categories = [
    'Electric | Mobil Listrik',
    'Hatchback | Mobil Kota',
    'LCGC | Mobil Hemat',
    'MPV | Mobil Keluarga',
    'Off-road | Mobil Jip',
    'Sedan | Mobil Elegan',
    'Sport Car | Mobil Sport',
    'SUV | Mobil Tangguh & Serbaguna',
  ];
  final List<String> transmissions = ['Automatic', 'CVT', 'Manual'];
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
    _initProductData();
  }

  @override
  void onClose() {
    nameController.dispose();
    descriptionController.dispose();
    priceController.dispose();
    streetController.dispose();
    nameFocus.dispose();
    descriptionFocus.dispose();
    priceFocus.dispose();
    releaseYearFocus.dispose();
    categoryFocus.dispose();
    transmissionFocus.dispose();
    streetFocus.dispose();
    provinceFocus.dispose();
    cityFocus.dispose();
    districtFocus.dispose();
    villageFocus.dispose();
    super.onClose();
  }

  Future<void> _initProductData() async {
    final arguments = Get.arguments;
    if (arguments != null && arguments['isEdit'] == true) {
      isEditMode.value = true;
      final Car car = arguments['car'];
      productToEdit.value = car;

      nameController.text = car.nameProduct;
      descriptionController.text = car.descriptionProduct;
      priceController.text = car.priceProduct.toString();
      streetController.text = car.address!.split(',')[0];

      selectedCategory.value = car.categoryProduct;
      selectedTransmission.value = car.transmissionProduct;
      selectedReleaseYear.value = car.releaseProduct.toString();

      imageUrl.value = car.imageProduct;

      await addressVM.loadProvinces();

      final provinceData = addressVM.provinces.firstWhereOrNull(
        (p) => p['value'] == car.province,
      );
      if (provinceData != null) {
        addressVM.selectedProvince.value = provinceData;
        addressVM.selectedProvinceName.value = provinceData['value'];
        await addressVM.loadCities(provinceData['id']);

        final cityData = addressVM.cities.firstWhereOrNull(
          (c) => c['value'] == car.city,
        );
        if (cityData != null) {
          addressVM.selectedCity.value = cityData;
          addressVM.selectedCityName.value = cityData['value'];
          await addressVM.loadSubDistricts(cityData['id']);

          final districtData = addressVM.subDistricts.firstWhereOrNull(
            (d) => d['value'] == car.district,
          );
          if (districtData != null) {
            addressVM.selectedSubDistrict.value = districtData;
            addressVM.selectedSubDistrictName.value = districtData['value'];
            await addressVM.loadVillages(districtData['id']);

            final villageData = addressVM.villages.firstWhereOrNull(
              (v) => v['value'] == car.village,
            );
            if (villageData != null) {
              addressVM.selectedVillage.value = villageData;
              addressVM.selectedVillageName.value = villageData['value'];
            }
          }
        }
      }
    }
  }

  Future<void> updateExistingProduct({
    required String carId,
    required String nameProduct,
    required String descriptionProduct,
    required String categoryProduct,
    required String transmissionProduct,
    required num priceProduct,
    required num releaseProduct,
    required String imageProduct,
    required String street,
    required String province,
    required String city,
    required String district,
    required String village,
  }) async {
    try {
      final arguments = Get.arguments;
      final Car car = arguments['car'];
      productToEdit.value = car;
      String finalImageUrl = imageProduct;
      if (pickedImage.value != null) {
        final cloudinaryResponse = await sellerSource.cloudinary.uploadFile(
          CloudinaryFile.fromFile(
            pickedImage.value!.path,
            resourceType: CloudinaryResourceType.Image,
          ),
        );
        finalImageUrl = cloudinaryResponse.secureUrl;
      }

      final updatedCar = Car(
        id: carId,
        nameProduct: nameProduct,
        descriptionProduct: descriptionProduct,
        imageProduct: finalImageUrl,
        categoryProduct: categoryProduct,
        transmissionProduct: transmissionProduct,
        priceProduct: priceProduct,
        releaseProduct: releaseProduct,
        ratingProduct: productToEdit.value!.ratingProduct,
        purchasedProduct: productToEdit.value!.purchasedProduct,
        ownerId: authVM.account.value!.uid,
        ownerType: authVM.account.value!.role,
        ownerName: authVM.account.value!.name,
        ownerEmail: authVM.account.value!.email,
        ownerPhotoUrl: authVM.account.value!.photoUrl!,
        address: "$street, $village, $district, $city, $province",
        province: province,
        city: city,
        district: district,
        village: village,
      );

      await sellerSource.updateProduct(updatedCar);
      Message.success('Produk berhasil diperbarui!');
      sellerVM.fetchMyProducts();
      Get.until((route) => route.settings.name == '/discover');
      discoverVM.setFragmentIndex(0);
    } catch (e) {
      log('Gagal memperbarui Produk $e');
      Message.error('Gagal memperbarui Produk. Coba lagi');
    }
  }

  Future<void> createNewProduct({
    required String nameProduct,
    required String descriptionProduct,
    required String categoryProduct,
    required String transmissionProduct,
    required num priceProduct,
    required num releaseProduct,
    required XFile imageFile,
    required String address,
    required String province,
    required String city,
    required String district,
    required String village,
    required String ownerId,
    required String ownerType,
    required String ownerName,
    required String ownerPhotoUrl,
    required num purchasedProduct,
    required num ratingProduct,
  }) async {
    final userAccount = authVM.account.value;
    if (userAccount == null) {
      return;
    }

    try {
      final cloudinaryResponse = await sellerSource.cloudinary.uploadFile(
        CloudinaryFile.fromFile(
          imageFile.path,
          resourceType: CloudinaryResourceType.Image,
        ),
      );
      final imageUrl = cloudinaryResponse.secureUrl;
      final newCar = Car(
        categoryProduct: categoryProduct,
        descriptionProduct: descriptionProduct,
        id: const Uuid().v4(),
        imageProduct: imageUrl,
        nameProduct: nameProduct,
        priceProduct: priceProduct,
        ratingProduct: ratingProduct,
        releaseProduct: releaseProduct,
        purchasedProduct: purchasedProduct,
        transmissionProduct: transmissionProduct,
        ownerId: userAccount.uid,
        ownerType: userAccount.role,
        ownerName: userAccount.name,
        ownerEmail: userAccount.email,
        ownerPhotoUrl: userAccount.photoUrl!,
        address: address,
        province: province,
        city: city,
        district: district,
        village: village,
      );

      await sellerSource.createProduct(
        newCar,
        userAccount.uid,
        userAccount.role,
      );
      Message.success('Produk berhasil ditambahkan!');
      sellerVM.fetchMyProducts();
      Get.until((route) => route.settings.name == '/discover');
      discoverVM.setFragmentIndex(0);
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
      }
    } catch (e) {
      log('Gagal memilih gambar: $e');
    }
  }

  Future<void> handleAddProduct() async {
    nameError.value = null;
    descriptionError.value = null;
    priceError.value = null;
    streetError.value = null;
    categoryError.value = null;
    transmissionError.value = null;
    releaseYearError.value = null;

    bool isValid = true;
    FocusNode? focusToRequest;

    if (nameController.text.isEmpty) {
      nameError.value = 'Nama produk harus diisi.';
      focusToRequest ??= nameFocus;
      isValid = false;
    }
    if (priceController.text.isEmpty) {
      priceError.value = 'Harga produk harus diisi.';
      focusToRequest ??= priceFocus;
      isValid = false;
    }
    if (selectedReleaseYear.value == null) {
      releaseYearError.value = 'Tahun rilis harus dipilih.';
      focusToRequest ??= releaseYearFocus;
      isValid = false;
    }
    if (streetController.text.isEmpty) {
      streetError.value = 'Alamat Jalan harus diisi.';
      focusToRequest ??= streetFocus;
      isValid = false;
    }
    if (descriptionController.text.isEmpty) {
      descriptionError.value = 'Deskripsi produk harus diisi.';
      focusToRequest ??= descriptionFocus;
      isValid = false;
    }
    if (selectedCategory.value == null) {
      categoryError.value = 'Kategori harus dipilih.';
      focusToRequest ??= categoryFocus;
      isValid = false;
    }
    if (selectedTransmission.value == null) {
      transmissionError.value = 'Transmisi harus dipilih.';
      focusToRequest ??= transmissionFocus;
      isValid = false;
    }
    if (pickedImage.value == null) {
      Message.error('Mohon Masukkan Gambar Produk Anda');
      isValid = false;
    }

    if (addressVM.selectedProvinceName.value == null) {
      provinceError.value = 'Alamat Provinsi harus dipilih';
      focusToRequest ??= provinceFocus;
      isValid = false;
    }

    if (addressVM.selectedCityName.value == null) {
      cityError.value = 'Alamat Kota harus dipilih';
      focusToRequest ??= cityFocus;
      isValid = false;
    }

    if (addressVM.selectedSubDistrictName.value == null) {
      districtError.value = 'Alamat Kecamatan harus dipilih';
      focusToRequest ??= districtFocus;
      isValid = false;
    }

    if (addressVM.selectedVillageName.value == null) {
      villageError.value = 'Alamat Kelurahan/Desa harus dipilih';
      focusToRequest ??= villageFocus;
      isValid = false;
    }

    if (!isValid) {
      Message.error('Mohon lengkapi semua field yang kosong.');
      if (focusToRequest != null) {
        focusToRequest.requestFocus();
      }
      return;
    }

    final cleanedPriceText = priceController.text.replaceAll('.', '');
    final parsedPrice = num.tryParse(cleanedPriceText) ?? 0;

    if (isEditMode.value && productToEdit.value != null) {
      updateExistingProduct(
        carId: productToEdit.value!.id,
        nameProduct: nameController.text,
        descriptionProduct: descriptionController.text,
        categoryProduct: selectedCategory.value!,
        transmissionProduct: selectedTransmission.value!,
        priceProduct: parsedPrice,
        releaseProduct: num.tryParse(selectedReleaseYear.value!) ?? 0,
        imageProduct: productToEdit.value!.imageProduct,
        street: streetController.text,
        province: addressVM.selectedProvinceName.value!,
        city: addressVM.selectedCityName.value!,
        district: addressVM.selectedSubDistrictName.value!,
        village: addressVM.selectedVillageName.value!,
      );
    } else {
      createNewProduct(
        nameProduct: nameController.text,
        descriptionProduct: descriptionController.text,
        categoryProduct: selectedCategory.value!,
        transmissionProduct: selectedTransmission.value!,
        priceProduct: parsedPrice,
        releaseProduct: num.tryParse(selectedReleaseYear.value!) ?? 0,
        imageFile: pickedImage.value!,
        purchasedProduct: 0,
        ratingProduct: 5.0,
        address: '${streetController.text}, ${addressVM.getFullAddress()}',
        ownerId: authVM.account.value!.uid,
        ownerType: authVM.account.value!.role,
        ownerName: authVM.account.value!.name,
        ownerPhotoUrl: authVM.account.value!.photoUrl!,
        province: addressVM.selectedProvinceName.value!,
        city: addressVM.selectedCityName.value!,
        district: addressVM.selectedSubDistrictName.value!,
        village: addressVM.selectedVillageName.value!,
      );
    }

    UserSource().updateUserAddress(
      authVM.account.value!.uid,
      authVM.account.value!.role,
      '${streetController.text}, ${addressVM.getFullAddress()}',
    );

    Message.success('Yeay, Produk Berhasil di Upload');
  }
}
