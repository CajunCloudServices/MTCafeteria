import 'package:flutter/material.dart';

import '../theme/stitch_tokens.dart';
import '../widgets/app_header.dart';
import '../widgets/ui/stitch_buttons.dart';
import '../widgets/ui/stitch_card.dart';
import '../widgets/ui/stitch_dropdown_field.dart';
import '../widgets/ui/stitch_selection_screen.dart';
import '../widgets/ui/stitch_task_widgets.dart';

part 'support/dashboard_support_models.dart';
part 'support/dashboard_support_data.dart';
part 'support/dishroom_worker_section.dart';
part 'support/dishroom_lead_trainer_section.dart';
part 'support/kitchen_jobs_section.dart';
part 'support/night_custodial_section.dart';
part 'support/dashboard_flow_components.dart';

Future<bool> _showSupportShiftFinishPrompt(
  BuildContext context, {
  String title = 'Finished with this shift?',
  String message =
      'Everything is checked off. Are you ready to finish the shift now?',
  String confirmLabel = 'Yes, Finish Shift',
  String cancelLabel = 'Not Yet',
}) async {
  final result = await showDialog<bool>(
    context: context,
    builder: (dialogContext) {
      return AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(cancelLabel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text(confirmLabel),
          ),
        ],
      );
    },
  );
  return result ?? false;
}
