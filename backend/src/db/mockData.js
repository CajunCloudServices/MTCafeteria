const bcrypt = require('bcryptjs');
const { Roles } = require('../config/roles');

const today = new Date().toISOString().slice(0, 10);
const tomorrow = new Date(Date.now() + 24 * 60 * 60 * 1000).toISOString().slice(0, 10);
const longFuture = new Date(Date.now() + 180 * 24 * 60 * 60 * 1000).toISOString().slice(0, 10);

const roles = [
  { id: 1, name: Roles.EMPLOYEE },
  { id: 2, name: Roles.LEAD_TRAINER },
  { id: 3, name: Roles.SUPERVISOR },
  { id: 4, name: Roles.STUDENT_MANAGER },
  { id: 5, name: Roles.DISHROOM_LEAD_TRAINER },
];

const users = [
  { id: 1, email: 'employee@mtc.local', passwordHash: bcrypt.hashSync('password123', 10), roleId: 1, points: 8 },
  { id: 2, email: 'trainer@mtc.local', passwordHash: bcrypt.hashSync('password123', 10), roleId: 2, points: 7 },
  { id: 3, email: 'supervisor@mtc.local', passwordHash: bcrypt.hashSync('password123', 10), roleId: 3, points: 9 },
  { id: 4, email: 'manager@mtc.local', passwordHash: bcrypt.hashSync('password123', 10), roleId: 4, points: 6 },
  { id: 5, email: 'employee2@mtc.local', passwordHash: bcrypt.hashSync('password123', 10), roleId: 1, points: 9 },
  { id: 6, email: 'employee3@mtc.local', passwordHash: bcrypt.hashSync('password123', 10), roleId: 1, points: 5 },
  { id: 7, email: 'employee4@mtc.local', passwordHash: bcrypt.hashSync('password123', 10), roleId: 1, points: 6 },
  { id: 8, email: 'dishtrainer@mtc.local', passwordHash: bcrypt.hashSync('password123', 10), roleId: 5, points: 4 },
];

const announcements = [
  {
    id: 1,
    type: 'Announcement',
    title: 'Table Direction Changes',
    content:
      'Everyone: Management is working on changing table directions to improve customer seating. Please keep the table direction changes in place. - Dusty Lybbert',
    startDate: '2026-04-09',
    endDate: longFuture,
    createdBy: 4,
  },
  {
    id: 2,
    type: 'Reminder',
    title: 'Sack Room Boiled Eggs',
    content:
      'Line: At breakfast in sack room, please put 18 boiled eggs in the warmer next to the oatmeal.',
    startDate: '2026-04-04',
    endDate: longFuture,
    createdBy: 4,
  },
  {
    id: 3,
    type: 'Announcement',
    title: 'Leave Silver Hangers on Stand',
    content:
      'Everyone: We are not recycling the silver metal hangers in the custodial closet. Please leave them on the hanger stand.',
    startDate: '2026-04-04',
    endDate: longFuture,
    createdBy: 4,
  },
  {
    id: 4,
    type: 'Reminder',
    title: 'Keep Fork Containers Stocked',
    content:
      'Line: Even with the lack of metal forks, we need to make sure we are putting 2-3 containers of forks in each of the silverware stands, even if you have to put plastic in.',
    startDate: '2026-04-04',
    endDate: longFuture,
    createdBy: 4,
  },
];

// Keep in sync with backend/sql/seed.sql so mock and postgres return the same
// training titles/content to clients.
const trainings = [
  {
    id: 1,
    title: 'Service Tone',
    content: 'Greet guests and keep communication warm and clear.',
    assignedDate: today,
  },
  {
    id: 2,
    title: 'Safety Refresh',
    content: 'Review food-contact surface sanitation guidelines.',
    assignedDate: tomorrow,
  },
];

const meals = ['Breakfast', 'Lunch', 'Dinner'];

const shifts = meals.map((meal, index) => ({
  id: index + 1,
  shiftType: 'Line Shift',
  mealType: meal,
  name: `${meal} Line Shift`,
}));

