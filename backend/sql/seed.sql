-- seed.sql assumes schema.sql has already been applied. It only inserts and
-- backfills data; DDL lives exclusively in schema.sql so the two files cannot
-- drift.

INSERT INTO roles (name) VALUES
  ('Employee'),
  ('Lead Trainer'),
  ('Supervisor'),
  ('Student Manager'),
  ('Dishroom Lead Trainer')
ON CONFLICT (name) DO NOTHING;

-- Password for all users: password123
INSERT INTO users (email, password_hash, role_id) VALUES
  ('employee@mtc.local', '$2a$10$hFr32lkOgmzoqPreOBkXZuY2jAPG9TpN6Y9FrUWSzjSG10IAVwAsC', (SELECT id FROM roles WHERE name = 'Employee')),
  ('trainer@mtc.local', '$2a$10$hFr32lkOgmzoqPreOBkXZuY2jAPG9TpN6Y9FrUWSzjSG10IAVwAsC', (SELECT id FROM roles WHERE name = 'Lead Trainer')),
  ('supervisor@mtc.local', '$2a$10$hFr32lkOgmzoqPreOBkXZuY2jAPG9TpN6Y9FrUWSzjSG10IAVwAsC', (SELECT id FROM roles WHERE name = 'Supervisor')),
  ('manager@mtc.local', '$2a$10$hFr32lkOgmzoqPreOBkXZuY2jAPG9TpN6Y9FrUWSzjSG10IAVwAsC', (SELECT id FROM roles WHERE name = 'Student Manager')),
  ('employee2@mtc.local', '$2a$10$hFr32lkOgmzoqPreOBkXZuY2jAPG9TpN6Y9FrUWSzjSG10IAVwAsC', (SELECT id FROM roles WHERE name = 'Employee')),
  ('employee3@mtc.local', '$2a$10$hFr32lkOgmzoqPreOBkXZuY2jAPG9TpN6Y9FrUWSzjSG10IAVwAsC', (SELECT id FROM roles WHERE name = 'Employee')),
  ('employee4@mtc.local', '$2a$10$hFr32lkOgmzoqPreOBkXZuY2jAPG9TpN6Y9FrUWSzjSG10IAVwAsC', (SELECT id FROM roles WHERE name = 'Employee')),
  ('dishtrainer@mtc.local', '$2a$10$hFr32lkOgmzoqPreOBkXZuY2jAPG9TpN6Y9FrUWSzjSG10IAVwAsC', (SELECT id FROM roles WHERE name = 'Dishroom Lead Trainer'))
ON CONFLICT (email) DO UPDATE SET
  password_hash = EXCLUDED.password_hash,
  role_id = EXCLUDED.role_id;

INSERT INTO points (user_id, points) VALUES
  ((SELECT id FROM users WHERE email = 'employee@mtc.local'), 8),
  ((SELECT id FROM users WHERE email = 'trainer@mtc.local'), 7),
  ((SELECT id FROM users WHERE email = 'supervisor@mtc.local'), 9),
  ((SELECT id FROM users WHERE email = 'manager@mtc.local'), 6),
  ((SELECT id FROM users WHERE email = 'employee2@mtc.local'), 9),
  ((SELECT id FROM users WHERE email = 'employee3@mtc.local'), 5),
  ((SELECT id FROM users WHERE email = 'employee4@mtc.local'), 6),
  ((SELECT id FROM users WHERE email = 'dishtrainer@mtc.local'), 4)
ON CONFLICT (user_id) DO NOTHING;

-- Remove the old prototype demo report if it exists. This is intentionally
-- narrow so reseeding does not wipe legitimate production report history.
DELETE FROM daily_shift_reports
WHERE track = 'Line'
  AND meal_type = 'Breakfast'
  AND submitted_by_user_id = (SELECT id FROM users WHERE email = 'supervisor@mtc.local')
  AND payload->>'summaries' = 'Eggs count: 490. Pancakes count: 287.'
  AND payload->>'maintenanceConcerns' = 'Right juice machine on line 4 is warm';

DELETE FROM announcements;

INSERT INTO announcements (type, title, content, start_date, end_date, created_by)
VALUES
(
  'Reminder',
  'Shift Readiness Reminder',
  'Arrive on time, clean shaven, and dressed in missionary-appropriate work attire.',
  CURRENT_DATE,
  CURRENT_DATE + INTERVAL '180 day',
  (SELECT id FROM users WHERE email = 'manager@mtc.local')
),
(
  'Announcement',
  'Seasonal Shift Sign-Up',
  'Complete your spring and summer shift sign-up, even if you expect to be away, so staffing can be planned correctly.',
  CURRENT_DATE,
  CURRENT_DATE + INTERVAL '180 day',
  (SELECT id FROM users WHERE email = 'manager@mtc.local')
),
(
  'Special Event',
  'VIP Event Volunteer Sign-Up',
  'Volunteer sign-up is open for next Tuesday''s VIP event. Add your name if you are available to help.',
  CURRENT_DATE + INTERVAL '1 day',
  CURRENT_DATE + INTERVAL '180 day',
  (SELECT id FROM users WHERE email = 'manager@mtc.local')
);

