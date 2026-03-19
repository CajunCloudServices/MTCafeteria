part of '../dashboard_support_sections.dart';

const List<String> _localMeals = ['Breakfast', 'Lunch', 'Dinner'];

/// Converts `DateTime.weekday` values into labels used by local deep-clean
/// references.
String weekdayNameLabel(int weekday) {
  switch (weekday) {
    case DateTime.monday:
      return 'Monday';
    case DateTime.tuesday:
      return 'Tuesday';
    case DateTime.wednesday:
      return 'Wednesday';
    case DateTime.thursday:
      return 'Thursday';
    case DateTime.friday:
      return 'Friday';
    case DateTime.saturday:
      return 'Saturday';
    case DateTime.sunday:
      return 'Sunday';
    default:
      return 'Unknown';
  }
}

const List<LocalJobDefinition> dishroomJobs = [
  LocalJobDefinition(
    name: 'Pit Lead',
    setup: [
      LocalChecklistTask(
        id: 'pitlead-setup-1',
        description: 'Set pit station and verify spray tools are ready.',
        requiresCheckoff: true,
      ),
      LocalChecklistTask(
        id: 'pitlead-setup-2',
        description: 'Confirm dish return flow and blue belt are clear.',
        requiresCheckoff: true,
      ),
    ],
    during: [
      LocalChecklistTask(
        id: 'pitlead-during-1',
        description: 'Keep pit flowing and support crew with bottlenecks.',
        requiresCheckoff: false,
      ),
    ],
    cleanup: [
      LocalChecklistTask(
        id: 'pitlead-clean-1',
        description: 'Clean pulper.',
        requiresCheckoff: true,
      ),
      LocalChecklistTask(
        id: 'pitlead-clean-2',
        description: 'Paint station and rinse blue belt in dish return.',
        requiresCheckoff: true,
      ),
      LocalChecklistTask(
        id: 'pitlead-clean-3',
        description: 'Clear pit on low side.',
        requiresCheckoff: true,
      ),
      LocalChecklistTask(
        id: 'pitlead-clean-4',
        description: 'Spray out trap pans and remove food and trash.',
        requiresCheckoff: true,
      ),
      LocalChecklistTask(
        id: 'pitlead-clean-5',
        description: 'Scrub pit walls and island; remove all food.',
        requiresCheckoff: true,
      ),
    ],
  ),
  LocalJobDefinition(
    name: 'Pit Crew',
    setup: [
      LocalChecklistTask(
        id: 'pitcrew-setup-1',
        description: 'Stage spray nozzles and PPE.',
        requiresCheckoff: true,
      ),
    ],
    during: [
      LocalChecklistTask(
        id: 'pitcrew-during-1',
        description:
            'Maintain pit support and clear food buildup continuously.',
        requiresCheckoff: false,
      ),
    ],
    cleanup: [
      LocalChecklistTask(
        id: 'pitcrew-clean-1',
        description: 'Spray carousel trays and remove food.',
        requiresCheckoff: true,
      ),
      LocalChecklistTask(
        id: 'pitcrew-clean-2',
        description: 'Spray lower pit wall.',
        requiresCheckoff: true,
      ),
      LocalChecklistTask(
        id: 'pitcrew-clean-3',
        description: 'Spray out traps (3) and remove all food.',
        requiresCheckoff: true,
      ),
      LocalChecklistTask(
        id: 'pitcrew-clean-4',
        description: 'Vacuum from pit drain.',
        requiresCheckoff: true,
      ),
      LocalChecklistTask(
        id: 'pitcrew-clean-5',
        description: 'Clean floors.',
        requiresCheckoff: true,
      ),
    ],
  ),
  LocalJobDefinition(
    name: 'Cups',
    setup: [
      LocalChecklistTask(
        id: 'cups-setup-1',
        description: 'Prepare cup machine and racks.',
        requiresCheckoff: true,
      ),
    ],
    during: [
      LocalChecklistTask(
        id: 'cups-during-1',
        description: 'Keep cup flow moving and prevent rack backlog.',
        requiresCheckoff: false,
      ),
    ],
    cleanup: [
      LocalChecklistTask(
        id: 'cups-clean-1',
        description: 'Replace cup machine.',
        requiresCheckoff: true,
      ),
      LocalChecklistTask(
        id: 'cups-clean-2',
        description: 'Clean cup machine.',
        requiresCheckoff: true,
      ),
      LocalChecklistTask(
        id: 'cups-clean-3',
        description: 'Put cups away.',
        requiresCheckoff: true,
      ),
    ],
  ),
  LocalJobDefinition(
    name: 'Silverware',
    setup: [
      LocalChecklistTask(
        id: 'silver-setup-1',
        description: 'Set silverware bins and machine area.',
        requiresCheckoff: true,
      ),
    ],
    during: [
      LocalChecklistTask(
        id: 'silver-during-1',
        description: 'Sort silverware continuously and keep counters clear.',
        requiresCheckoff: false,
      ),
    ],
    cleanup: [
      LocalChecklistTask(
        id: 'silver-clean-1',
        description: 'Sort all silverware.',
        requiresCheckoff: true,
      ),
      LocalChecklistTask(
        id: 'silver-clean-2',
        description:
            'Place silverware container and set on counter in Cafe West.',
        requiresCheckoff: true,
      ),
      LocalChecklistTask(
        id: 'silver-clean-3',
        description: 'Clean silverware machine, clean and squeegee counters.',
        requiresCheckoff: true,
      ),
      LocalChecklistTask(
        id: 'silver-clean-4',
        description: 'Clean silverware area.',
        requiresCheckoff: true,
      ),
    ],
  ),
  LocalJobDefinition(
    name: 'Loading',
    setup: [
      LocalChecklistTask(
        id: 'loading-setup-1',
        description: 'Prepare loading area and machine access.',
        requiresCheckoff: true,
      ),
    ],
    during: [
      LocalChecklistTask(
        id: 'loading-during-1',
        description: 'Keep loading flow consistent and feed machines steadily.',
        requiresCheckoff: false,
      ),
    ],
    cleanup: [
      LocalChecklistTask(
        id: 'loading-clean-1',
        description: 'Spray blue belt and counter near loading area.',
        requiresCheckoff: true,
      ),
      LocalChecklistTask(
        id: 'loading-clean-2',
        description: 'Empty each dish machine.',
        requiresCheckoff: true,
      ),
      LocalChecklistTask(
        id: 'loading-clean-3',
        description: 'Clean first 2 sections of dish machine, including parts.',
        requiresCheckoff: true,
      ),
      LocalChecklistTask(
        id: 'loading-clean-4',
        description: 'Clean floors and drains near dish machine.',
        requiresCheckoff: true,
      ),
    ],
  ),
  LocalJobDefinition(
    name: 'Unloading',
    setup: [
      LocalChecklistTask(
        id: 'unload-setup-1',
        description: 'Set unload carts and gloves basket.',
        requiresCheckoff: true,
      ),
    ],
    during: [
      LocalChecklistTask(
        id: 'unload-during-1',
        description: 'Unload continuously and return clean dishes quickly.',
        requiresCheckoff: false,
      ),
    ],
    cleanup: [
      LocalChecklistTask(
        id: 'unload-clean-1',
        description: 'Clean unloading area of machine and remove all food.',
        requiresCheckoff: true,
      ),
      LocalChecklistTask(
        id: 'unload-clean-2',
        description: 'Wash rack cart and refill clean gloves basket.',
        requiresCheckoff: true,
      ),
      LocalChecklistTask(
        id: 'unload-clean-3',
        description: 'Wash dirty unloading gloves.',
        requiresCheckoff: true,
      ),
      LocalChecklistTask(
        id: 'unload-clean-4',
        description: 'Empty recycling.',
        requiresCheckoff: true,
      ),
    ],
  ),
  LocalJobDefinition(
    name: 'Scullery',
    setup: [
      LocalChecklistTask(
        id: 'sc-setup-1',
        description: 'Set scullery and sorting carts.',
        requiresCheckoff: true,
      ),
    ],
    during: [
      LocalChecklistTask(
        id: 'sc-during-1',
        description: 'Keep dish return sorted and clear.',
        requiresCheckoff: false,
      ),
    ],
    cleanup: [
      LocalChecklistTask(
        id: 'sc-clean-1',
        description: 'Put away all dishes and clean all carts.',
        requiresCheckoff: true,
      ),
      LocalChecklistTask(
        id: 'sc-clean-2',
        description: 'Clean sinks and machines.',
        requiresCheckoff: true,
      ),
      LocalChecklistTask(
        id: 'sc-clean-3',
        description: 'Clean wall.',
        requiresCheckoff: true,
      ),
      LocalChecklistTask(
        id: 'sc-clean-4',
        description: 'Take out trash.',
        requiresCheckoff: true,
      ),
    ],
  ),
];

