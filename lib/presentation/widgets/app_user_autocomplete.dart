import 'package:flutter/material.dart';

import '../../core/constants/constants.dart';
import '../../domain/entities/user_entity.dart';

/// Autocomplete field for picking a [UserEntity], with a clear ("x") button
/// that resets both the text and the selection.
class AppUserAutocomplete extends StatelessWidget {
  final int? selected;
  final List<UserEntity> users;
  final ValueChanged<int?> onChanged;
  final VoidCallback onClear;

  const AppUserAutocomplete({
    super.key,
    required this.selected,
    required this.users,
    required this.onChanged,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Autocomplete<UserEntity>(
        displayStringForOption: (u) => u.name ?? '',

        optionsBuilder: (TextEditingValue value) {
          final query = value.text.trim().toLowerCase();

          if (query.isEmpty) return users;

          return users.where(
            (u) => (u.name ?? '').toLowerCase().contains(query),
          );
        },

        onSelected: (UserEntity user) {
          FocusScope.of(context).unfocus();
          onChanged(user.id);
        },

        fieldViewBuilder: (context, textController, focusNode, onFieldSubmitted) {
          final selectedUser = selected == null ? null : users.where((u) => u.id == selected).firstOrNull;

          // Keep re-syncing text with state, overriding stale input.
          if (selectedUser != null && textController.text != selectedUser.name) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              textController.text = selectedUser.name ?? '';
            });
          }

          return SizedBox(
            height: 40,
            child: TextFormField(
              controller: textController,
              focusNode: focusNode,
              style: const TextStyle(fontSize: 14),
              onChanged: (value) {
                if (value.trim().isEmpty) {
                  onClear();
                  onChanged(null);
                }
              },
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
                suffixIcon: (textController.text.isEmpty && selected == null)
                    ? null
                    : IconButton(
                        icon: const Icon(Icons.close, size: 18),
                        onPressed: () {
                          onClear();
                          textController.clear();
                          onChanged(null);
                        },
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