INSERT INTO trainings (title, content, assigned_date)
VALUES
  ('Service Tone', 'Greet guests and keep communication warm and clear.', CURRENT_DATE),
  ('Safety Refresh', 'Review food-contact surface sanitation guidelines.', CURRENT_DATE + INTERVAL '1 day')
ON CONFLICT DO NOTHING;

-- Self-heal duplicate shift/job rows that earlier seed runs could create
-- because (shift_type, meal_type) and (shift_id, name) were not unique yet.
-- Without this, re-running seed.sql (or reapplying it against an already
-- populated database) piled on additional "Breakfast Line Shift" rows and,
-- in turn, additional per-shift "Beverages"/"Sack Cashier"/etc. jobs. We
-- collapse duplicates by keeping the oldest id in each group, rehoming any
-- jobs/tasks attached to the loser rows, then enforce uniqueness so
-- subsequent re-runs stay idempotent via ON CONFLICT targets below.

UPDATE jobs j
SET shift_id = canonical.keep_id
FROM (
  SELECT
    id,
    MIN(id) OVER (PARTITION BY shift_type, meal_type) AS keep_id
  FROM shifts
) canonical
WHERE j.shift_id = canonical.id
  AND j.shift_id <> canonical.keep_id;

DELETE FROM shifts
WHERE id IN (
  SELECT id FROM (
    SELECT
      id,
      ROW_NUMBER() OVER (
        PARTITION BY shift_type, meal_type
        ORDER BY id
      ) AS rn
    FROM shifts
  ) ranked
  WHERE rn > 1
);

DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_constraint WHERE conname = 'shifts_shift_type_meal_type_key'
  ) THEN
    ALTER TABLE shifts
      ADD CONSTRAINT shifts_shift_type_meal_type_key UNIQUE (shift_type, meal_type);
  END IF;
END $$;

UPDATE tasks t
SET job_id = canonical.keep_id
FROM (
  SELECT
    id,
    MIN(id) OVER (PARTITION BY shift_id, name) AS keep_id
  FROM jobs
) canonical
WHERE t.job_id = canonical.id
  AND t.job_id <> canonical.keep_id;

DELETE FROM jobs
WHERE id IN (
  SELECT id FROM (
    SELECT
      id,
      ROW_NUMBER() OVER (
        PARTITION BY shift_id, name
        ORDER BY id
      ) AS rn
    FROM jobs
  ) ranked
  WHERE rn > 1
);

DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_constraint WHERE conname = 'jobs_shift_id_name_key'
  ) THEN
    ALTER TABLE jobs
      ADD CONSTRAINT jobs_shift_id_name_key UNIQUE (shift_id, name);
  END IF;
END $$;

INSERT INTO shifts (shift_type, meal_type, name) VALUES
  ('Line Shift', 'Breakfast', 'Breakfast Line Shift'),
  ('Line Shift', 'Lunch', 'Lunch Line Shift'),
  ('Line Shift', 'Dinner', 'Dinner Line Shift')
ON CONFLICT (shift_type, meal_type) DO NOTHING;

-- Replace legacy unsplit shared jobs with split variants.
DELETE FROM jobs
WHERE name IN ('Line Runner', 'Beverages', 'Beverages (A)', 'Beverages (B)')
  AND shift_id IN (
    SELECT id FROM shifts WHERE shift_type = 'Line Shift'
  );

DELETE FROM jobs
WHERE name IN ('Aloha Plate', 'Choices')
  AND shift_id IN (
    SELECT id FROM shifts
    WHERE shift_type = 'Line Shift' AND meal_type = 'Breakfast'
  );

WITH meal_jobs AS (
  SELECT * FROM (VALUES
    ('Breakfast', 'Sack Cashier'),
    ('Breakfast', 'Sack Runner'),
    ('Breakfast', 'Salads'),
    ('Breakfast', 'Server'),
    ('Breakfast', 'Volunteer Coordinator'),
    ('Breakfast', 'Line Running (Left)'),
    ('Breakfast', 'Line Running (Right)'),
    ('Breakfast', 'Beverages'),
    ('Breakfast', 'Senior Cash'),
    ('Breakfast', 'Junior Cash'),
    ('Breakfast', 'Desserts'),
    ('Breakfast', 'Condiments Prep'),
    ('Breakfast', 'Condiments Host'),
    ('Lunch', 'Sack Cashier'),
    ('Lunch', 'Sack Runner'),
    ('Lunch', 'Salads'),
    ('Lunch', 'Server'),
    ('Lunch', 'Volunteer Coordinator'),
    ('Lunch', 'Ice Cream'),
    ('Lunch', 'Paninis'),
    ('Lunch', 'Line Running (Left)'),
    ('Lunch', 'Line Running (Right)'),
    ('Lunch', 'Aloha Plate'),
    ('Lunch', 'Choices'),
    ('Lunch', 'Beverages'),
    ('Lunch', 'Senior Cash'),
    ('Lunch', 'Junior Cash'),
    ('Lunch', 'Desserts'),
    ('Lunch', 'Condiments Prep'),
    ('Lunch', 'Condiments Host'),
    ('Dinner', 'Server'),
    ('Dinner', 'Volunteer Coordinator'),
    ('Dinner', 'Ice Cream'),
    ('Dinner', 'Paninis'),
    ('Dinner', 'Line Running (Left)'),
    ('Dinner', 'Line Running (Right)'),
    ('Dinner', 'Aloha Plate'),
    ('Dinner', 'Choices'),
    ('Dinner', 'Beverages'),
    ('Dinner', 'Senior Cash'),
    ('Dinner', 'Junior Cash'),
    ('Dinner', 'Desserts'),
    ('Dinner', 'Condiments Prep'),
    ('Dinner', 'Condiments Host')
  ) AS t(meal_type, job_name)
)
INSERT INTO jobs (shift_id, name)
SELECT s.id, mj.job_name
FROM meal_jobs mj
JOIN shifts s ON s.meal_type = mj.meal_type
ON CONFLICT (shift_id, name) DO NOTHING;