List<LocalChecklistTask> dishroomDeepCleanTasksFor({
  required String meal,
  required int weekday,
}) {
  if (weekday == DateTime.saturday && meal == 'Breakfast') {
    return const [
      LocalChecklistTask(
        id: 'deep-sat-breakfast-1',
        description: 'Scrub blue cup conveyor attachments.',
        requiresCheckoff: true,
      ),
    ];
  }
  if (weekday == DateTime.saturday && meal == 'Lunch') {
    return const [
      LocalChecklistTask(
        id: 'deep-sat-lunch-1',
        description: 'Scrub blue cups.',
        requiresCheckoff: true,
      ),
    ];
  }
  if (weekday == DateTime.saturday && meal == 'Dinner') {
    return const [
      LocalChecklistTask(
        id: 'deep-sat-dinner-1',
        description: 'Wash steel wool dish machine or silverware machine.',
        requiresCheckoff: true,
      ),
    ];
  }
  if (weekday == DateTime.sunday && meal == 'Breakfast') {
    return const [
      LocalChecklistTask(
        id: 'deep-sun-breakfast-1',
        description: 'Clean walls and machines in dishroom.',
        requiresCheckoff: true,
      ),
    ];
  }
  if (weekday == DateTime.sunday && meal == 'Dinner') {
    return const [
      LocalChecklistTask(
        id: 'deep-sun-dinner-1',
        description: 'Clean floors between dishroom machines.',
        requiresCheckoff: true,
      ),
    ];
  }
  if (weekday == DateTime.monday) {
    return const [
      LocalChecklistTask(
        id: 'deep-mon-1',
        description: 'Clean/polish walls in dish return and scullery.',
        requiresCheckoff: true,
      ),
    ];
  }
  if (weekday == DateTime.tuesday) {
    return const [
      LocalChecklistTask(
        id: 'deep-tue-1',
        description: 'Pull out dish machine and clean floor around it.',
        requiresCheckoff: true,
      ),
    ];
  }
  if (weekday == DateTime.wednesday) {
    return const [
      LocalChecklistTask(
        id: 'deep-wed-1',
        description: 'Put cups, pans, and bowls into pan machine at shift end.',
        requiresCheckoff: true,
      ),
    ];
  }
  if (weekday == DateTime.thursday) {
    return const [
      LocalChecklistTask(
        id: 'deep-thu-1',
        description: 'Replace black bins and clean sink/counter area.',
        requiresCheckoff: true,
      ),
    ];
  }
  if (weekday == DateTime.friday) {
    return const [
      LocalChecklistTask(
        id: 'deep-fri-1',
        description: 'Clean wall/restroom and relabel with date.',
        requiresCheckoff: true,
      ),
    ];
  }
  return const [
    LocalChecklistTask(
      id: 'deep-generic-1',
      description: 'Complete todays assigned dishroom deep clean task.',
      requiresCheckoff: true,
    ),
  ];
}

const List<String> supervisorEndShiftCheckoffItems = [
  '1-on-1 for both dishroom and line (if applicable)',
  'Check discipline sheets: signed, filled out, and filed in binder/shelf',
  'Fill out the Service Missionary attendance sheet',
  'Ensure any first-day checklists are completed',
  'Confirm new employee buddy-system checkout is completed',
  'Ensure crate building has been wrapped',
  'Keep supervisor/lead trainer station organized',
  'Add maintenance issues with specific details to shift email',
  'Confirm deep-cleaning assignment has been completed',
  'Ensure all radios are returned and plugged in correctly',
  'Ensure all secondary jobs are done',
  'Assign shift shoutout and add to Google form',
  'Send correctly completed shift email',
];

const List<String> leadTrainerEndShiftCheckoffItems = [
  'Put away 2-minute trainings',
  'Put away allergen signs (including fresh bar for dinner)',
  'Enter all trainings in correct matrix with date, coaching notes, and your name',
  'Add training summary to shift email',
];
