import 'package:flutter/foundation.dart';

@immutable
class TrainingTextSection {
  const TrainingTextSection({required this.heading, required this.bullets});

  final String heading;
  final List<String> bullets;
}

@immutable
class TrainingTextContent {
  const TrainingTextContent({
    required this.title,
    required this.objective,
    required this.sections,
    this.teachingIdea,
    this.generalGuidelines = const <String>[],
    this.sourceImage,
  });

  final String title;
  final String objective;
  final String? teachingIdea;
  final List<String> generalGuidelines;
  final List<TrainingTextSection> sections;
  final String? sourceImage;
}

TrainingTextContent? _manualTrainingOverride({required String? sourceImage}) {
  if (sourceImage == null) return null;
  switch (sourceImage) {
    case 'Shared1.JPG':
      return const TrainingTextContent(
        title: 'General Safety',
        objective:
            'Promote awareness of accidents in the workplace and how to prevent them by following proper safety procedures.',
        teachingIdea:
            'Quiz. Use each subheading as a question. For example: "How does following dress code prevent accidents and/or injury?"',
        sections: [
          TrainingTextSection(
            heading: 'Clothing / Dress Code',
            bullets: [
              'How does following the proper dress code prevent accidents/injury?',
            ],
          ),
          TrainingTextSection(
            heading: 'Burns',
            bullets: [
              'In what ways can you get burned?',
              'What precautions can you take to avoid getting burned?',
            ],
          ),
          TrainingTextSection(
            heading: 'Broken Glass',
            bullets: [
              'What do you do with broken glass?',
              'Where does it go?',
              'What can you do to prevent glass breakage?',
            ],
          ),
          TrainingTextSection(
            heading: 'Wet Floors',
            bullets: [
              'When and where do we use wet floor signs?',
              'How do we clean up spills of any kind?',
              'Make sure everyone understands that spills need to be cleaned up immediately.',
              'Why should we clean up puddles in dishroom/scullery?',
            ],
          ),
          TrainingTextSection(
            heading: 'Locker Doors',
            bullets: [
              'What injuries can occur when locker doors are improperly or hastily opened?',
              'How can you prevent them?',
            ],
          ),
          TrainingTextSection(
            heading: 'Dish Room Safety',
            bullets: [
              'Where do carts go in scullery?',
              'Where do cup racks go in dishroom?',
              'Where are knives cleaned?',
              'How are they cleaned?',
              'What else can you do to promote safety and prevent accidents in dishroom/scullery?',
            ],
          ),
        ],
        sourceImage: 'Shared1.JPG',
      );
    case 'Shared2.JPG':
      return const TrainingTextContent(
        title: 'Medical Emergencies I',
        objective:
            'Make sure workers know how to appropriately respond to a medical emergency at work',
        sections: [
          TrainingTextSection(
            heading: 'General Guidelines',
            bullets: [
              'In case of an emergency, call 911, and then call MTC Security (801-422-9000).',
              'Notify the supervisor as soon as possible.',
              'If a worker is injured in any way, even if it is minor, have the supervisor record it so the MTC can pay for any medical expenses if needed.',
            ],
          ),
          TrainingTextSection(
            heading: 'Bleeding',
            bullets: [
              'Put on disposable gloves before helping someone who is bleeding.',
              'Apply pressure to stop the bleeding.',
              'If it is a minor cut, clean the wound, apply antibiotic, and put on a bandage.',
              'If there is an embedded object, DO NOT PULL IT OUT. Apply pressure with a rolled cloth around it to stop the bleeding.',
              'If there is severe bleeding, call 911.',
              'Wash your hands thoroughly after helping the injured person.',
            ],
          ),
          TrainingTextSection(
            heading: 'Sprain/Fracture',
            bullets: [
              'Keep the body still and stabilize with splint if needed.',
              'If it is a severe fracture, DO NOT MOVE/SET BONES and wait until medical help arrives.',
              'Apply ice packs to prevent swelling.',
            ],
          ),
          TrainingTextSection(
            heading: 'Burns',
            bullets: [
              'First degree (red skin): remove clothing/jewelry from the area, run cool (not cold) water, apply burn gel, and lightly bandage the burn.',
              'Second degree (blisters): same as first degree burn and seek medical attention. Do not break blisters.',
              'Third degree (lack of pain due to nerve damage): call 911 and BYU Security. Safely remove the person from the source of the burn. If it is an electrical burn, make sure power is off before approaching. Check breathing and signs of shock. DO NOT APPLY WATER. Lay the person down, loosely cover the wound with a clean cloth, and raise the burned area.',
            ],
          ),
        ],
        sourceImage: 'Shared2.JPG',
      );
    case 'Shared3.JPG':
      return const TrainingTextContent(
        title: 'Medical Emergencies II',
        objective:
            'Make sure workers know how to appropriately respond to a medical emergency at work',
        sections: [
          TrainingTextSection(
            heading: 'General Guidelines',
            bullets: [
              'In case of an emergency, call 911, and then call MTC Security (801-422-9000).',
              'Notify the supervisor as soon as possible.',
              'If a worker is injured in any way, even if it is minor, have the supervisor record it so the MTC can pay for any medical expenses if needed.',
            ],
          ),
          TrainingTextSection(
            heading: 'Heat Exhaustion',
            bullets: [
              'Heat exhaustion occurs when your body loses too much water or salt, usually from excessive sweating or dehydration.',
              'Symptoms: heavy sweating, faintness, dizziness, fatigue, and weak/rapid pulse.',
              'Move the person to a cool or air-conditioned place, such as one of the offices or in between scullery and the supervisor desk.',
              'Lay the person down and elevate legs and feet slightly.',
              'Have the person sip chilled water or Powerade and remove tight clothing.',
            ],
          ),
          TrainingTextSection(
            heading: 'Shock',
            bullets: [
              'Shock is a sudden drop in blood flow in the body caused by trauma, heatstroke, blood loss, or an allergic reaction.',
              'Symptoms: clammy skin, confusion, dizziness, bluish lips/fingernails, weak rapid pulse, rapid breathing, nausea, or vomiting.',
              'Call emergency services and check breathing/circulation. CPR might be needed.',
              'Lay the person down, keep them still, elevate legs/feet, loosen tight clothing, cover with a blanket or jacket, and do not let them eat or drink.',
            ],
          ),
          TrainingTextSection(
            heading: 'Heart Attack',
            bullets: [
              'A heart attack happens when blood flow to the heart is severely reduced or blocked.',
              'Symptoms: chest pain/pressure/tightness; pain spreading to upper body; nausea/indigestion/abdominal pain; shortness of breath; lightheadedness/dizziness/fainting.',
              'Call emergency services immediately. MTC Security has trained personnel.',
              'Clear the area so responders can promptly apply CPR if needed.',
            ],
          ),
        ],
        sourceImage: 'Shared3.JPG',
      );
    case 'Shared4.JPG':
      return const TrainingTextContent(
        title: 'Medical Emergencies III',
        objective:
            'Make sure workers know how to appropriately respond to a medical emergency at work',
        sections: [
          TrainingTextSection(
            heading: 'General Guidelines',
            bullets: [
              'In case of an emergency, call 911, and then call MTC Security (801-422-9000).',
              'Notify the supervisor as soon as possible.',
              'If a worker is injured in any way, even if it is minor, have the supervisor record it so the MTC can pay for any medical expenses if needed.',
            ],
          ),
          TrainingTextSection(
            heading: 'Stroke',
            bullets: [
              'Stroke is a sudden interruption of blood supply to the brain.',
              'Use the F.A.S.T. test:',
              'Face drooping: ask them to smile. Half of the face may droop.',
              'Arm weakness: ask them to raise both arms. One arm may drop.',
              'Slurred speech: ask them to say a phrase. They may say it incorrectly.',
              'Time to call 911: call with any of the above symptoms, even if they go away.',
              'Time makes the difference between recovery and permanent disability.',
            ],
          ),
          TrainingTextSection(
            heading: 'Seizure',
            bullets: [
              'A seizure is uncontrolled electrical signals between brain cells and can cause abnormal body movements.',
              'Stay calm and help others stay calm.',
              'Gently help the person to the ground if possible, but DO NOT hold them down or stop their movements.',
              'Set the person on their side to help them breathe.',
              'Place a jacket or other padding under the person\'s head.',
              'Clear the area around the person and remove glasses if applicable.',
              'Time the seizure: how long the shaking lasts and how long until they gain consciousness.',
              'Call 911 if the seizure lasts more than 5 minutes or if there are multiple seizures.',
              'Also call 911 if the person is injured or has a health condition like diabetes or heart disease.',
            ],
          ),
        ],
        sourceImage: 'Shared4.JPG',
      );
    case 'Shared5.JPG':
      return const TrainingTextContent(
        title: 'Fire Safety',
        objective:
            'Make sure workers know how to react in case the fire alarm goes off',
        teachingIdea:
            'Know where the 4 different fire response units are (fire extinguishers and stations), show the crew where they are, and ask what to do in a theoretical situation.',
        sections: [
          TrainingTextSection(
            heading: 'If You See a Fire',
            bullets: [
              'You are NOT required to fight fires.',
              'If the fire seems volatile or is bigger than a small trash can, evacuate the building.',
              'USE YOUR BEST JUDGMENT.',
              'Fire pull stations (typical red rectangular fire alarms): engage fire alarm.',
              'Fire suppression stations (circular fire alarms, usually silver): pull if fire is under the hoods and the regular fire suppression system is not working.',
              'This is a very expensive decision. Pull if necessary, but make sure it is an emergency.',
              'If a supervisor or manager is nearby, let them make this decision.',
              'Silver fire extinguisher: use for grease fires.',
              'Red fire extinguisher: use for all other fires.',
            ],
          ),
          TrainingTextSection(
            heading: 'If the Fire Alarm Goes Off',
            bullets: [
              'When you hear the fire alarm, exit through the nearest door.',
              'Exits include scullery, sack room, dining area, and bakery.',
              'Meet near the trees in the northeast parking lot by the buses.',
            ],
          ),
          TrainingTextSection(
            heading: 'Accountability',
            bullets: [
              'DO NOT leave the premises. Supervisors need accountability for everyone.',
              'Wait for supervisor direction before returning inside or going home.',
            ],
          ),
        ],
        sourceImage: 'Shared5.JPG',
      );
    case 'Shared6.JPG':
      return const TrainingTextContent(
        title: 'Chemical Safety',
        objective:
            'Teach workers how to properly handle chemicals and how to react in case of an accident with them',
        teachingIdea:
            'Bring a chemical and the SDS/HAZCOM binder and teach the crew how to find it/read it.',
        sections: [
          TrainingTextSection(
            heading: 'Red Chemicals',
            bullets: [
              'Oasis 146 Multi-Quat Sanitizer: sanitizer, food safe.',
              'Oasis 135 Power Force: floor cleaner, NOT food safe.',
              'Grease Express Fast Foam Degreaser: degreaser, DEFINITELY not food safe',
            ],
          ),
          TrainingTextSection(
            heading: 'General Safety',
            bullets: [
              'Do not mix or ingest chemicals.',
              'Store chemicals away from food. Do not set red buckets on counters or tables.',
              'Always label chemical containers. Do not use any chemical that is not labeled.',
            ],
          ),
          TrainingTextSection(
            heading: 'Exposure Treatment',
            bullets: [
              'Eyes: Rinse for 15-20 minutes with an eye wash bottle. Spray affected eye away from the other eye. Remove contacts if possible. Get medical attention if irritation persists.',
              'Skin contact: Wash thoroughly. For corrosive chemicals (like degreaser), remove contaminated clothing and wash skin for 15 minutes with cool water and mild soap if available. Wash clothes/shoes thoroughly before reuse. Get medical attention immediately.',
              'Ingestion: DO NOT INDUCE VOMITING. Rinse mouth. Get medical attention and call Poison Control.',
            ],
          ),
          TrainingTextSection(
            heading: 'Poison Control',
            bullets: [
              'Inhalation: Move victim to fresh air. Call Poison Control. If symptoms occur, get medical attention immediately.',
              'Poison Control: 1-800-222-1222.',
              'Call 911 immediately if severe symptoms occur.',
              'ALWAYS READ THE LABEL OF THE CHEMICAL YOU INTEND TO USE!',
            ],
          ),
        ],
        sourceImage: 'Shared6.JPG',
      );
    case 'Shared7.JPG':
      return const TrainingTextContent(
        title: 'Proper Lifting',
        objective:
            'Make sure workers know what resources are available to help carry heavy items, and how to lift appropriately.',
        teachingIdea:
            'Use the supervisor or a random worker as a demonstration, and have them show proper back and leg use.',
        sections: [
          TrainingTextSection(
            heading: 'Plan Ahead',
            bullets: [
              'Check the weight before lifting.',
              'Do not lift anything over 20 lbs (banana boxes, large piles of sheet trays, milk bags, etc.). Use a cart.',
              'Do not be embarrassed to use a cart or ask someone for help. We are a team.',
            ],
          ),
          TrainingTextSection(
            heading: 'Posture',
            bullets: [
              'Plant feet shoulder-width apart.',
              'Keep your back straight, look slightly up, and flex abdominal muscles to maintain posture.',
              'Keep the object close to your body.',
              'Lift with your legs.',
              'If you need to pivot, pivot your whole body in unison. Do not twist or arch your back.',
            ],
          ),
        ],
        sourceImage: 'Shared7.JPG',
      );
    case 'Shared8.JPG':
      return const TrainingTextContent(
        title: 'Hand Washing',
        objective:
            'Make sure workers know how to appropriately wash their hands.',
        teachingIdea:
            'Use the supervisor or another crew member for a demonstration.',
        sections: [
          TrainingTextSection(
            heading: 'Why Hand Washing Is Important',
            bullets: [
              'We have a lot of bacteria on our hands, especially from bathrooms and highly touched areas around campus.',
              'Hand washing helps prevent cross-contact between foods.',
              'Hand washing helps keep food safe for customers.',
            ],
          ),
          TrainingTextSection(
            heading: 'When to Wash Your Hands',
            bullets: [
              'At the beginning of the shift',
              'After using the restroom',
              'After taking a break, eating, or getting a drink',
              'Each time you change your gloves',
              'After touching your clothes, face, or hair',
              'When changing tasks',
            ],
          ),
          TrainingTextSection(
            heading: '5 Steps of Handwashing',
            bullets: [
              '1. Get hands wet with warm, running water.',
              '2. Use soap and scrub hands, between fingers, and under fingernails.',
              '3. Scrub for at least 20 seconds.',
              'A simple timing cue is about the length of singing "Happy Birthday."',
              '4. Rinse thoroughly.',
              '5. Use paper towels to dry.',
              'Remember: Do not touch your face with your gloves. If you do, change them.',
            ],
          ),
        ],
        sourceImage: 'Shared8.JPG',
      );
    case 'Shared9.JPG':
      return const TrainingTextContent(
        title: 'Professionalism',
        objective:
            'Ensure crew members understand what professionalism looks and sounds like at MTC Dining.',
        teachingIdea:
            'Have the supervisor conduct the meeting dressed in the wrong uniform, then discuss what should be corrected.',
        sections: [
          TrainingTextSection(
            heading: 'Professionalism Looks Like',
            bullets: [
              'Following BYU dress and grooming standards.',
              'Keeping your uniform neat and clean.',
              'Pulling back long hair.',
              'Not chewing gum while working.',
              'Arriving on time (or calling ahead if you will be late).',
              'Staying on task.',
              'Not using your phone while clocked in.',
              'Not eating served food until after the shift.',
              'Being kind and respectful in all interactions.',
            ],
          ),
          TrainingTextSection(
            heading: 'Professionalism Sounds Like',
            bullets: [
              'Offering your help.',
              'Using respectful language.',
              'Having integrity.',
              'Taking responsibility and being accountable.',
              'Communicating effectively and regularly with leaders and coworkers.',
            ],
          ),
          TrainingTextSection(
            heading: 'Expectations',
            bullets: [
              'Set a good example.',
              'Use common sense.',
              'Follow instructions.',
              'Be quick and efficient.',
              'Ask questions.',
              'Have fun.',
            ],
          ),
          TrainingTextSection(
            heading: 'Respect for Sacred Resources',
            bullets: [
              'Remember that all resources we use here, including paychecks, come from sacred tithing funds paid by faithful members around the world.',
            ],
          ),
        ],
        sourceImage: 'Shared9.JPG',
      );
    case 'Shared10.JPG':
      return const TrainingTextContent(
        title: 'Staying Productive',
        objective:
            'Teach crews to be aware of how productive they are and what they can do when they have a free second.',
        teachingIdea:
            'Lead Trainers: Come with ideas of your own, ask the crew what they do when it is slow, and make the training memorable.',
        sections: [
          TrainingTextSection(
            heading: 'Main Principle',
            bullets: [
              'Always prioritize getting something done before talking.',
              'It is okay to talk while staying busy.',
            ],
          ),
          TrainingTextSection(
            heading: 'Ideas for Staying Productive',
            bullets: [
              'Ask your Supervisor: Your supervisor knows what needs to be done.',
              'See a need and fill it: If you notice a need, take the initiative to fill it.',
              'Organize your area: Make sure to leave your area better than you found it.',
              'Help someone else who you have noticed is behind.',
              'Work on secondaries or cleaning assignments.',
            ],
          ),
          TrainingTextSection(
            heading: 'Time to Get Creative',
            bullets: [
              'Come prepared with a few productivity ideas from your own shift experience.',
              'Ask the crew for their favorite productive tasks when it is slow.',
            ],
          ),
        ],
        sourceImage: 'Shared10.JPG',
      );
    case 'Shared11.JPG':
      return const TrainingTextContent(
        title: 'Scheduling & Attendance',
        objective:
            'Ensure crew members understand scheduling, attendance, and discipline policies. Each team member plays a vital role in serving missionaries.',
        sections: [
          TrainingTextSection(
            heading: 'Accountability Policy',
            bullets: [
              'Show up for your shifts.',
              'If you cannot come to your assigned shift, get a sub.',
              'If you cannot get a sub, contact the scheduling manager and explain the situation.',
              'Texting or calling your supervisor and management helps avoid misunderstandings and a bad attendance record.',
            ],
          ),
          TrainingTextSection(
            heading: 'Discipline',
            bullets: [
              'Discipline points are assigned case by case.',
              '1-2 points for tardiness.',
              '0-2 points for sick days (0 points if you did all you could to get a sub and called in sick).',
              '2 points for an incomplete shift.',
              '4 points for no-shows.',
              'Points are doubled on the weekend.',
            ],
          ),
          TrainingTextSection(
            heading: 'Trades',
            bullets: [
              'You can also get points for forgetting or losing your uniform.',
              'Shifts can be posted to the tradeboard using the "Post My Shifts" option from the "Trades/Available Shifts" tab on the W2W menu.',
              'All trades must be approved by management, except weekend trades when the hiring manager is out of office. If you request a weekend shift, still come in even if approval is pending.',
            ],
          ),
          TrainingTextSection(
            heading: 'Time Off',
            bullets: [
              'Time-off requests must be submitted at least 2 weeks in advance using the "Time Off" tab in W2W.',
              'Time off is granted Monday-Friday. For weekend shifts, you must find a sub.',
            ],
          ),
          TrainingTextSection(
            heading: 'Scheduling',
            bullets: [
              'All MTC Dining employees are required to a weekend rotation, based on staffing levels.',
              'Employees select shifts when hired or near the beginning of each semester.',
              'Direct scheduling questions to the scheduling manager.',
            ],
          ),
        ],
        sourceImage: 'Shared11.JPG',
      );
    case 'Shared12.JPG':
      return const TrainingTextContent(
        title: 'Harassment & Discrimination',
        objective:
            'Inform crews of BYU policies on harassment and non-discrimination. Read these policies aloud and get verbal agreement from your crew to treat each other with respect.',
        sections: [
          TrainingTextSection(
            heading: 'Sexual Harassment Policy',
            bullets: [
              'All forms of sexual harassment, including sexual assault, dating violence, domestic violence, and stalking, are contrary to the teachings of The Church of Jesus Christ of Latter-day Saints and the Church Educational System Honor Code.',
              'Brigham Young University prohibits sexual harassment by its personnel and students in all education programs and activities.',
            ],
          ),
          TrainingTextSection(
            heading: 'Non-Discrimination Policy',
            bullets: [
              'Brigham Young University is committed to providing academic and employment environments that are free from unlawful discrimination. Unlawful discrimination on the basis of race, color, sex, national origin, religion, age, veteran status, genetic information and/or disability will not be tolerated. Harassing behavior based on a protected class that becomes so severe or pervasive that it creates a hostile environment is also unlawful.',
            ],
          ),
          TrainingTextSection(
            heading: 'Consent and Boundaries',
            bullets: [
              'Harassment and discrimination can occur in many forms in a variety of situations.',
              'In order to prevent these issues in the MTC Cafeteria, set clear boundaries with coworkers. Say "No" when you need to. Do not let others cross the line into what makes you uncomfortable, and do not cross boundaries they have set with you.',
              'Always do your part to create a safe, comfortable work environment!',
              'If you notice harassment or discrimination happening around you at work, report it.',
            ],
          ),
          TrainingTextSection(
            heading: 'Report to',
            bullets: [
              'Supervisor, Student Manager, Full-Time Manager',
              'BYU Title IX Office: 1085 WSC, 801-422-8692',
            ],
          ),
        ],
        sourceImage: 'Shared12.JPG',
      );
    case 'Line13.JPG':
      return const TrainingTextContent(
        title: 'Allergens',
        objective:
            'For all employees to understand and implement proper allergen procedures.',
        sections: [
          TrainingTextSection(
            heading: 'Why This Matters',
            bullets: [
              'Some food allergies can be life threatening.',
              'We need to be very cautious in how we handle food so we can keep guests safe.',
            ],
          ),
          TrainingTextSection(
            heading: 'Things to Be Aware Of',
            bullets: [
              'NEVER go into the specialty meals room unless you are a specialty meals worker.',
              'Change gloves and wash hands often when handling potential allergens such as dairy, nuts, and fish.',
              'Avoid cross-contamination. An example of cross-contamination could be using the same scoop for different foods.',
              'Treat all guests with respect and be attentive to their needs.',
              'Ask your supervisor if you have questions.',
            ],
          ),
          TrainingTextSection(
            heading: 'Allergen Sign Locations',
            bullets: [
              'Condiments: Found in the box under the fruit bar.',
              'Desserts: Found in the box by the dessert station.',
              'Breakfast bar: Found in the box on the island.',
              'Ice Cream: Found in the box on the island.',
              'Salad Bar allergen signs: Found in the box on the island.',
            ],
          ),
          TrainingTextSection(
            heading: 'Warning Signs',
            bullets: [
              'Use the red-triangle warning signs for foods that contain nuts.',
              'These signs have a black exclamation point and can be found by the blue box near the dessert station.',
              'Put warning signs out as needed.',
            ],
          ),
          TrainingTextSection(
            heading: 'End of Shift',
            bullets: [
              'Always put all signs away at the end of the shift unless you know the next shift still needs them.',
            ],
          ),
        ],
        sourceImage: 'Line13.JPG',
      );
    case 'Line14.JPG':
      return const TrainingTextContent(
        title: 'General Organization',
        objective: 'Create a clean, organized environment.',
        teachingIdea:
            'We have many moving pieces in the cafeteria. Each person should do their part so we can work effectively.',
        sections: [
          TrainingTextSection(
            heading: 'Core Practices',
            bullets: [
              'Clean your area often (wipe stations with sanitizer, return dishes, and leave your area better than you found it).',
              'If there is an empty cart, take it to scullery.',
              'Take empty keepers where they belong right away.',
              'CSC keepers go by the cage; MTC keepers go between scullery and the ice machines.',
              'Move empty carts to scullery.',
              'Break down boxes before putting them in trash carts.',
              'Do not leave empty crates, boxes, or other items lying around.',
              'Consolidate and organize lockers when possible (ask the supervisor).',
              'If you do not know where something goes, ask. Do not leave it in an open random spot.',
              'Ask your crew: what else can we do to stay organized?',
            ],
          ),
        ],
        sourceImage: 'Line14.JPG',
      );
    case 'Line15.JPG':
      return const TrainingTextContent(
        title: 'Putting Away Dishes',
        objective:
            'Maintain an organized cafeteria by learning to properly put away dishes.',
        teachingIdea:
            'Bring a cart of dishes from scullery and put them away together.',
        sections: [
          TrainingTextSection(
            heading: 'Essential Information',
            bullets: [
              'If you are not sure where an item goes, ask a cook or experienced worker.',
              'Show common look-alikes: holey vs solid pans, 2-inch vs 4-inch pans, CSC vs MTC containers.',
              'Keep like items together and separate unlike items.',
              'Always use a clean blue cart to transport clean dishes.',
              'Use metal carts for dirty dishes.',
              'In scullery, sort items well on carts to reduce mix-ups while putting dishes away.',
              'Store plastic dessert trays separately from metal sheet trays.',
            ],
          ),
          TrainingTextSection(
            heading: 'Field Trip',
            bullets: [
              'Take your crew to each stop and show them where the different items go:',
              '1. Bakery / Cage',
              '2. Shelves on Main Dish back wall',
              '3. Main Dish Area, hanging items',
              '4. Salad Prep/Shelves by Dish Room',
              '5. Island',
              '6. Scullery / West Loading Dock',
            ],
          ),
          TrainingTextSection(
            heading: 'Remember',
            bullets: [
              'Putting dishes and items in the correct place makes a notable difference in cafeteria flow.',
              'Everything is easier to locate when items are returned correctly.',
            ],
          ),
        ],
        sourceImage: 'Line15.JPG',
      );
    case 'Line16.JPG':
      return const TrainingTextContent(
        title: 'Tips and Tricks',
        objective:
            'To inform your crew of some tips and tricks that they might be missing out on that could potentially make their life easier.',
        teachingIdea:
            'The ideas are suggestions. You can use them, but come prepared with tips and tricks you have discovered to share with the crew.',
        sections: [
          TrainingTextSection(
            heading: 'Examples of "Tips and Tricks"',
            bullets: [
              'Beverages: At dinner, get a scullery cart and take everything that needs to be cleaned at the same time.',
              'Thoroughness: If you do your job thoroughly, you do not have to do it again.',
              'Scullery: Go around the cafeteria and gather dishes before you run out so that you are always busy.',
            ],
          ),
          TrainingTextSection(
            heading: 'Time to Get Creative',
            bullets: [
              'Lead Trainers: Get as creative as you would like.',
              'You could always come up with ideas to share and do just that.',
              'You could ask the crew if they have any "Tips and Tricks".',
              'You could even play charades to see if they can guess the tip you are trying to teach.',
            ],
          ),
        ],
        sourceImage: 'Line16.JPG',
      );
    case 'Line17.JPG':
      return const TrainingTextContent(
        title: 'Locker 10 Etiquette',
        objective:
            'Ensure Lockers 10 and 13 stay clean and organized. Take the crew to Locker 10 and show them.',
        sections: [
          TrainingTextSection(
            heading: 'Milk',
            bullets: [
              'Pull milk in the correct order.',
              'Keep milks on a cart while prepping so the floor stays clear.',
              'Follow the posted shelf sequence in Locker 10 when rotating milk.',
            ],
          ),
          TrainingTextSection(
            heading: 'Desserts',
            bullets: [
              'Consolidate dessert keepers after every shift so Locker 10 does not get overcrowded.',
              'Finish each stack before starting the next stack.',
              'NEVER put donuts or cookies into the lockers.',
            ],
          ),
          TrainingTextSection(
            heading: 'Placement Rules',
            bullets: [
              'Put items only where they belong.',
              'If you are not sure where something goes, ask your supervisor.',
              'Do not put keepers in front of Locker 11.',
              'Do not put keepers or carts in salad bar or deli bar spots. If a spot is empty, keep it empty.',
              'Go to Locker 10 to review expected placement with your crew.',
            ],
          ),
        ],
        sourceImage: 'Line17.JPG',
      );
    case 'Line18.JPG':
      return const TrainingTextContent(
        title: 'Throwing Food Away',
        objective: 'Ensure employees know when and what foods to throw away.',
        sections: [
          TrainingTextSection(
            heading: 'Disposal Timing',
            bullets: [
              'Donuts (glazed and cake): toss after lunch on day of delivery.',
              'Exception: Saturday cake donuts may be held for Sunday breakfast, then tossed.',
              'Bagels and muffins: toss after breakfast on day of delivery.',
              'Exception: Saturday bagels and muffins may be held for Sunday breakfast, then tossed.',
              'Cookies: toss after dinner, 3 days after delivery.',
              'Paninis and sandwiches (unwrapped): toss after dinner on day of delivery.',
              'Paninis and sandwiches (wrapped): toss after labeled best-by date.',
              'Pre-made salads: toss after labeled best-by date.',
              'Bottled milk: toss after dinner, 5 days after best-by date.',
              'Desserts: toss after dinner, 3 days after delivery. Inspect daily and consult manager if needed.',
              'Whole fruit: check daily; toss if bad and consult manager if unsure.',
              'Cut fruit: toss 7 days after date. Inspect daily and toss sooner if quality is bad.',
            ],
          ),
          TrainingTextSection(
            heading: 'Lead Trainer Idea',
            bullets: [
              'Have someone name disposal windows for each item as a quick check.',
            ],
          ),
        ],
        sourceImage: 'Line18.JPG',
      );
    case 'Line19.JPG':
      return const TrainingTextContent(
        title: 'Runner',
        objective: 'To ensure that the runner is doing their job properly.',
        teachingIdea:
            'Time to get creative. A short quiz works great, but any memorable approach is fine.',
        sections: [
          TrainingTextSection(
            heading: 'Core Reminders',
            bullets: [
              'ALWAYS communicate with cooks at the beginning of the shift and ask when they want to be informed of items running low.',
              'When the dirty dish cart is almost full, take it to scullery. Also, take the dirty dishes off the cart and put them on the metal shelf in scullery so that there is a cart that can be used whenever somebody needs it.',
              'ALWAYS ask the cooks when they would like to be informed about running low on food (for example, when there are 2 pans of potatoes left).',
              'ALWAYS have a red bucket with sanitizer in your area so you can wipe out empty bowl and plate carts. When done wiping empty carts, take them back to dishroom.',
              'ALWAYS remember to grab a grease bucket at the beginning of a shift and dump it at the end (if you are serving an item with a lot of excess grease).',
              'ALWAYS prioritize your runner duties over helping the server.',
            ],
          ),
        ],
        sourceImage: 'Line19.JPG',
      );
    case 'Line20.JPG':
      return const TrainingTextContent(
        title: 'Bathrooms',
        objective:
            'Communicate how different line shifts maintain the bathrooms.',
        teachingIdea:
            'Time to get creative. A quiz would probably suit this training best, but any memorable method works.',
        sections: [
          TrainingTextSection(
            heading: 'Breakfast/Lunch Responsibilities',
            bullets: [
              'Check each bathroom for cleanliness.',
              'Sweep if necessary.',
              'Restock toilet paper and paper towels as needed.',
              'Empty trashes if needed.',
              'Tidy up uniforms and remove junk.',
            ],
          ),
          TrainingTextSection(
            heading: 'Dinner Responsibilities',
            bullets: [
              'Use line training sheet and thoroughly clean both bathrooms.',
              'Commonly missed: hand sanitizer in both bathrooms.',
              'Commonly missed: feminine product trashes in all women\'s stalls.',
              'Refill soap dispensers.',
              'Keep 3 rolls of toilet paper in each stall.',
              'Restock paper towels.',
              'Restock toilet seat covers (extras in basement).',
              'Polish metal stalls with stainless steel polish.',
            ],
          ),
        ],
        sourceImage: 'Line20.JPG',
      );
    case 'Line21.JPG':
      return const TrainingTextContent(
        title: 'Vacuuming',
        objective:
            'For your crew to know how to properly use and maintain the vacuums.',
        teachingIdea:
            'Time to get creative. Bring out a vacuum and demonstrate if possible.',
        sections: [
          TrainingTextSection(
            heading: 'Do Not Vacuum',
            bullets: [
              'Napkins.',
              'Large chunks of food.',
              'Utensils.',
              'Pens and pencils.',
            ],
          ),
          TrainingTextSection(
            heading: 'Do Not',
            bullets: [
              'Remove the metal prongs at the bottom of vacuums.',
              'Rest vacuums on the battery.',
            ],
          ),
          TrainingTextSection(
            heading: 'Always',
            bullets: [
              'Plug in batteries after each use.',
              'Hang vacuums neatly in the vacuum closet.',
              'Replace the filter bag whenever it is full (check after each use so it does not get missed).',
              'Report issues to your supervisor.',
              'Keep the vacuum closet organized.',
            ],
          ),
        ],
        sourceImage: 'Line21.JPG',
      );
    case 'Line22.JPG':
      return const TrainingTextContent(
        title: 'Custodial Closet Secondary Jobs',
        objective:
            'For your crew to know how to properly do the custodial secondary jobs.',
        teachingIdea:
            'Time to get creative. Teach this in a memorable way and do not just recite it.',
        sections: [
          TrainingTextSection(
            heading: 'Rag Buckets',
            bullets: [
              'Take the bucket of dirty rags from Cafe West, the island, and the salads area and bring back clean ones.',
            ],
          ),
          TrainingTextSection(
            heading: 'Metal Hangers',
            bullets: [
              'Empty metal hangers from white MTC shirts should be moved to the metal hanger stand (next to the dirty clothes bin).',
              'If the stand gets full, dump it into recycling behind scullery.',
            ],
          ),
          TrainingTextSection(
            heading: 'Laundry',
            bullets: [
              'Any laundry left in the washing machine from the previous shift should be taken out and hung on clothes lines.',
              'Any dry clothes on clothes lines should be put away.',
              'Dirty bathroom towels, dry mops, and dishroom/cutting gloves should be started as a load (these can also go in the end-of-shift load with table-wiping towels).',
            ],
          ),
          TrainingTextSection(
            heading: 'Clean Uniform Pieces',
            bullets: [
              'Take clean uniform pieces in custodial closet to the basement and put them away in their proper place in an organized manner.',
            ],
          ),
        ],
        sourceImage: 'Line22.JPG',
      );
    case 'Line23.JPG':
      return const TrainingTextContent(
        title: 'Cashier Reminders',
        objective:
            'To remind your crew of small cashier details that are often forgotten.',
        teachingIdea:
            'Time to get creative. This training works well as a quiz, but any memorable format is good.',
        sections: [
          TrainingTextSection(
            heading: 'Main Cashier',
            bullets: [
              'P-day Clothes: Never let missionaries in P-day clothes into the main cafeteria. Send them to the sack room or to change.',
              'Receipts: Always ask employees and senior missionaries if they would like a receipt.',
              'Closing duties: refill napkins, restock salt/pepper, refill hand sanitizer, take lost and found to front desk, write next meal menu (including hot/fresh bar item), and spot sweep tile floor.',
              'Erasing boards: use a napkin and hand sanitizer, NEVER a rag.',
            ],
          ),
          TrainingTextSection(
            heading: 'Sack Cashier',
            bullets: [
              'Complete assigned secondary job.',
              'Keep black pans (cambros) filled for utensils and condiments.',
            ],
          ),
        ],
        sourceImage: 'Line23.JPG',
      );
    case 'Line24.JPG':
      return const TrainingTextContent(
        title: 'Trashes',
        objective:
            'Create a uniform understanding of what is expected for the trashes secondary.',
        sections: [
          TrainingTextSection(
            heading: 'General Information',
            bullets: [
              'Liners: extra liners are in red buckets hanging on trash carts or in the basement on the right wall.',
              'Tying: on both large and small cans, tie the liner to ensure it does not slip off.',
              'Large Cans: when replacing bags on large circular cans, use 2 liners. These cans are often over-filled and one bag can rip.',
              'Carts: cardboard and trash carts need to be taken back and put into compactors. Break down boxes to create more space.',
            ],
          ),
          TrainingTextSection(
            heading: 'Breakfast/Lunch',
            bullets: [
              'Usually push bags down instead of replacing.',
              'Replace if a can is more than halfway full after pushing down.',
            ],
          ),
          TrainingTextSection(
            heading: 'Dinner',
            bullets: [
              'Replace all cans that contain food, even small amounts.',
              'This helps prevent insects and rodents.',
            ],
          ),
          TrainingTextSection(
            heading: 'Lead Trainers',
            bullets: [
              'A helpful teaching idea is showing how to tie bags properly.',
              'This can be done as a clock-out question or individually with the assigned trash person.',
            ],
          ),
        ],
        sourceImage: 'Line24.JPG',
      );
    case 'Dishroom13.JPG':
      return const TrainingTextContent(
        title: 'General Organization',
        objective:
            'Create a clean, organized environment so dishroom operations stay safe and efficient.',
        sections: [
          TrainingTextSection(
            heading: 'Core Habits',
            bullets: [
              'Keep stations clean throughout shift, not only at close.',
              'Return tools and carts to assigned locations.',
              'Leave each area better than you found it.',
            ],
          ),
        ],
        sourceImage: 'Dishroom13.JPG',
      );
    case 'Dishroom14.JPG':
      return const TrainingTextContent(
        title: 'Night Custodial Chemicals',
        objective:
            'Ensure employees understand uses of custodial chemicals and can identify them correctly.',
        sections: [
          TrainingTextSection(
            heading: 'Pantastic',
            bullets: [
              'Detergent-style cleaner for scrubbing tasks.',
              'Typically identified by blue hue.',
            ],
          ),
          TrainingTextSection(
            heading: 'Oasis 135 Power Force',
            bullets: [
              'Premium degreaser/cleaner for heavy-duty cleaning.',
              'Typically identified by red hue.',
            ],
          ),
          TrainingTextSection(
            heading: 'Safety',
            bullets: [
              'Verify labels before use and follow PPE requirements.',
              'Do not mix chemicals.',
            ],
          ),
        ],
        sourceImage: 'Dishroom14.JPG',
      );
    case 'Dishroom15.JPG':
      return const TrainingTextContent(
        title: 'Gas Connections',
        objective:
            'Help crew members safely disconnect and reconnect gas equipment in kitchen areas.',
        sections: [
          TrainingTextSection(
            heading: 'Disconnection',
            bullets: [
              'Turn off electrical and gas supply first.',
              'Use correct coupling and valve steps before moving equipment.',
            ],
          ),
          TrainingTextSection(
            heading: 'Reconnection',
            bullets: [
              'Reconnect gas and electrical lines in correct order.',
              'Confirm secure connection before operating equipment.',
            ],
          ),
        ],
        sourceImage: 'Dishroom15.JPG',
      );
    case 'Dishroom17.JPG':
      return const TrainingTextContent(
        title: 'Pulpers',
        objective:
            'Ensure employees know proper pulper usage and what must not go into the pulper.',
        sections: [
          TrainingTextSection(
            heading: 'Do Not Put In Pulper',
            bullets: [
              'Banana peels, watermelon rinds, pineapple tops.',
              'Bones, metals, plastics, wrappers, or paper dishes.',
              'Grease/oils and large excessive rice/quinoa loads.',
            ],
          ),
          TrainingTextSection(
            heading: 'Safety',
            bullets: [
              'Never reach into pulper unless disconnect switch is off.',
              'Escalate malfunctions to leadership immediately.',
            ],
          ),
        ],
        sourceImage: 'Dishroom17.JPG',
      );
    case 'Dishroom18.JPG':
      return const TrainingTextContent(
        title: 'Important Cleaning: Dishroom Part 1',
        objective:
            'Review high-priority dishroom cleaning locations that are often missed.',
        sections: [
          TrainingTextSection(
            heading: 'Pit Lead and No Man\'s Land',
            bullets: [
              'Spray and clean underworld and nearby counters thoroughly.',
              'Remove food, water, and dish buildup continuously.',
            ],
          ),
          TrainingTextSection(
            heading: 'Conveyor and Surrounding Areas',
            bullets: [
              'Clean around and under conveyor structures.',
              'Pay attention to hidden splash and residue zones.',
            ],
          ),
        ],
        sourceImage: 'Dishroom18.JPG',
      );
    case 'Dishroom19.JPG':
      return const TrainingTextContent(
        title: 'Important Cleaning: Dish Machine',
        objective:
            'Ensure employees clean hard-to-reach dish machine loading-side areas.',
        sections: [
          TrainingTextSection(
            heading: 'Problem Areas',
            bullets: [
              'Target corners, seams, rails, and hidden buildup points.',
              'Rinse and sanitize surfaces after debris removal.',
            ],
          ),
        ],
        sourceImage: 'Dishroom19.JPG',
      );
    case 'Dishroom20.JPG':
      return const TrainingTextContent(
        title: 'Important Cleaning: Scullery',
        objective:
            'Ensure employees understand key scullery cleaning priorities.',
        sections: [
          TrainingTextSection(
            heading: 'Floors and Drains',
            bullets: [
              'Keep floors clear of food and standing water.',
              'Clean drain zones to prevent buildup and odor.',
            ],
          ),
          TrainingTextSection(
            heading: 'Sink and Work Zones',
            bullets: [
              'Sanitize sink edges and splash areas.',
              'Keep scrubbing and wash stations organized and ready.',
            ],
          ),
        ],
        sourceImage: 'Dishroom20.JPG',
      );
    case 'Dishroom21.JPG':
      return const TrainingTextContent(
        title: 'Stocking Chemicals: Dishroom',
        objective:
            'Ensure employees can safely replace chemical products on dishroom machines.',
        sections: [
          TrainingTextSection(
            heading: 'Before Replacing',
            bullets: [
              'Confirm product label and machine compatibility.',
              'Wear gloves and follow posted safety instructions.',
            ],
          ),
          TrainingTextSection(
            heading: 'Replacement Steps',
            bullets: [
              'Remove empty container and prepare new one correctly.',
              'Seat container/hose securely and verify machine feeds properly.',
            ],
          ),
        ],
        sourceImage: 'Dishroom21.JPG',
      );
    case 'Dishroom22.JPG':
      return const TrainingTextContent(
        title: 'Stocking Chemicals: Scullery and Custodial Closet',
        objective:
            'Ensure employees replace scullery and custodial chemicals safely and accurately.',
        sections: [
          TrainingTextSection(
            heading: 'Verification',
            bullets: [
              'Match product name to the correct machine/system.',
              'Double-check labels before connecting.',
            ],
          ),
          TrainingTextSection(
            heading: 'Safe Handling',
            bullets: [
              'Use gloves and avoid splashes.',
              'Secure all adapters and lines after replacement.',
            ],
          ),
        ],
        sourceImage: 'Dishroom22.JPG',
      );
    case 'Dishroom23.JPG':
      return const TrainingTextContent(
        title: 'Scullery Organization',
        objective:
            'Ensure employees know how to work efficiently in scullery during high volume.',
        sections: [
          TrainingTextSection(
            heading: 'Flow and Consolidation',
            bullets: [
              'Consolidate carts and keep wash flow moving.',
              'Keep pan machine running when load exists.',
            ],
          ),
          TrainingTextSection(
            heading: 'Priorities',
            bullets: [
              'Handle raw-meat dishes quickly and safely.',
              'When caught up, support nearby areas that need help.',
            ],
          ),
        ],
        sourceImage: 'Dishroom23.JPG',
      );
    default:
      return null;
  }
}