-- Keep line task definitions aligned with the latest reference sheets.
DELETE FROM task_progress
WHERE task_id IN (
  SELECT t.id
  FROM tasks t
  JOIN jobs j ON j.id = t.job_id
  JOIN shifts s ON s.id = j.shift_id
  WHERE s.shift_type = 'Line Shift'
);

DELETE FROM supervisor_task_checks
WHERE task_id IN (
  SELECT t.id
  FROM tasks t
  JOIN jobs j ON j.id = t.job_id
  JOIN shifts s ON s.id = j.shift_id
  WHERE s.shift_type = 'Line Shift'
);

DELETE FROM tasks
WHERE job_id IN (
  SELECT j.id
  FROM jobs j
  JOIN shifts s ON s.id = j.shift_id
  WHERE s.shift_type = 'Line Shift'
);

WITH meal_specific_task_defs AS (
  SELECT * FROM (VALUES
    ('Breakfast', 'Sack Cashier', 'Setup', 'Put out oatmeal'),
    ('Breakfast', 'Sack Cashier', 'Setup', 'Put out oatmeal cups and lids'),
    ('Breakfast', 'Sack Cashier', 'Setup', 'Turn on cooler lights'),
    ('Breakfast', 'Sack Cashier', 'Setup', 'Put out donuts'),
    ('Breakfast', 'Sack Cashier', 'Setup', 'Put out donut utensils'),
    ('Breakfast', 'Sack Cashier', 'Setup', 'Unlock door when doors open'),
    ('Breakfast', 'Sack Cashier', 'Setup', 'Flip sign to "Open"'),
    ('Breakfast', 'Sack Cashier', 'Setup', 'Set up and sign into register'),
    ('Breakfast', 'Sack Cashier', 'During Shift', 'Ensure missionaries swipe cards'),
    ('Breakfast', 'Sack Cashier', 'During Shift', 'Keep count of missionaries who do not swipe'),
    ('Breakfast', 'Sack Cashier', 'During Shift', 'Ring up senior missionaries'),
    ('Breakfast', 'Sack Cashier', 'During Shift', 'Communicate with sack runner when items run out'),
    ('Breakfast', 'Sack Cashier', 'Cleanup', 'Flip sign to "Closed"'),
    ('Breakfast', 'Sack Cashier', 'Cleanup', 'Lock door'),
    ('Breakfast', 'Sack Cashier', 'Cleanup', 'Log out of register'),
    ('Breakfast', 'Sack Cashier', 'Cleanup', 'Turn off cooler lights'),
    ('Breakfast', 'Sack Cashier', 'Cleanup', 'Restock drinks'),
    ('Breakfast', 'Sack Cashier', 'Cleanup', 'Put away donuts'),
    ('Breakfast', 'Sack Cashier', 'Cleanup', 'Put away oatmeal'),
    ('Breakfast', 'Sack Cashier', 'Cleanup', 'Wipe counters'),
    ('Breakfast', 'Sack Cashier', 'Cleanup', 'Vacuum area'),
    ('Lunch', 'Sack Cashier', 'Setup', 'Put out soups'),
    ('Lunch', 'Sack Cashier', 'Setup', 'Ensure sandwiches are available (not displayed)'),
    ('Lunch', 'Sack Cashier', 'Setup', 'Put out cookies'),
    ('Lunch', 'Sack Cashier', 'Setup', 'Put out chips'),
    ('Lunch', 'Sack Cashier', 'Setup', 'Ensure salads are available'),
    ('Lunch', 'Sack Cashier', 'Setup', 'Turn on cooler lights'),
    ('Lunch', 'Sack Cashier', 'Setup', 'Unlock door when doors open'),
    ('Lunch', 'Sack Cashier', 'Setup', 'Flip sign to "Open"'),
    ('Lunch', 'Sack Cashier', 'Setup', 'Set up and sign into register'),
    ('Lunch', 'Sack Cashier', 'During Shift', 'Ensure missionaries swipe cards'),
    ('Lunch', 'Sack Cashier', 'During Shift', 'Keep count of missionaries who do not swipe'),
    ('Lunch', 'Sack Cashier', 'During Shift', 'Ring up senior missionaries'),
    ('Lunch', 'Sack Cashier', 'During Shift', 'Communicate with sack runner when items run out'),
    ('Lunch', 'Sack Cashier', 'Cleanup', 'Flip sign to "Closed"'),
    ('Lunch', 'Sack Cashier', 'Cleanup', 'Lock door'),
    ('Lunch', 'Sack Cashier', 'Cleanup', 'Log out of register'),
    ('Lunch', 'Sack Cashier', 'Cleanup', 'Turn off cooler lights'),
    ('Lunch', 'Sack Cashier', 'Cleanup', 'Restock drinks'),
    ('Lunch', 'Sack Cashier', 'Cleanup', 'Restock sandwiches'),
    ('Lunch', 'Sack Cashier', 'Cleanup', 'Restock salads'),
    ('Lunch', 'Sack Cashier', 'Cleanup', 'Wipe counters'),
    ('Lunch', 'Sack Cashier', 'Cleanup', 'Vacuum area'),
    ('Breakfast', 'Salads', 'Setup', 'Put out fruit and breakfast salad items'),
    ('Breakfast', 'Salads', 'Setup', 'Ensure plates are stocked'),
    ('Breakfast', 'Salads', 'During Shift', 'Keep salad bar stocked'),
    ('Breakfast', 'Salads', 'During Shift', 'Ensure plates remain stocked'),
    ('Breakfast', 'Salads', 'During Shift', 'Keep oatmeal, grits, or similar items stocked and warm'),
    ('Breakfast', 'Salads', 'Cleanup', 'Surfaces cleaned'),
    ('Breakfast', 'Salads', 'Cleanup', 'Soup area clean'),
    ('Breakfast', 'Salads', 'Cleanup', 'Fridges wiped out'),
    ('Breakfast', 'Salads', 'Cleanup', 'Floor swept in and out of island'),
    ('Breakfast', 'Salads', 'Cleanup', 'Bowls/plates restocked'),
    ('Breakfast', 'Salads', 'Cleanup', 'Fruit shelf restocked'),
    ('Breakfast', 'Salads', 'Cleanup', 'Lettuce wraps/dressings restocked'),
    ('Breakfast', 'Salads', 'Cleanup', 'Trash emptied'),
    ('Lunch', 'Salads', 'Setup', 'Put out salad ingredients'),
    ('Lunch', 'Salads', 'Setup', 'Put out tortillas'),
    ('Lunch', 'Salads', 'Setup', 'Set up deli bar'),
    ('Lunch', 'Salads', 'Setup', 'Ensure plates are stocked'),
    ('Lunch', 'Salads', 'During Shift', 'Keep salad bar stocked'),
    ('Lunch', 'Salads', 'During Shift', 'Ensure plates remain stocked'),
    ('Lunch', 'Salads', 'Cleanup', 'Surfaces cleaned'),
    ('Lunch', 'Salads', 'Cleanup', 'Soup area clean'),
    ('Lunch', 'Salads', 'Cleanup', 'Fridges wiped out'),
    ('Lunch', 'Salads', 'Cleanup', 'Floor swept in and out of island'),
    ('Lunch', 'Salads', 'Cleanup', 'Bowls/plates restocked'),
    ('Lunch', 'Salads', 'Cleanup', 'Fruit shelf restocked'),
    ('Lunch', 'Salads', 'Cleanup', 'Lettuce wraps/dressings restocked'),
    ('Lunch', 'Salads', 'Cleanup', 'Trash emptied')
  ) AS t(meal_type, job_name, phase, description)
),
generic_task_defs AS (
  SELECT * FROM (VALUES
    ('Sack Runner', 'Setup', 'Assist sack cashier with setup tasks'),
    ('Sack Runner', 'During Shift', 'Restock items from sack room as needed'),
    ('Sack Runner', 'During Shift', 'Coordinate with sack cashier'),
    ('Sack Runner', 'Cleanup', 'Assist sack cashier with cleanup tasks'),
    ('Server', 'Setup', 'Follow the line map and set up the serving line'),
    ('Server', 'Setup', 'Make sure the display plate has been put out'),
    ('Server', 'Setup', 'Put 6 plates or 10 bowls out onto the hot pad before the doors open'),
    ('Server', 'During Shift', 'Serve the food'),
    ('Server', 'During Shift', 'Communicate your needs to the runner as they come up'),
    ('Server', 'Cleanup', 'Clean up the serving line and make sure the heaters and light are turned off'),
    ('Volunteer Coordinator', 'Setup', 'Meet the volunteer missionaries when they arrive'),
    ('Volunteer Coordinator', 'Setup', 'Make sure they get aprons, gloves, and hairnets'),
    ('Volunteer Coordinator', 'Setup', 'Explain their assigned work clearly before they start'),
    ('Volunteer Coordinator', 'Setup', 'Coordinate with supervisors and line leads so volunteers are placed where they are needed most'),
    ('Volunteer Coordinator', 'During Shift', 'Check in on volunteers and redirect them if needs change'),
    ('Volunteer Coordinator', 'During Shift', 'Switch out the current volunteer group when the next district arrives halfway through the shift'),
    ('Volunteer Coordinator', 'During Shift', 'Keep volunteers working in the highest-need areas instead of standing idle'),
    ('Volunteer Coordinator', 'Cleanup', 'Direct volunteers to wipe tables, vacuum, and help with dining-room cleanup at the end of the shift'),
    ('Volunteer Coordinator', 'Cleanup', 'Collect aprons and make sure shared supplies are returned'),
    ('Paninis', 'Setup', 'Turn on panini machines'),
    ('Paninis', 'During Shift', 'Prepare paninis'),
    ('Paninis', 'During Shift', 'Press paninis in machines'),
    ('Paninis', 'During Shift', 'Cut paninis'),
    ('Paninis', 'During Shift', 'Put paninis out for service'),
    ('Paninis', 'Cleanup', 'Panini presses and tools cleaned'),
    ('Paninis', 'Cleanup', 'Surfaces wiped and floor swept'),
    ('Paninis', 'Cleanup', 'Heated shelf off and cleaned'),
    ('Ice Cream', 'Setup', 'Get ice cream'),
    ('Ice Cream', 'Setup', 'Get scoops'),
    ('Ice Cream', 'Setup', 'Get bowls'),
    ('Ice Cream', 'Setup', 'Get water as needed'),
    ('Ice Cream', 'During Shift', 'Serve ice cream'),
    ('Ice Cream', 'Cleanup', 'Dirty trays/utensils taken to scullery'),
    ('Ice Cream', 'Cleanup', 'Dessert plates restocked'),
    ('Ice Cream', 'Cleanup', 'Desserts put away in correct spot'),
    ('Ice Cream', 'Cleanup', 'Counters/surfaces cleaned and dried'),
    ('Ice Cream', 'Cleanup', 'Floor swept'),
    ('Ice Cream', 'Cleanup', 'Cereal bowls restocked'),
    ('Ice Cream', 'Cleanup', 'Silverware restocked'),
    ('Condiments Prep', 'Setup', 'Ensure condiment cart is full'),
    ('Condiments Prep', 'Setup', 'Assist condiments host with setup'),
    ('Condiments Prep', 'During Shift', 'Keep condiments stocked'),
    ('Condiments Prep', 'During Shift', 'Prepare condiments for next meal'),
    ('Condiments Prep', 'During Shift', 'If dinner: prepare condiments for breakfast bar next day'),
    ('Condiments Prep', 'Cleanup', 'Enough prepped for next meal'),
    ('Condiments Prep', 'Cleanup', 'Specialty condiments prepped'),
    ('Condiments Prep', 'Cleanup', 'PB, J, and butter prepped'),
    ('Condiments Prep', 'Cleanup', 'Prep surfaces cleaned and dried'),
    ('Condiments Prep', 'Cleanup', 'Toaster station cleaned and restocked'),
    ('Condiments Prep', 'Cleanup', 'Condiment dispensers clean and full'),
    ('Condiments Prep', 'Cleanup', 'Pump station swept under'),
    ('Condiments Prep', 'Cleanup', 'Fruit bar surfaces cleaned and dried'),
    ('Condiments Prep', 'Cleanup', 'Bowls/plates restocked on fruit bar'),
    ('Condiments Host', 'Setup', 'Turn on fruit bar cooler'),
    ('Condiments Host', 'Setup', 'Put out fruit (4 shotgun pans of fruit, 2 of specialty food)'),
    ('Condiments Host', 'Setup', 'Put out any special condiments to salad bar'),
    ('Condiments Host', 'Setup', 'Put up allergen signs'),
    ('Condiments Host', 'Setup', 'Put utensils in the peanut butter, and butter next to Aloha plate'),
    ('Condiments Host', 'Setup', 'Make sure the condiment stands are stocked'),
    ('Condiments Host', 'Setup', 'Put spoons in the fruit'),
    ('Condiments Host', 'During Shift', 'Ensure everything stays stocked: fruit, condiments, and salad bar condiments'),
    ('Condiments Host', 'Cleanup', 'Wrap and put away the specialty food'),
    ('Condiments Host', 'Cleanup', 'Wrap the fruit, leave it in place, and leave the cooler on'),
    ('Condiments Host', 'Cleanup', 'Put away the allergen signs'),
    ('Condiments Host', 'Cleanup', 'Wipe down the fruit bar'),
    ('Condiments Host', 'Cleanup', 'Wipe down all the condiment bars'),
    ('Condiments Host', 'Cleanup', 'Wipe down the condiment area of the salad bar'),
    ('Condiments Host', 'Cleanup', 'Move salad bar condiments to the student table'),
    ('Line Running (Left)', 'Setup', 'Fill wells with water'),
    ('Line Running (Left)', 'Setup', 'Turn on heat'),
    ('Line Running (Left)', 'Setup', 'Turn on heating elements'),
    ('Line Running (Left)', 'Setup', 'Put food out in correct order'),
    ('Line Running (Left)', 'Setup', 'Get utensils'),
    ('Line Running (Left)', 'Setup', 'Prepare plate stacks'),
    ('Line Running (Left)', 'During Shift', 'Keep food stocked'),
    ('Line Running (Left)', 'During Shift', 'Communicate with chefs as needed'),
    ('Line Running (Left)', 'During Shift', 'Put plates out 10 at a time'),
    ('Line Running (Left)', 'During Shift', 'Keep track of plate counts'),
    ('Line Running (Left)', 'Cleanup', 'Plates/bowls restocked'),
    ('Line Running (Left)', 'Cleanup', 'Heaters off'),
    ('Line Running (Left)', 'Cleanup', 'Surfaces clean and dry'),
    ('Line Running (Left)', 'Cleanup', 'Drain closed and bucket empty'),
    ('Line Running (Left)', 'Cleanup', 'Floors swept (including under station)'),
    ('Line Running (Left)', 'Cleanup', 'Trash emptied'),
    ('Line Running (Right)', 'Setup', 'Fill wells with water'),
    ('Line Running (Right)', 'Setup', 'Turn on heat'),
    ('Line Running (Right)', 'Setup', 'Turn on heating elements'),
    ('Line Running (Right)', 'Setup', 'Put food out in correct order'),
    ('Line Running (Right)', 'Setup', 'Get utensils'),
    ('Line Running (Right)', 'Setup', 'Prepare plate stacks'),
    ('Line Running (Right)', 'During Shift', 'Keep food stocked'),
    ('Line Running (Right)', 'During Shift', 'Communicate with chefs as needed'),
    ('Line Running (Right)', 'During Shift', 'Put plates out 10 at a time'),
    ('Line Running (Right)', 'During Shift', 'Keep track of plate counts'),
    ('Line Running (Right)', 'Cleanup', 'Plates/bowls restocked'),
    ('Line Running (Right)', 'Cleanup', 'Heaters off'),
    ('Line Running (Right)', 'Cleanup', 'Surfaces clean and dry'),
    ('Line Running (Right)', 'Cleanup', 'Drain closed and bucket empty'),
    ('Line Running (Right)', 'Cleanup', 'Floors swept (including under station)'),
    ('Line Running (Right)', 'Cleanup', 'Trash emptied'),
    ('Aloha Plate', 'Setup', 'Fill wells with water'),
    ('Aloha Plate', 'Setup', 'Turn on heat'),
    ('Aloha Plate', 'Setup', 'Turn on heating elements'),
    ('Aloha Plate', 'Setup', 'Put food out in correct order'),
    ('Aloha Plate', 'Setup', 'Get utensils'),
    ('Aloha Plate', 'Setup', 'Prepare plate stacks'),
    ('Aloha Plate', 'During Shift', 'Keep food stocked'),
    ('Aloha Plate', 'During Shift', 'Communicate with chefs as needed'),
    ('Aloha Plate', 'During Shift', 'Put plates out 10 at a time'),
    ('Aloha Plate', 'During Shift', 'Keep track of plate counts'),
    ('Aloha Plate', 'Cleanup', 'Plates/bowls restocked'),
    ('Aloha Plate', 'Cleanup', 'Heaters off'),
    ('Aloha Plate', 'Cleanup', 'Surfaces clean and dry'),
    ('Aloha Plate', 'Cleanup', 'Drain closed and bucket empty'),
    ('Aloha Plate', 'Cleanup', 'Floors swept (including under station)'),
    ('Aloha Plate', 'Cleanup', 'Trash emptied'),
    ('Choices', 'Setup', 'Fill wells with water'),
    ('Choices', 'Setup', 'Turn on heat'),
    ('Choices', 'Setup', 'Turn on heating elements'),
    ('Choices', 'Setup', 'Put food out in correct order'),
    ('Choices', 'Setup', 'Get utensils'),
    ('Choices', 'Setup', 'Prepare plate stacks'),
    ('Choices', 'During Shift', 'Keep food stocked'),
    ('Choices', 'During Shift', 'Communicate with chefs as needed'),
    ('Choices', 'During Shift', 'Put plates out 10 at a time'),
    ('Choices', 'During Shift', 'Keep track of plate counts'),
    ('Choices', 'Cleanup', 'Plates/bowls restocked'),
    ('Choices', 'Cleanup', 'Heaters off'),
    ('Choices', 'Cleanup', 'Surfaces clean and dry'),
    ('Choices', 'Cleanup', 'Drain closed and bucket empty'),
    ('Choices', 'Cleanup', 'Floors swept (including under station)'),
    ('Choices', 'Cleanup', 'Trash emptied'),
    ('Beverages', 'Setup', 'Ensure all beverages are stocked'),
    ('Beverages', 'Setup', 'Turn on beverage machines'),
    ('Beverages', 'During Shift', 'Restock cups'),
    ('Beverages', 'During Shift', 'Check bib room for soda stock'),
    ('Beverages', 'During Shift', 'Ensure sodas are stocked'),
    ('Beverages', 'During Shift', 'Ensure juices are stocked'),
    ('Beverages', 'During Shift', 'Ensure all beverage stations remain stocked'),
    ('Beverages', 'Cleanup', 'Milks and juices restocked'),
    ('Beverages', 'Cleanup', 'Milk/soda/juice machines cleaned'),
    ('Beverages', 'Cleanup', 'Cups filled'),
    ('Beverages', 'Cleanup', 'Ice filled'),
    ('Beverages', 'Cleanup', 'Scissors cleaned'),
    ('Beverages', 'Cleanup', 'Milk trays cleaned'),
    ('Beverages', 'Cleanup', 'Coke machine nozzles (dinner)'),
    ('Beverages', 'Cleanup', 'Blue crates to Empire Crate Building'),
    ('Beverages', 'Cleanup', 'Empire Crate Building wrapped'),
    ('Beverages', 'Cleanup', 'Vitamin waters restocked'),
    ('Beverages', 'Cleanup', 'BIB room checked'),
    ('Senior Cash', 'Setup', 'Sign into register'),
    ('Senior Cash', 'Setup', 'Verify register is ready'),
    ('Senior Cash', 'During Shift', 'Ring up senior missionaries'),
    ('Senior Cash', 'Cleanup', 'Napkins and salt/pepper'),
    ('Senior Cash', 'Cleanup', 'Sanitizer and paper towels'),
    ('Senior Cash', 'Cleanup', 'Lost and found items to front desk'),
    ('Senior Cash', 'Cleanup', 'Write next meal menu on door'),
    ('Senior Cash', 'Cleanup', 'Refill sanitizer bottles'),
    ('Senior Cash', 'Cleanup', 'Sweep tile floor'),
    ('Junior Cash', 'Setup', 'Sign into register'),
    ('Junior Cash', 'During Shift', 'Ensure missionaries swipe cards'),
    ('Junior Cash', 'During Shift', 'Keep count of missionaries without cards'),
    ('Junior Cash', 'Cleanup', 'Napkins and salt/pepper'),
    ('Junior Cash', 'Cleanup', 'Sanitizer and paper towels'),
    ('Junior Cash', 'Cleanup', 'Lost and found items to front desk'),
    ('Junior Cash', 'Cleanup', 'Write next meal menu on door'),
    ('Junior Cash', 'Cleanup', 'Refill sanitizer bottles'),
    ('Junior Cash', 'Cleanup', 'Sweep tile floor'),
    ('Desserts', 'Setup', 'Put out desserts'),
    ('Desserts', 'Setup', 'Breakfast: donuts'),
    ('Desserts', 'Setup', 'Lunch/Dinner: cookies or assigned desserts'),
    ('Desserts', 'Setup', 'Put out plates'),
    ('Desserts', 'Setup', 'Put out utensils'),
    ('Desserts', 'During Shift', 'Keep desserts stocked'),
    ('Desserts', 'During Shift', 'Keep utensils stocked'),
    ('Desserts', 'Cleanup', 'Dirty trays/utensils taken to scullery'),
    ('Desserts', 'Cleanup', 'Dessert plates restocked'),
    ('Desserts', 'Cleanup', 'Desserts put away in correct spot'),
    ('Desserts', 'Cleanup', 'Counters/surfaces cleaned and dried'),
    ('Desserts', 'Cleanup', 'Floor swept'),
    ('Desserts', 'Cleanup', 'Cereal bowls restocked'),
    ('Desserts', 'Cleanup', 'Silverware restocked')
  ) AS t(job_name, phase, description)
),
meal_jobs AS (
  SELECT * FROM (VALUES
    ('Breakfast', 'Sack Cashier'),
    ('Breakfast', 'Sack Runner'),
    ('Breakfast', 'Salads'),
    ('Breakfast', 'Server'),
    ('Breakfast', 'Volunteer Coordinator'),
    ('Breakfast', 'Line Running (Left)'),
    ('Breakfast', 'Line Running (Right)'),
    ('Breakfast', 'Beverages'),
    ('Breakfast', 'Senior Cash'),
    ('Breakfast', 'Junior Cash'),
    ('Breakfast', 'Desserts'),
    ('Breakfast', 'Condiments Prep'),
    ('Breakfast', 'Condiments Host'),
    ('Lunch', 'Sack Cashier'),
    ('Lunch', 'Sack Runner'),
    ('Lunch', 'Salads'),
    ('Lunch', 'Server'),
    ('Lunch', 'Volunteer Coordinator'),
    ('Lunch', 'Ice Cream'),
    ('Lunch', 'Paninis'),
    ('Lunch', 'Line Running (Left)'),
    ('Lunch', 'Line Running (Right)'),
    ('Lunch', 'Aloha Plate'),
    ('Lunch', 'Choices'),
    ('Lunch', 'Beverages'),
    ('Lunch', 'Senior Cash'),
    ('Lunch', 'Junior Cash'),
    ('Lunch', 'Desserts'),
    ('Lunch', 'Condiments Prep'),
    ('Lunch', 'Condiments Host'),
    ('Dinner', 'Server'),
    ('Dinner', 'Volunteer Coordinator'),
    ('Dinner', 'Ice Cream'),
    ('Dinner', 'Paninis'),
    ('Dinner', 'Line Running (Left)'),
    ('Dinner', 'Line Running (Right)'),
    ('Dinner', 'Aloha Plate'),
    ('Dinner', 'Choices'),
    ('Dinner', 'Beverages'),
    ('Dinner', 'Senior Cash'),
    ('Dinner', 'Junior Cash'),
    ('Dinner', 'Desserts'),
    ('Dinner', 'Condiments Prep'),
    ('Dinner', 'Condiments Host')
  ) AS t(meal_type, job_name)
)
INSERT INTO tasks (job_id, phase, description)
SELECT j.id, ms.phase, ms.description
FROM meal_specific_task_defs ms
JOIN shifts s ON s.meal_type = ms.meal_type
JOIN jobs j ON j.shift_id = s.id AND j.name = ms.job_name
WHERE NOT EXISTS (
  SELECT 1 FROM tasks t
  WHERE t.job_id = j.id AND t.phase = ms.phase AND t.description = ms.description
)
UNION ALL
SELECT j.id, gd.phase, gd.description
FROM generic_task_defs gd
JOIN meal_jobs mj ON mj.job_name = gd.job_name
JOIN shifts s ON s.meal_type = mj.meal_type
JOIN jobs j ON j.shift_id = s.id AND j.name = gd.job_name
WHERE NOT EXISTS (
  SELECT 1 FROM tasks t
  WHERE t.job_id = j.id AND t.phase = gd.phase AND t.description = gd.description
);

