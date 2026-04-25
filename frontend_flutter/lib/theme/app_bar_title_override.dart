import 'package:flutter/foundation.dart';

/// Global override for the shared app bar title.
///
/// Selection screens (Select Area, Select Role, Select Meal, Select Station,
/// Select Section, etc.) are rendered deep inside flow widgets but want their
/// title in the top app bar rather than inline. They write to this notifier
/// on mount and clear on unmount; the app bar in `main.dart` listens and
/// swaps its title accordingly.
final ValueNotifier<String?> appBarTitleOverride = ValueNotifier<String?>(null);
