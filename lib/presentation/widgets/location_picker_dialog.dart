// import 'dart:convert';
// import 'dart:developer';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:google_maps_flutter/google_maps_flutter.dart';
// import 'package:http/http.dart' as http;

// class LocationPickerDialog extends StatefulWidget {
//   const LocationPickerDialog({super.key});

//   @override
//   State<LocationPickerDialog> createState() => _LocationPickerDialogState();
// }

// class _LocationPickerDialogState extends State<LocationPickerDialog> {
//   final TextEditingController _searchController = TextEditingController();
//   GoogleMapController? _mapController;

//   final LatLng _initialCameraPositon = const LatLng(-6.200000, 106.816666);
//   LatLng? _selectedLocation;
//   String _addressText = '';
//   List<dynamic> _placePredictions = [];

//   @override
//   void dispose() {
//     _searchController.dispose();
//     _mapController?.dispose();
//     super.dispose();
//   }

//   void _onMapCreated(GoogleMapController controller) {
//     _mapController = controller;
//   }

//   Future<void> _searchPlaces(String input) async {
//     if (input.isEmpty) {
//       setState(() => _placePredictions = []);
//       return;
//     }

//     final url =
//         "https://maps.googleapis.com/maps/api/place/autocomplete/json?input=$input&key=$_apiKey&language=id&components=country:id";

//     final response = await http.get(Uri.parse(url));
//     if (response.statusCode == 200) {
//       final data = json.decode(response.body);
//       setState(() {
//         _placePredictions = data["predictions"];
//       });
//     } else {
//       log("Gagal memanggil API Places: ${response.body}");
//     }
//   }

//   Future<void> _selectPlace(String placeId, String description) async {
//     final url =
//         "https://maps.googleapis.com/maps/api/place/details/json?place_id=$placeId&key=$_apiKey";

//     final response = await http.get(Uri.parse(url));
//     if (response.statusCode == 200) {
//       final data = json.decode(response.body);
//       final location = data["result"]["geometry"]["location"];

//       final lat = location["lat"];
//       final lng = location["lng"];

//       setState(() {
//         _selectedLocation = LatLng(lat, lng);
//         _addressText = description;
//         _searchController.text = description;
//         _placePredictions = [];
//       });

//       _mapController?.animateCamera(CameraUpdate.newLatLng(_selectedLocation!));
//     }
//   }

//   void _onConfirm() {
//     if (_addressText.isNotEmpty) {
//       Get.back(result: _addressText);
//     } else {
//       log("Alamat kosong!");
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Stack(
//         children: [
//           GoogleMap(
//             initialCameraPosition: CameraPosition(
//               target: _initialCameraPositon,
//               zoom: 14,
//             ),
//             markers: _selectedLocation != null
//                 ? {
//                     Marker(
//                       markerId: const MarkerId("selected_location"),
//                       position: _selectedLocation!,
//                     ),
//                   }
//                 : {},
//             onMapCreated: _onMapCreated,
//             onTap: (pos) {
//               setState(() {
//                 _selectedLocation = pos;
//                 _addressText = "${pos.latitude}, ${pos.longitude}";
//               });
//             },
//           ),

//           Positioned(
//             top: 50,
//             left: 16,
//             right: 16,
//             child: Column(
//               children: [
//                 Material(
//                   elevation: 5,
//                   borderRadius: BorderRadius.circular(8),
//                   child: TextField(
//                     controller: _searchController,
//                     decoration: const InputDecoration(
//                       hintText: "Cari alamat...",
//                       prefixIcon: Icon(Icons.search),
//                       border: InputBorder.none,
//                       contentPadding: EdgeInsets.all(12),
//                     ),
//                     onChanged: _searchPlaces,
//                   ),
//                 ),

//                 if (_placePredictions.isNotEmpty)
//                   Container(
//                     margin: const EdgeInsets.only(top: 4),
//                     decoration: BoxDecoration(
//                       color: Colors.white,
//                       borderRadius: BorderRadius.circular(8),
//                       boxShadow: [
//                         BoxShadow(
//                           color: Colors.black26,
//                           blurRadius: 5,
//                           offset: Offset(0, 2),
//                         ),
//                       ],
//                     ),
//                     child: ListView.builder(
//                       shrinkWrap: true,
//                       itemCount: _placePredictions.length,
//                       itemBuilder: (context, index) {
//                         final prediction = _placePredictions[index];
//                         return ListTile(
//                           leading: const Icon(
//                             Icons.location_on,
//                             color: Colors.deepOrange,
//                           ),
//                           title: Text(prediction["description"]),
//                           onTap: () => _selectPlace(
//                             prediction["place_id"],
//                             prediction["description"],
//                           ),
//                         );
//                       },
//                     ),
//                   ),
//               ],
//             ),
//           ),

//           Positioned(
//             bottom: 40,
//             left: 16,
//             right: 16,
//             child: ElevatedButton(
//               onPressed: _onConfirm,
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: Colors.deepOrange,
//                 padding: const EdgeInsets.symmetric(vertical: 16),
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(30),
//                 ),
//               ),
//               child: const Text(
//                 "Konfirmasi Lokasi",
//                 style: TextStyle(color: Colors.white, fontSize: 16),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
