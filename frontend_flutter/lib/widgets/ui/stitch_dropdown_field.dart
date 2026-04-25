import 'package:flutter/material.dart';

import '../../theme/stitch_tokens.dart';

/// Polished Stitch dropdown wrapper around `DropdownButtonFormField<T>`.
///
/// Adds a rounded menu surface, soft card shadow, and a chevron icon — so the
/// popup matches the rest of the Stitch surface system instead of Material's
/// default boxy light-grey menu.
class StitchDropdownField<T> extends StatelessWidget {
  const StitchDropdownField({
    super.key,
    required this.value,
    required this.items,
    required this.onChanged,
    this.label,
    this.isExpanded = true,
    this.width,
  });

  final T? value;
  final List<DropdownMenuItem<T>> items;
  final ValueChanged<T?>? onChanged;
  final String? label;
  final bool isExpanded;
  final double? width;

  @override
  Widget build(BuildContext context) {
    final field = DropdownButtonFormField<T>(
      initialValue: value,
      isExpanded: isExpanded,
      icon: const Icon(
        Icons.keyboard_arrow_down_rounded,
        color: StitchColors.onSurfaceVariant,
      ),
      borderRadius: BorderRadius.circular(StitchRadii.md),
      dropdownColor: StitchColors.surfaceContainerLowest,
      elevation: 6,
      decoration: InputDecoration(
        labelText: label,
      ),
      items: items,
      onChanged: onChanged,
    );
    if (width != null) {
      return SizedBox(width: width, child: field);
    }
    return field;
  }
}
