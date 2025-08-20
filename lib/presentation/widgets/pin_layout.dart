import 'package:flutter/material.dart';
import 'package:rent_car_app/presentation/viewModels/pin_view_model.dart';
import 'package:rent_car_app/presentation/widgets/pin_number_button.dart';

Widget pinLayout(PinViewModel pinVm) {
  return SizedBox(
    width: 300,
    child: GridView.count(
      crossAxisCount: 3,
      childAspectRatio: 1.25,
      mainAxisSpacing: 25,
      crossAxisSpacing: 25,
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      children: [
        pinNumberButton(pinVm, 1),
        pinNumberButton(pinVm, 2),
        pinNumberButton(pinVm, 3),
        pinNumberButton(pinVm, 4),
        pinNumberButton(pinVm, 5),
        pinNumberButton(pinVm, 6),
        pinNumberButton(pinVm, 7),
        pinNumberButton(pinVm, 8),
        pinNumberButton(pinVm, 9),
        pinNumberButton(pinVm, null),
        pinNumberButton(pinVm, 0),
        pinNumberButton(pinVm, Icons.backspace),
      ],
    ),
  );
}
