import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:rent_car_app/core/constants/message.dart';
import 'package:rent_car_app/core/utils/number_formatter.dart';
import 'package:rent_car_app/data/services/connectivity_service.dart';
import 'package:rent_car_app/presentation/viewModels/location_view_model.dart';
import 'package:latlong2/latlong.dart';
import 'package:rent_car_app/presentation/widgets/button_primary.dart';
import 'package:rent_car_app/presentation/widgets/custom_header.dart';
import 'package:rent_car_app/presentation/widgets/custom_input.dart';
import 'package:rent_car_app/presentation/widgets/offline_banner.dart';

class LocationPage extends GetView<LocationViewModel> {
  LocationPage({super.key});
  final connectivity = Get.find<ConnectivityService>();
  final GlobalKey _searchFieldKey = GlobalKey();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          SafeArea(
            child: Column(
              children: [
                CustomHeader(title: 'Lokasi'),
                Expanded(
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 20),
                          _buildInputForm(
                            context,
                            controller.streetController,
                            'Masukkan Nama Jalan, No.Rumah/Blok',
                            null,
                            controller.streetFocus,
                            maxLines: null,
                            minLines: 1,
                            customBorderRadius: 20,
                          ),
                          const Gap(16),
                          Obx(() {
                            final fullAddress = controller.getFullAddress();
                            return Material(
                              borderRadius: BorderRadius.circular(20),
                              child: TextField(
                                controller: controller.hierarchyController,
                                readOnly: true,
                                decoration: InputDecoration(
                                  hintText: fullAddress.isEmpty
                                      ? "Pilih Provinsi/Kota/Kecamatan/Kelurahan"
                                      : fullAddress,
                                  hintStyle: GoogleFonts.poppins(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w400,
                                    color: const Color(0xff838384),
                                  ),
                                  border: InputBorder.none,
                                  contentPadding: const EdgeInsets.symmetric(
                                    vertical: 14,
                                    horizontal: 16,
                                  ),
                                ),
                                maxLines: null,
                                minLines: 1,
                                onTap: () {
                                  _showAddressSelector(context);
                                },
                              ),
                            );
                          }),
                          const Gap(16),
                          _buildSearchInput(),
                          const Gap(16),
                          _buildMap(),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Obx(() {
            if (controller.errorMessage.isNotEmpty) {
              return Message.error(controller.errorMessage.value) as Widget;
            }
            if (controller.suggestions.isEmpty) return const SizedBox();
            final box =
                _searchFieldKey.currentContext?.findRenderObject()
                    as RenderBox?;
            final position = box?.localToGlobal(Offset.zero);
            final dy = (position?.dy ?? 0) + (box?.size.height ?? 0);
            return Positioned(
              top: dy,
              left: 24,
              right: 24,
              child: Material(
                elevation: 4,
                borderRadius: BorderRadius.circular(12),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxHeight: 250),
                  child: ListView.builder(
                    padding: EdgeInsets.zero,
                    shrinkWrap: true,
                    itemCount: controller.suggestions.length,
                    itemBuilder: (ctx, i) {
                      final item = controller.suggestions[i];
                      return ListTile(
                        title: Text(item['display_name']),
                        onTap: () {
                          controller.lat.value = double.parse(item['lat']);
                          controller.lon.value = double.parse(item['lon']);
                          controller.locationSearchController.text =
                              item['display_name'];
                          controller.suggestions.clear();
                          controller.mapController.move(
                            LatLng(controller.lat.value, controller.lon.value),
                            15.0,
                          );
                        },
                      );
                    },
                  ),
                ),
              ),
            );
          }),
          const OfflineBanner(),
        ],
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
        color: Colors.transparent,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ButtonPrimary(
              onTap: () async {
                if (connectivity.isOnline.value) {
                  await controller.handleLocation();
                } else {
                  const OfflineBanner();
                  return;
                }
              },
              text: 'Pilih Lokasi',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputForm(
    BuildContext context,
    TextEditingController controller,
    String hintText,
    String? errorText,
    FocusNode focusNode, {
    double? customBorderRadius,
    int? maxLines = 1,
    int? minLines,
    bool isNumeric = false,
    bool isNumberFormatter = false,
    String? isSuffixText,
    String? prefixText,
    IconData? prefixIcon,
    VoidCallback? onTapBox,
    ValueChanged<String>? onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CustomInput(
          hint: hintText,
          isTextCapital: true,
          customHintFontSize: 14,
          customFontSize: 16,
          editingController: controller,
          maxLines: maxLines,
          minLines: minLines,
          customBorderRadius: customBorderRadius,
          keyboardType: isNumeric ? TextInputType.number : TextInputType.text,
          inputFormatters: isNumberFormatter ? [NumberFormatter()] : null,
          suffixText: isSuffixText,
          prefixText: prefixText,
          errorText: errorText,
          focusNode: focusNode,
          onTapBox: onTapBox,
          onChanged: onChanged,
          icon: prefixIcon,
        ),
      ],
    );
  }