INSERT INTO task_progress (user_id, task_id, completed, supervisor_checked)
VALUES
  ((SELECT id FROM users WHERE email = 'employee@mtc.local'), (SELECT id FROM tasks ORDER BY id LIMIT 1), true, false),
  ((SELECT id FROM users WHERE email = 'trainer@mtc.local'), (SELECT id FROM tasks ORDER BY id LIMIT 1), true, false)
ON CONFLICT (user_id, task_id) DO UPDATE
SET
  completed = EXCLUDED.completed,
  supervisor_checked = EXCLUDED.supervisor_checked;

INSERT INTO supervisor_job_checks (meal_type, job_id, checked)
VALUES
  ('Breakfast', (SELECT j.id FROM jobs j JOIN shifts s ON s.id = j.shift_id WHERE s.meal_type = 'Breakfast' AND j.name = 'Sack Cashier' LIMIT 1), false)
ON CONFLICT (meal_type, job_id) DO UPDATE
SET
  checked = EXCLUDED.checked,
  updated_at = NOW();

INSERT INTO supervisor_task_checks (meal_type, job_id, task_id, checked)
VALUES (
  'Breakfast',
  (SELECT j.id FROM jobs j JOIN shifts s ON s.id = j.shift_id WHERE s.meal_type = 'Breakfast' AND j.name = 'Sack Cashier' LIMIT 1),
  (SELECT t.id FROM tasks t JOIN jobs j ON j.id = t.job_id JOIN shifts s ON s.id = j.shift_id WHERE s.meal_type = 'Breakfast' AND j.name = 'Sack Cashier' AND t.phase = 'Cleanup' ORDER BY t.id LIMIT 1),
  false
)
ON CONFLICT (meal_type, job_id, task_id) DO UPDATE
SET
  checked = EXCLUDED.checked,
  updated_at = NOW();

