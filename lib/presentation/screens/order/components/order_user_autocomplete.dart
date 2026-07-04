import 'package:flutter/material.dart';

import '../../../../core/constants/constants.dart';
import '../../../../domain/entities/user_entity.dart';

class OrderUserAutocomplete extends StatelessWidget {
  final int? selected;
  final List<UserEntity> users;
  final ValueChanged<int?> onChanged;

  const OrderUserAutocomplete({
    super.key,
    required this.selected,
    required this.users,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final selectedUser = users.where((e) => e.id == selected).cast<UserEntity?>().firstOrNull;

    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Autocomplete<UserEntity>(
        displayStringForOption: (c) => c.name ?? '',

        optionsBuilder: (TextEditingValue value) {
          final query = value.text.trim().toLowerCase();

          if (query.isEmpty) {
            return users;
          }

          return users.where((c) {
            final deliveryDatetime = (c.name ?? '').toLowerCase();
            return deliveryDatetime.contains(query);
          });
        },

        onSelected: (UserEntity selection) {
          onChanged(selection.id);
        },

        fieldViewBuilder: (context, textController, focusNode, onFieldSubmitted) {
          // sync selected text khi edit
          if (selectedUser != null && textController.text.isEmpty) {
            textController.text = selectedUser.name ?? '';
          }

          return SizedBox(
            height: 40,
            child: TextFormField(
              controller: textController,
              focusNode: focusNode,
              style: const TextStyle(fontSize: 14),
              decoration: InputDecoration(
                labelText: 'Chọn khách hàng',
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
            ),
          );
        },

        optionsViewBuilder: (context, onSelected, options) {
          return Align(
            alignment: Alignment.topLeft,
            child: Material(
              elevation: 4,
              child: SizedBox(
                height: 220,
                child: ListView.builder(
                  padding: EdgeInsets.zero,
                  itemCount: options.length,
                  itemBuilder: (context, index) {
                    final option = options.elementAt(index);
                    return ListTile(
                      dense: true,
                      minTileHeight: 36,
                      contentPadding: const EdgeInsets.symmetric(horizontal: Constants.listTileFontSize),
                      title: Text(
                        option.name ?? '',
                        style: const TextStyle(fontSize: Constants.listTileFontSize),
                      ),
                      onTap: () => onSelected(option),
                    );
                  },
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