TrainingTextContent _requireManualTraining({
  required String sourceImage,
  required String title,
}) {
  final training = _manualTrainingOverride(sourceImage: sourceImage);
  if (training == null) {
    throw StateError(
      'Missing manual training content for $sourceImage ($title)',
    );
  }
  return training;
}

List<TrainingTextContent> _sharedTrainings() => <TrainingTextContent>[
  _requireManualTraining(sourceImage: 'Shared1.JPG', title: 'General Safety'),
  _requireManualTraining(
    sourceImage: 'Shared2.JPG',
    title: 'Medical Emergencies I',
  ),
  _requireManualTraining(
    sourceImage: 'Shared3.JPG',
    title: 'Medical Emergencies II',
  ),
  _requireManualTraining(
    sourceImage: 'Shared4.JPG',
    title: 'Medical Emergencies III',
  ),
  _requireManualTraining(sourceImage: 'Shared5.JPG', title: 'Fire Safety'),
  _requireManualTraining(sourceImage: 'Shared6.JPG', title: 'Chemical Safety'),
  _requireManualTraining(sourceImage: 'Shared7.JPG', title: 'Proper Lifting'),
  _requireManualTraining(sourceImage: 'Shared8.JPG', title: 'Hand Washing'),
  _requireManualTraining(sourceImage: 'Shared9.JPG', title: 'Professionalism'),
  _requireManualTraining(
    sourceImage: 'Shared10.JPG',
    title: 'Staying Productive',
  ),
  _requireManualTraining(
    sourceImage: 'Shared11.JPG',
    title: 'Scheduling and Attendance',
  ),
  _requireManualTraining(
    sourceImage: 'Shared12.JPG',
    title: 'Harassment and Discrimination',
  ),
];

