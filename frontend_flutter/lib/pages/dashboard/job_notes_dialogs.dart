part of '../dashboard_page.dart';

/// Small job-specific notes surfaced from employee and supervisor flows.
const Map<String, List<String>> jobQuickReference = {
  'Sack Runner': [
    'Help keep the sack room fully stocked all shift, including fruit, paper bags, and condiments.',
    'Vacuum the floor and outside rugs, wipe both counters, and help with trash at close if those pieces are not already done.',
    'Check expiration dates on milks, sandwiches, and salads while stocking so expired product does not stay out.',
    'At close, make sure both outside doors are locked, all lights are off, and the wooden door is left open between shifts.',
  ],
  'Line Runner': [
    'Before doors open, follow the line map, make sure the display plate is out, and stage 6 plates or 10 bowls on the hot pad.',
    'Talk to the cooks before service starts and ask exactly when they want low-food callouts.',
    'Get a grease bucket if needed and make sure there is a scullery cart ready.',
    'During service, replace food as it runs out, restock plates, wipe out empty plate carts, and take the scullery cart back when full or when time allows.',
    'Your last priority is helping serve food. Runner duties come first.',
    'After doors close, clean the hot pad and surrounding counter, dry out hot wells, close the drain, dump the water bucket, sweep, empty trash, and restock plates or bowls for the next shift.',
  ],
  'Line Running (Left)': [
    'Before doors open, follow the line map, make sure the display plate is out, and stage 6 plates or 10 bowls on the hot pad.',
    'Talk to the cooks before service starts and ask exactly when they want low-food callouts.',
    'Get a grease bucket if needed and make sure there is a scullery cart ready.',
    'During service, replace food as it runs out, restock plates, wipe out empty plate carts, and take the scullery cart back when full or when time allows.',
    'Your last priority is helping serve food. Runner duties come first.',
    'After doors close, clean the hot pad and surrounding counter, dry out hot wells, close the drain, dump the water bucket, sweep, empty trash, and restock plates or bowls for the next shift.',
  ],
  'Line Running (Right)': [
    'Before doors open, follow the line map, make sure the display plate is out, and stage 6 plates or 10 bowls on the hot pad.',
    'Talk to the cooks before service starts and ask exactly when they want low-food callouts.',
    'Get a grease bucket if needed and make sure there is a scullery cart ready.',
    'During service, replace food as it runs out, restock plates, wipe out empty plate carts, and take the scullery cart back when full or when time allows.',
    'Your last priority is helping serve food. Runner duties come first.',
    'After doors close, clean the hot pad and surrounding counter, dry out hot wells, close the drain, dump the water bucket, sweep, empty trash, and restock plates or bowls for the next shift.',
  ],
  'Server': [
    'Before doors open, follow the line map and set up the serving line.',
    'Make sure the display plate has been put out.',
    'Put 6 plates or 10 bowls out onto the hot pad before the doors open.',
    'During service, serve the food and communicate your needs to the runner as they come up.',
    'After doors close, clean up the serving line and make sure the heaters and light are turned off.',
    'Some shift-specific duties may still come up beyond this core guide.',
  ],
  'Beverages': [],
  'Senior Cash': [],
  'Junior Cash': [],
  'Desserts': [
    'Always use plastic sheet trays instead of metal sheet trays, except brownies can stay on metal sheet trays.',
    'Never serve donuts or muffins during dinner.',
    'Always serve stacked cookies, but never stack donuts.',
    'Always keep the dessert counter clean, stocked, and supplied with the correct serving utensils and silverware.',
    'Do not put donuts, cookies, or Rice Krispy treats in the locker.',
    'Top shelf desserts are jello, pudding, and mousse. Bottom shelf desserts on plastic trays are bars, muffins, pies, and tarts.',
    'Cookies and breads can go either way: use a 1-inch pan on the top shelf or a plastic tray on the bottom shelf.',
    'Cake stays on its cardboard and then goes onto an upside-down plastic sheet tray.',
    'If you are caught up, help serve food and do not forget to restock cereal bowls.',
  ],
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
    'If there is a "use first" sticker on any meat or rice during dinner leftovers, it needs to go to the student table or be tossed rather than stored normally.',
    'For mac salad, toss it if it is past 7 days. For coleslaw, toss it if it is past the date on the label.',
    'Wipe teriyaki sauce bottles before putting them back in Locker 9. If bottles are low, combine them and send the empties to scullery.',
    'All meat leftovers go on the leftover meat only rack in Locker 1.',
    'Rice goes on the leftover rice only rack in Locker 9. If there is too much rice in a 2-inch full pan, split it into 2 cooking tray sheets.',
    'Mac salad and coleslaw stay wrapped and go to Locker 8.',
    'At close, clean and sanitize Aloha prep areas and warmer or cooler doors, sweep warmer or cooler floors, clean the steam kettle used for pork, take out trash, do the daily grill cleaning, replace the scullery cart, and scrub the Aloha Plate floors.',
    'Do not cover leftovers except for mac salad and coleslaw.',
    'On Fridays, deep clean the grill, clean the grill drip pan, line it with new foil, and send cast iron grills through the silverware machine.',
  ],
  'Choices': [
    'Use the posted Choices leftovers sheet for leftover handling.',
    'If Choices and Aloha share cleanup or leftover handling on your shift, follow the posted leftover sheet instead of guessing on storage.',
  ],
  'Sack Cashier': [
    'Breakfast and lunch setup are different. Check the meal-specific steps.',
    'Use the open/close sign and register steps exactly as posted.',
    'Every shift, make sure everything is restocked, including fruit, paper bags, and condiments.',
    'Check expiration dates for milks, sandwiches, and salads.',
    'At close, reset the count ticker to 0, sign out of the register, lock both outside doors, turn off all lights, and leave the wooden door open between shifts.',
  ],
  'Salads': ['Specialty salad bins are stored in locker 8.'],
};

/// Returns job notes for any job name; unknown jobs default to an empty list.
List<String> notesForJob(String jobName) =>
    jobQuickReference[jobName] ?? const [];

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
