part of '../dashboard_page.dart';

/// Small job-specific notes surfaced from employee and supervisor flows.
const Map<String, List<String>> jobQuickReference = {
  'Sack Runner': [],
  'Line Runner': [],
  'Beverages': [],
  'Senior Cash': [],
  'Junior Cash': [],
  'Desserts': [],
  'Ice Cream': [],
  'Paninis': [],
  'Condiments Prep': [],
  'Condiments Host': [
    'Post allergen signs before service.',
    'Keep fruit, yogurt, and specialty condiments stocked during the shift.',
  ],
  'Aloha Plate': [
    'Macaroni salad uses a green scoop.',
    'Questions: talk to Tosh first.',
    'If Tosh is unavailable, talk to Jamie, Jared, or a full-time manager.',
  ],
  'Choices': [
    'Use the posted Choices leftovers sheet for leftover handling.',
  ],
  'Sack Cashier': [
    'Breakfast and lunch setup are different. Check the meal-specific steps.',
    'Use the open/close sign and register steps exactly as posted.',
  ],
  'Salads': [
    'Specialty salad bins are stored in locker 8.',
  ],
};

/// Returns job notes for any job name; unknown jobs default to an empty list.
List<String> notesForJob(String jobName) => jobQuickReference[jobName] ?? const [];

/// Shared modal used by the job-note buttons throughout the dashboard flows.
void showJobQuickReferenceDialog(
  BuildContext context, {
  required String jobName,
  required List<String> lines,
}) {
  showDialog<void>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text('$jobName Reference'),
      content: SizedBox(
        width: 480,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (lines.isEmpty)
                const Text('No notes yet for this job.')
              else
                for (final line in lines) ...[
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('- '),
                      Expanded(child: Text(line)),
                    ],
                  ),
                  const SizedBox(height: 6),
                ],
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Close'),
        ),
      ],
    ),
  );
}

/// Opens the existing condiments reference flow without forcing users back out
/// to the dashboard-level reference browser.
void showCondimentsRotationDialog(BuildContext context) {
  showDialog<void>(
    context: context,
    builder: (context) => Dialog(
      insetPadding: const EdgeInsets.all(24),
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 720, maxHeight: 560),
        child: const ReferenceSheetsView(
          initialSection: 'Condiments Rotation',
          lockSection: true,
          useOuterCard: false,
        ),
      ),
    ),
  );
}
