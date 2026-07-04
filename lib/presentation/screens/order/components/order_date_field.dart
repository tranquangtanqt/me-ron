import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/themes/app_sizes.dart';

class OrderDateField extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<DateTime> onChanged;
  final String label;
  final double topPadding;

  const OrderDateField({
    super.key,
    required this.controller,
    required this.onChanged,
    required this.label,
    this.topPadding = AppSizes.padding,
  });

  Future<void> _pickDate(BuildContext context) async {
    DateTime initialDate = DateTime.now();

    if (controller.text.isNotEmpty) {
      try {
        initialDate = DateFormat('dd/MM/yyyy').parse(controller.text);
      } catch (_) {}
    }

    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );

    if (picked != null) {
      final formatted = DateFormat('dd/MM/yyyy').format(picked);

      controller.text = formatted;
      onChanged(picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: EdgeInsets.only(top: topPadding),
      child: SizedBox(
        height: 40,
        child: InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: () => _pickDate(context),
          child: InputDecorator(
            isEmpty: controller.text.isEmpty,
            decoration: InputDecoration(
              labelText: label,
              isDense: true,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 10,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(4),
              ),
              prefixIcon: const Icon(
                Icons.event_available_rounded,
                size: 16,
              ),
              suffixIcon: const Icon(
                Icons.calendar_month_rounded,
                size: 16,
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    controller.text,
                    style: TextStyle(
                      fontSize: 13,
                      color: controller.text.isEmpty ? theme.colorScheme.outline : theme.textTheme.bodyMedium?.color,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