const jobDefinitions = [
  {
    name: 'Sack Cashier',
    meals: ['Breakfast', 'Lunch'],
    phases: {
      Setup: {
        Breakfast: [
          'Put out oatmeal',
          'Put out oatmeal cups and lids',
          'Turn on cooler lights',
          'Put out donuts',
          'Put out donut utensils',
          'Unlock door when doors open',
          'Flip sign to "Open"',
          'Set up and sign into register',
        ],
        Lunch: [
          'Put out soups',
          'Ensure sandwiches are available (not displayed)',
          'Put out cookies',
          'Put out chips',
          'Ensure salads are available',
          'Turn on cooler lights',
          'Unlock door when doors open',
          'Flip sign to "Open"',
          'Set up and sign into register',
        ],
      },
      'During Shift': {
        Breakfast: [
          'Ensure missionaries swipe cards',
          'Keep count of missionaries who do not swipe',
          'Ring up senior missionaries',
          'Communicate with sack runner when items run out',
        ],
        Lunch: [
          'Ensure missionaries swipe cards',
          'Keep count of missionaries who do not swipe',
          'Ring up senior missionaries',
          'Communicate with sack runner when items run out',
        ],
      },
      Cleanup: {
        Breakfast: [
          'Flip sign to "Closed"',
          'Lock door',
          'Log out of register',
          'Turn off cooler lights',
          'Restock drinks',
          'Put away donuts',
          'Put away oatmeal',
          'Wipe counters',
          'Vacuum area',
        ],
        Lunch: [
          'Flip sign to "Closed"',
          'Lock door',
          'Log out of register',
          'Turn off cooler lights',
          'Restock drinks',
          'Restock sandwiches',
          'Restock salads',
          'Wipe counters',
          'Vacuum area',
        ],
      },
    },
  },
  {
    name: 'Sack Runner',
    meals: ['Breakfast', 'Lunch'],
    phases: {
      Setup: ['Assist sack cashier with setup tasks'],
      'During Shift': ['Restock items from sack room as needed', 'Coordinate with sack cashier'],
      Cleanup: ['Assist sack cashier with cleanup tasks'],
    },
  },
  {
    name: 'Salads',
    meals: ['Breakfast', 'Lunch'],
    phases: {
      Setup: {
        Breakfast: [
          'Put out fruit and breakfast salad items',
          'Ensure plates are stocked',
        ],
        Lunch: [
          'Put out salad ingredients',
          'Put out tortillas',
          'Set up deli bar',
          'Ensure plates are stocked',
        ],
      },
      'During Shift': {
        Breakfast: [
          'Keep salad bar stocked',
          'Ensure plates remain stocked',
          'Keep oatmeal, grits, or similar items stocked and warm',
        ],
        Lunch: [
          'Keep salad bar stocked',
          'Ensure plates remain stocked',
        ],
      },
      Cleanup: {
        Breakfast: [
          'Surfaces cleaned',
          'Soup area clean',
          'Fridges wiped out',
          'Floor swept in and out of island',
          'Bowls/plates restocked',
          'Fruit shelf restocked',
          'Lettuce wraps/dressings restocked',
          'Trash emptied',
        ],
        Lunch: [
          'Surfaces cleaned',
          'Soup area clean',
          'Fridges wiped out',
          'Floor swept in and out of island',
          'Bowls/plates restocked',
          'Fruit shelf restocked',
          'Lettuce wraps/dressings restocked',
          'Trash emptied',
        ],
      },
    },
  },
  {
    name: 'Server',
    meals: ['Breakfast', 'Lunch', 'Dinner'],
    phases: {
      Setup: [
        'Follow the line map and set up the serving line',
        'Make sure the display plate has been put out',
        'Put 6 plates or 10 bowls out onto the hot pad before the doors open',
      ],
      'During Shift': [
        'Serve the food',
        'Communicate your needs to the runner as they come up',
      ],
      Cleanup: [
        'Clean up the serving line and make sure the heaters and light are turned off',
      ],
    },
  },
  {
    name: 'Volunteer Coordinator',
    meals: ['Breakfast', 'Lunch', 'Dinner'],
    phases: {
      Setup: [
        'Meet the volunteer missionaries when they arrive',
        'Make sure they get aprons, gloves, and hairnets',
        'Explain their assigned work clearly before they start',
        'Coordinate with supervisors and line leads so volunteers are placed where they are needed most',
      ],
      'During Shift': [
        'Check in on volunteers and redirect them if needs change',
        'Switch out the current volunteer group when the next district arrives halfway through the shift',
        'Keep volunteers working in the highest-need areas instead of standing idle',
      ],
      Cleanup: [
        'Direct volunteers to wipe tables, vacuum, and help with dining-room cleanup at the end of the shift',
        'Collect aprons and make sure shared supplies are returned',
      ],
    },
  },
  {
    name: 'Paninis',
    meals: ['Lunch', 'Dinner'],
    phases: {
      Setup: ['Turn on panini machines'],
      'During Shift': [
        'Prepare paninis',
        'Press paninis in machines',
        'Cut paninis',
        'Put paninis out for service',
      ],
      Cleanup: [
        'Panini presses and tools cleaned',
        'Surfaces wiped and floor swept',
        'Heated shelf off and cleaned',
      ],
    },
  },
  {
    name: 'Ice Cream',
    meals: ['Lunch', 'Dinner'],
    phases: {
      Setup: ['Get ice cream', 'Get scoops', 'Get bowls', 'Get water as needed'],
      'During Shift': ['Serve ice cream'],
      Cleanup: [
        'Dirty trays/utensils taken to scullery',
        'Dessert plates restocked',
        'Desserts put away in correct spot',
        'Counters/surfaces cleaned and dried',
        'Floor swept',
        'Cereal bowls restocked',
        'Silverware restocked',
      ],
    },
  },
  {
    name: 'Condiments Prep',
    meals: ['Breakfast', 'Lunch', 'Dinner'],
    phases: {
      Setup: ['Ensure condiment cart is full', 'Assist condiments host with setup'],
      'During Shift': [
        'Keep condiments stocked',
        'Prepare condiments for next meal',
        'If dinner: prepare condiments for breakfast bar next day',
      ],
      Cleanup: [
        'Enough prepped for next meal',
        'Specialty condiments prepped',
        'PB, J, and butter prepped',
        'Prep surfaces cleaned and dried',
        'Toaster station cleaned and restocked',
        'Condiment dispensers clean and full',
        'Pump station swept under',
        'Fruit bar surfaces cleaned and dried',
        'Bowls/plates restocked on fruit bar',
      ],
    },
  },
  {
    name: 'Condiments Host',
    meals: ['Breakfast', 'Lunch', 'Dinner'],
    phases: {
      Setup: [
        'Turn on fruit bar cooler',
        'Put out fruit (4 shotgun pans of fruit, 2 of specialty food)',
        'Put out any special condiments to salad bar',
        'Put up allergen signs',
        'Put utensils in the peanut butter, and butter next to Aloha plate',
        'Make sure the condiment stands are stocked',
        'Put spoons in the fruit',
      ],
      'During Shift': [
        'Ensure everything stays stocked: fruit, condiments, and salad bar condiments',
      ],
      Cleanup: [
        'Wrap and put away the specialty food',
        'Wrap the fruit, leave it in place, and leave the cooler on',
        'Put away the allergen signs',
        'Wipe down the fruit bar',
        'Wipe down all the condiment bars',
        'Wipe down the condiment area of the salad bar',
        'Move salad bar condiments to the student table',
      ],
    },
  },
  {
    name: 'Line Running (Left)',
    meals: ['Breakfast', 'Lunch', 'Dinner'],
    phases: {
      Setup: [
        'Fill wells with water',
        'Turn on heat',
        'Turn on heating elements',
        'Put food out in correct order',
        'Get utensils',
        'Prepare plate stacks',
      ],
      'During Shift': [
        'Keep food stocked',
        'Communicate with chefs as needed',
        'Put plates out 10 at a time',
        'Keep track of plate counts',
      ],
      Cleanup: [
        'Plates/bowls restocked',
        'Heaters off',
        'Surfaces clean and dry',
        'Drain closed and bucket empty',
        'Floors swept (including under station)',
        'Trash emptied',
      ],
    },
  },
  {
    name: 'Line Running (Right)',
    meals: ['Breakfast', 'Lunch', 'Dinner'],
    phases: {
      Setup: [
        'Fill wells with water',
        'Turn on heat',
        'Turn on heating elements',
        'Put food out in correct order',
        'Get utensils',
        'Prepare plate stacks',
      ],
      'During Shift': [
        'Keep food stocked',
        'Communicate with chefs as needed',
        'Put plates out 10 at a time',
        'Keep track of plate counts',
      ],
      Cleanup: [
        'Plates/bowls restocked',
        'Heaters off',
        'Surfaces clean and dry',
        'Drain closed and bucket empty',
        'Floors swept (including under station)',
        'Trash emptied',
      ],
    },
  },
  {
    name: 'Aloha Plate',
    meals: ['Lunch', 'Dinner'],
    phases: {
      Setup: [
        'Fill wells with water',
        'Turn on heat',
        'Turn on heating elements',
        'Put food out in correct order',
        'Get utensils',
        'Prepare plate stacks',
      ],
      'During Shift': [
        'Keep food stocked',
        'Communicate with chefs as needed',
        'Put plates out 10 at a time',
        'Keep track of plate counts',
      ],
      Cleanup: [
        'Plates/bowls restocked',
        'Heaters off',
        'Surfaces clean and dry',
        'Drain closed and bucket empty',
        'Floors swept (including under station)',
        'Trash emptied',
      ],
    },
  },
  {
    name: 'Choices',
    meals: ['Lunch', 'Dinner'],
    phases: {
      Setup: [
        'Fill wells with water',
        'Turn on heat',
        'Turn on heating elements',
        'Put food out in correct order',
        'Get utensils',
        'Prepare plate stacks',
      ],
      'During Shift': [
        'Keep food stocked',
        'Communicate with chefs as needed',
        'Put plates out 10 at a time',
        'Keep track of plate counts',
      ],
      Cleanup: [
        'Plates/bowls restocked',
        'Heaters off',
        'Surfaces clean and dry',
        'Drain closed and bucket empty',
        'Floors swept (including under station)',
        'Trash emptied',
      ],
    },
  },
  {
    name: 'Beverages',
    meals: ['Breakfast', 'Lunch', 'Dinner'],
    phases: {
      Setup: ['Ensure all beverages are stocked', 'Turn on beverage machines'],
      'During Shift': [
        'Restock cups',
        'Check bib room for soda stock',
        'Ensure sodas are stocked',
        'Ensure juices are stocked',
        'Ensure all beverage stations remain stocked',
      ],
      Cleanup: [
        'Milks and juices restocked',
        'Milk/soda/juice machines cleaned',
        'Cups filled',
        'Ice filled',
        'Scissors cleaned',
        'Milk trays cleaned',
        'Coke machine nozzles (dinner)',
        'Blue crates to Empire Crate Building',
        'Empire Crate Building wrapped',
        'Vitamin waters restocked',
        'BIB room checked',
      ],
    },
  },
  {
    name: 'Senior Cash',
    meals: ['Breakfast', 'Lunch', 'Dinner'],
    phases: {
      Setup: ['Sign into register', 'Verify register is ready'],
      'During Shift': ['Ring up senior missionaries'],
      Cleanup: [
        'Napkins and salt/pepper',
        'Sanitizer and paper towels',
        'Lost and found items to front desk',
        'Write next meal menu on door',
        'Refill sanitizer bottles',
        'Sweep tile floor',
      ],
    },
  },
  {
    name: 'Junior Cash',
    meals: ['Breakfast', 'Lunch', 'Dinner'],
    phases: {
      Setup: ['Sign into register'],
      'During Shift': [
        'Ensure missionaries swipe cards',
        'Keep count of missionaries without cards',
      ],
      Cleanup: [
        'Napkins and salt/pepper',
        'Sanitizer and paper towels',
        'Lost and found items to front desk',
        'Write next meal menu on door',
        'Refill sanitizer bottles',
        'Sweep tile floor',
      ],
    },
  },
  {
    name: 'Desserts',
    meals: ['Breakfast', 'Lunch', 'Dinner'],
    phases: {
      Setup: [
        'Put out desserts',
        'Breakfast: donuts',
        'Lunch/Dinner: cookies or assigned desserts',
        'Put out plates',
        'Put out utensils',
      ],
      'During Shift': ['Keep desserts stocked', 'Keep utensils stocked'],
      Cleanup: [
        'Dirty trays/utensils taken to scullery',
        'Dessert plates restocked',
        'Desserts put away in correct spot',
        'Counters/surfaces cleaned and dried',
        'Floor swept',
        'Cereal bowls restocked',
        'Silverware restocked',
      ],
    },
  },
];