  void _showAddressSelector(BuildContext context) {
    controller.selectedProvince.value = null;
    controller.selectedCity.value = null;
    controller.selectedSubDistrict.value = null;
    controller.selectedVillage.value = null;
    Get.bottomSheet(
      PopScope(
        canPop: true,
        onPopInvokedWithResult: (didPop, result) {
          if (!didPop) return;

          if (controller.selectedVillage.value == null) {
            Future.microtask(() {
              controller.selectedProvince.value = null;
              controller.selectedCity.value = null;
              controller.selectedSubDistrict.value = null;
              controller.selectedVillage.value = null;
              controller.selectedProvinceName.value = null;
              controller.selectedCityName.value = null;
              controller.selectedSubDistrictName.value = null;
              controller.selectedVillageName.value = null;
            });
          }
        },
        child: Container(
          height: 300,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Obx(() {
            if (controller.selectedProvince.value == null) {
              return _buildList("Pilih Provinsi", controller.provinces, (item) {
                controller.selectedProvince.value = item;
                controller.selectedProvinceName.value = item['value'];
                controller.loadCities(item['id']);
              });
            } else if (controller.selectedCity.value == null) {
              return _buildList("Pilih Kota/Kabupaten", controller.cities, (
                item,
              ) {
                controller.selectedCity.value = item;
                controller.selectedCityName.value = item['value'];
                controller.loadSubDistricts(item['id']);
              });
            } else if (controller.selectedSubDistrict.value == null) {
              return _buildList("Pilih Kecamatan", controller.subDistricts, (
                item,
              ) {
                controller.selectedSubDistrict.value = item;
                controller.selectedSubDistrictName.value = item['value'];
                controller.loadVillages(item['id']);
              });
            } else {
              return _buildList("Pilih Kelurahan/Desa", controller.villages, (
                item,
              ) {
                controller.selectedVillage.value = item;
                controller.selectedVillageName.value = item['value'];
                controller.hierarchyController.text = controller
                    .getFullAddress();
                Get.back();
              });
            }
          }),
        ),
      ),
    );
  }

  Widget _buildList(
    String title,
    List<Map<String, dynamic>> items,
    Function(Map<String, dynamic>) onTap,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Theme.of(Get.context!).colorScheme.onSurface,
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: items.length,
            itemBuilder: (_, i) {
              final item = items[i];
              return ListTile(
                title: Text(
                  item['value'],
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    color: Theme.of(Get.context!).colorScheme.onSurface,
                  ),
                ),
                onTap: () => onTap(item),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildSearchInput() {
    return Material(
      borderRadius: BorderRadius.circular(20),
      child: TextField(
        key: _searchFieldKey,
        controller: controller.locationSearchController,
        decoration: InputDecoration(
          hintText: "Cari alamat...",
          hintStyle: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.w400,
            color: const Color(0xff838384),
          ),
          prefixIcon: const Icon(Icons.search),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            vertical: 12,
            horizontal: 16,
          ),
        ),
        onChanged: (val) {
          controller.debounceSearch(val, (res) {
            controller.suggestions.assignAll(res);
          });
        },
        maxLines: null,
        minLines: 1,
      ),
    );
  }

  Widget _buildMap() {
    return Obx(() {
      if (controller.errorMessage.isNotEmpty) {
        return Message.error(controller.errorMessage.value) as Widget;
      }
      return SizedBox(
        height: 400,
        child: FlutterMap(
          mapController: controller.mapController,
          options: MapOptions(
            initialCenter: LatLng(controller.lat.value, controller.lon.value),
            initialZoom: 15,
            onTap: (tapPosition, point) async {
              controller.lat.value = point.latitude;
              controller.lon.value = point.longitude;
              controller.tappedPoint = point;
              controller.updateAddressFromLatLng(
                controller.lat.value,
                controller.lon.value,
              );
            },
          ),
          children: [
            TileLayer(
              urlTemplate:
                  "https://tiles.locationiq.com/v2/obk/r/{z}/{x}/{y}.png?key=${controller.apiKey}",
              userAgentPackageName: 'com.example.rent_car_app',
            ),
            MarkerLayer(
              markers: [
                Marker(
                  point: LatLng(controller.lat.value, controller.lon.value),
                  width: 40,
                  height: 40,
                  child: const Icon(
                    Icons.location_pin,
                    color: Colors.red,
                    size: 40,
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    });
  }
}
