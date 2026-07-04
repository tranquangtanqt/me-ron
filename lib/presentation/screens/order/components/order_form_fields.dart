import 'package:flutter/material.dart';

import '../../../../core/themes/app_sizes.dart';
import '../../../widgets/app_text_field.dart';

class OrderPrepaidCheckbox extends StatelessWidget {
  final bool value;
  final ValueChanged<bool> onChanged;

  const OrderPrepaidCheckbox({
    super.key,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme.primary;

    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: CheckboxListTile(
        value: value,
        dense: true,
        contentPadding: const EdgeInsets.only(left: 4),
        controlAffinity: ListTileControlAffinity.leading,

        // 🔵 màu text
        title: Text(
          'Thanh toán',
          style: TextStyle(
            fontSize: 14,
            color: color,
          ),
        ),

        // 🔵 màu checkbox
        activeColor: color, // fallback cho older Flutter
        checkColor: Colors.white,

        // 🔵 Flutter mới (quan trọng)
        fillColor: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.selected)) {
            return color;
          }
          return Colors.transparent;
        }),

        side: BorderSide(
          color: color,
          width: 1.5,
        ),

        onChanged: (v) => onChanged(v ?? false),
      ),
    );
  }
}

class OrderDiscountValueField extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  const OrderDiscountValueField({
    super.key,
    required this.controller,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: AppSizes.padding / 2),
      child: SizedBox(
        height: 40, // 👈 nhỏ lại (40 → 36)
        child: TextField(
          controller: controller,
          onChanged: onChanged,
          keyboardType: TextInputType.number,
          style: const TextStyle(fontSize: 12.5),

          decoration: InputDecoration(
            isDense: true,

            contentPadding: const EdgeInsets.symmetric(
              horizontal: 10,
              vertical: 8,
            ),

            labelText: 'Giảm giá',

            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(6),
            ),

            prefixIcon: const Icon(Icons.discount, size: 16),
            suffixIcon: const Icon(Icons.attach_money, size: 16),
          ),
        ),
      ),
    );
  }
}

class OrderNoteField extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  const OrderNoteField({
    super.key,
    required this.controller,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: AppSizes.padding),
      child: AppTextField(
        controller: controller,
        labelText: 'Ghi chú',
        hintText: 'Nhập ghi chú...',
        maxLines: 2,
        onChanged: onChanged,
      ),
    );
  }
}