List<TrainingTextContent> buildLineTrainings() => <TrainingTextContent>[
  ..._sharedTrainings(),
  _requireManualTraining(
    sourceImage: 'Line13.JPG',
    title: 'Allergen Awareness',
  ),
  _requireManualTraining(
    sourceImage: 'Line14.JPG',
    title: 'General Organization',
  ),
  _requireManualTraining(
    sourceImage: 'Line15.JPG',
    title: 'Putting Away Dishes',
  ),
  _requireManualTraining(sourceImage: 'Line16.JPG', title: 'Tips and Tricks'),
  _requireManualTraining(
    sourceImage: 'Line17.JPG',
    title: 'Locker 10 Etiquette',
  ),
  _requireManualTraining(
    sourceImage: 'Line18.JPG',
    title: 'Throwing Food Away',
  ),
  _requireManualTraining(sourceImage: 'Line19.JPG', title: 'Runner Reminders'),
  _requireManualTraining(
    sourceImage: 'Line20.JPG',
    title: 'Bathroom Responsibilities',
  ),
  _requireManualTraining(
    sourceImage: 'Line21.JPG',
    title: 'Vacuum Use and Care',
  ),
  _requireManualTraining(
    sourceImage: 'Line22.JPG',
    title: 'Custodial Closet Secondary Jobs',
  ),
  _requireManualTraining(sourceImage: 'Line23.JPG', title: 'Cashier Reminders'),
  _requireManualTraining(sourceImage: 'Line24.JPG', title: 'Trashes Secondary'),
];