const jobs = [];
let jobIdCounter = 1;
for (const shift of shifts) {
  for (const definition of jobDefinitions) {
    if (!definition.meals.includes(shift.mealType)) continue;
    jobs.push({
      id: jobIdCounter,
      shiftId: shift.id,
      name: definition.name,
    });
    jobIdCounter += 1;
  }
}

const tasks = [];
let taskIdCounter = 1;

function addTask(jobId, phase, description, requiresCheckoff = true) {
  tasks.push({
    id: taskIdCounter,
    jobId,
    phase,
    description,
    requiresCheckoff,
  });
  taskIdCounter += 1;
}

for (const job of jobs) {
  const shift = shifts.find((s) => s.id === job.shiftId);
  const definition = jobDefinitions.find((d) => d.name === job.name);
  if (!shift || !definition) continue;

  for (const phase of ['Setup', 'During Shift', 'Cleanup']) {
    const phaseDefinition = definition.phases[phase];
    const phaseTasks = Array.isArray(phaseDefinition)
      ? phaseDefinition
      : (phaseDefinition[shift.mealType] || []);

    for (const taskText of phaseTasks) {
      addTask(job.id, phase, taskText, phase !== 'During Shift');
    }
  }
}

const taskProgress = [
  { userId: 1, taskId: 1, completed: true },
  { userId: 1, taskId: 2, completed: false },
  { userId: 2, taskId: 1, completed: true },
];

