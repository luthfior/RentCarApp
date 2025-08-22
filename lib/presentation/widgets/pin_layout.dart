import 'package:flutter/material.dart';
import 'package:rent_car_app/presentation/viewModels/pin_view_model.dart';
import 'package:rent_car_app/presentation/widgets/pin_number_button.dart';

Widget pinLayout(PinViewModel pinVm) {
  return LayoutBuilder(
    builder: (context, constraints) {
      final itemWidth = (constraints.maxWidth - (25 * 2)) / 3;
      return SizedBox(
        width: constraints.maxWidth > 300 ? 300 : constraints.maxWidth,
        child: GridView.count(
          crossAxisCount: 3,
          childAspectRatio: itemWidth / 65,
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
    },
  );
}