List<TrainingTextContent> buildDishroomTrainings() => <TrainingTextContent>[
  ..._sharedTrainings(),
  _requireManualTraining(
    sourceImage: 'Dishroom13.JPG',
    title: 'General Organization',
  ),
  _requireManualTraining(
    sourceImage: 'Dishroom14.JPG',
    title: 'Night Custodial Chemicals',
  ),
  _requireManualTraining(
    sourceImage: 'Dishroom15.JPG',
    title: 'Line Chemicals and Their Purpose',
  ),
  _requireManualTraining(
    sourceImage: 'Dishroom17.JPG',
    title: 'Handwashing Procedures',
  ),
  _requireManualTraining(
    sourceImage: 'Dishroom18.JPG',
    title: 'Pan Machine Basics',
  ),
  _requireManualTraining(
    sourceImage: 'Dishroom19.JPG',
    title: 'Sanitizer Bucket and Rag Standards',
  ),
  _requireManualTraining(
    sourceImage: 'Dishroom20.JPG',
    title: 'Rack Layout and Washing Sequence',
  ),
  _requireManualTraining(
    sourceImage: 'Dishroom21.JPG',
    title: 'Dishroom Closing Priorities',
  ),
  _requireManualTraining(
    sourceImage: 'Dishroom22.JPG',
    title: 'Rack Return and Workstation Reset',
  ),
  _requireManualTraining(
    sourceImage: 'Dishroom23.JPG',
    title: 'Scullery Organization',
  ),
];