const supervisorJobChecks = [
  { mealType: 'Breakfast', jobId: 1, checked: true },
  { mealType: 'Breakfast', jobId: 2, checked: false },
];

const supervisorTaskChecks = [
  { mealType: 'Breakfast', jobId: 1, taskId: 1, checked: true },
  { mealType: 'Breakfast', jobId: 1, taskId: 2, checked: false },
];

const trainerAssignments = [];

const pointAssignments = [
  {
    id: 1,
    assignedToUserId: 1,
    assignedToEmail: 'employee@mtc.local',
    assignedByUserId: 4,
    assignedByEmail: 'manager@mtc.local',
    pointsDelta: 1,
    assignmentDate: today,
    reason: 'Late < 30 minutes',
    assignmentDescription: 'Arrived late to shift check-in without calling ahead.',
    status: 'Pending',
    requiresManagerApproval: false,
    managerApprovedByUserId: 4,
    managerApprovedByEmail: 'manager@mtc.local',
    managerApprovedAt: new Date().toISOString(),
    employeeInitials: null,
    employeeConfirmedAt: null,
    managerNotifiedAt: null,
    createdAt: new Date().toISOString(),
  },
];

const dailyShiftReports = [];

const traineeIds = [1, 5, 6, 7];
for (const meal of meals) {
  const shift = shifts.find((s) => s.mealType === meal);
  if (!shift) continue;

  const mealJobs = jobs.filter((j) => j.shiftId === shift.id);
  for (let i = 0; i < mealJobs.length; i += 1) {
    const traineeUserId = traineeIds[i % traineeIds.length];
    trainerAssignments.push({
      trainerUserId: 2,
      mealType: meal,
      traineeUserId,
      jobName: mealJobs[i].name,
    });
  }
}

module.exports = {
  roles,
  users,
  announcements,
  trainings,
  shifts,
  jobs,
  tasks,
  taskProgress,
  supervisorJobChecks,
  supervisorTaskChecks,
  trainerAssignments,
  pointAssignments,
  dailyShiftReports,
  meals,
};