INSERT INTO trainer_assignments (trainer_user_id, trainee_user_id, job_id)
VALUES
  (
    (SELECT id FROM users WHERE email = 'trainer@mtc.local'),
    (SELECT id FROM users WHERE email = 'employee@mtc.local'),
    (SELECT j.id FROM jobs j JOIN shifts s ON s.id = j.shift_id WHERE s.meal_type = 'Breakfast' AND j.name = 'Condiments Host' LIMIT 1)
  ),
  (
    (SELECT id FROM users WHERE email = 'trainer@mtc.local'),
    (SELECT id FROM users WHERE email = 'employee2@mtc.local'),
    (SELECT j.id FROM jobs j JOIN shifts s ON s.id = j.shift_id WHERE s.meal_type = 'Breakfast' AND j.name = 'Beverages' LIMIT 1)
  ),
  (
    (SELECT id FROM users WHERE email = 'trainer@mtc.local'),
    (SELECT id FROM users WHERE email = 'employee3@mtc.local'),
    (SELECT j.id FROM jobs j JOIN shifts s ON s.id = j.shift_id WHERE s.meal_type = 'Breakfast' AND j.name = 'Salads' LIMIT 1)
  ),
  (
    (SELECT id FROM users WHERE email = 'trainer@mtc.local'),
    (SELECT id FROM users WHERE email = 'employee4@mtc.local'),
    (SELECT j.id FROM jobs j JOIN shifts s ON s.id = j.shift_id WHERE s.meal_type = 'Breakfast' AND j.name = 'Sack Cashier' LIMIT 1)
  ),
  (
    (SELECT id FROM users WHERE email = 'trainer@mtc.local'),
    (SELECT id FROM users WHERE email = 'employee2@mtc.local'),
    (SELECT j.id FROM jobs j JOIN shifts s ON s.id = j.shift_id WHERE s.meal_type = 'Breakfast' AND j.name = 'Sack Runner' LIMIT 1)
  )
ON CONFLICT DO NOTHING;
