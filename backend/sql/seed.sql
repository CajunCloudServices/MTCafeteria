INSERT INTO roles (name) VALUES
  ('Employee'),
  ('Lead Trainer'),
  ('Supervisor'),
  ('Student Manager')
ON CONFLICT (name) DO NOTHING;

-- Password for all users: password123
INSERT INTO users (email, password_hash, role_id) VALUES
  ('employee@mtc.local', '$2a$10$hFr32lkOgmzoqPreOBkXZuY2jAPG9TpN6Y9FrUWSzjSG10IAVwAsC', (SELECT id FROM roles WHERE name = 'Employee')),
  ('trainer@mtc.local', '$2a$10$hFr32lkOgmzoqPreOBkXZuY2jAPG9TpN6Y9FrUWSzjSG10IAVwAsC', (SELECT id FROM roles WHERE name = 'Lead Trainer')),
  ('supervisor@mtc.local', '$2a$10$hFr32lkOgmzoqPreOBkXZuY2jAPG9TpN6Y9FrUWSzjSG10IAVwAsC', (SELECT id FROM roles WHERE name = 'Supervisor')),
  ('manager@mtc.local', '$2a$10$hFr32lkOgmzoqPreOBkXZuY2jAPG9TpN6Y9FrUWSzjSG10IAVwAsC', (SELECT id FROM roles WHERE name = 'Student Manager')),
  ('employee2@mtc.local', '$2a$10$hFr32lkOgmzoqPreOBkXZuY2jAPG9TpN6Y9FrUWSzjSG10IAVwAsC', (SELECT id FROM roles WHERE name = 'Employee')),
  ('employee3@mtc.local', '$2a$10$hFr32lkOgmzoqPreOBkXZuY2jAPG9TpN6Y9FrUWSzjSG10IAVwAsC', (SELECT id FROM roles WHERE name = 'Employee')),
  ('employee4@mtc.local', '$2a$10$hFr32lkOgmzoqPreOBkXZuY2jAPG9TpN6Y9FrUWSzjSG10IAVwAsC', (SELECT id FROM roles WHERE name = 'Employee'))
ON CONFLICT (email) DO UPDATE SET
  password_hash = EXCLUDED.password_hash,
  role_id = EXCLUDED.role_id;

INSERT INTO points (user_id, points) VALUES
  ((SELECT id FROM users WHERE email = 'employee@mtc.local'), 14),
  ((SELECT id FROM users WHERE email = 'trainer@mtc.local'), 22),
  ((SELECT id FROM users WHERE email = 'supervisor@mtc.local'), 30),
  ((SELECT id FROM users WHERE email = 'manager@mtc.local'), 45),
  ((SELECT id FROM users WHERE email = 'employee2@mtc.local'), 9),
  ((SELECT id FROM users WHERE email = 'employee3@mtc.local'), 11),
  ((SELECT id FROM users WHERE email = 'employee4@mtc.local'), 6)
ON CONFLICT (user_id) DO NOTHING;

INSERT INTO announcements (type, title, content, start_date, end_date, created_by)
VALUES (
  'Announcement',
  'Prototype Announcement',
  'Use this board for reminders, activities, and VIP event updates.',
  CURRENT_DATE,
  CURRENT_DATE + INTERVAL '7 day',
  (SELECT id FROM users WHERE email = 'manager@mtc.local')
)
ON CONFLICT DO NOTHING;

INSERT INTO trainings (title, content, assigned_date)
VALUES
  ('Service Tone', 'Greet guests and keep communication warm and clear.', CURRENT_DATE),
  ('Safety Refresh', 'Review food-contact surface sanitation guidelines.', CURRENT_DATE + INTERVAL '1 day')
ON CONFLICT DO NOTHING;

INSERT INTO shifts (shift_type, meal_type, name) VALUES
  ('Line Shift', 'Breakfast', 'Breakfast Line Shift'),
  ('Line Shift', 'Lunch', 'Lunch Line Shift'),
  ('Line Shift', 'Dinner', 'Dinner Line Shift')
ON CONFLICT DO NOTHING;

WITH meal_jobs AS (
  SELECT * FROM (VALUES
    ('Breakfast', 'Sack Cashier'),
    ('Breakfast', 'Sack Runner'),
    ('Breakfast', 'Salads'),
    ('Breakfast', 'Line Runner'),
    ('Breakfast', 'Beverages'),
    ('Breakfast', 'Senior Cash'),
    ('Breakfast', 'Junior Cash'),
    ('Breakfast', 'Desserts'),
    ('Breakfast', 'Condiments Prep'),
    ('Breakfast', 'Condiments Host'),
    ('Lunch', 'Sack Cashier'),
    ('Lunch', 'Sack Runner'),
    ('Lunch', 'Salads'),
    ('Lunch', 'Ice Cream'),
    ('Lunch', 'Paninis'),
    ('Lunch', 'Line Runner'),
    ('Lunch', 'Beverages'),
    ('Lunch', 'Senior Cash'),
    ('Lunch', 'Junior Cash'),
    ('Lunch', 'Desserts'),
    ('Lunch', 'Condiments Prep'),
    ('Lunch', 'Condiments Host'),
    ('Dinner', 'Ice Cream'),
    ('Dinner', 'Paninis'),
    ('Dinner', 'Line Runner'),
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
WHERE NOT EXISTS (
  SELECT 1 FROM jobs j WHERE j.shift_id = s.id AND j.name = mj.job_name
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
    ('Breakfast', 'Salads', 'Cleanup', 'Wipe all surfaces'),
    ('Breakfast', 'Salads', 'Cleanup', 'Put away breakfast items'),
    ('Breakfast', 'Salads', 'Cleanup', 'Clean oatmeal or grits containers'),
    ('Breakfast', 'Salads', 'Cleanup', 'Sweep area'),
    ('Breakfast', 'Salads', 'Cleanup', 'Mop if necessary'),
    ('Lunch', 'Salads', 'Setup', 'Put out salad ingredients'),
    ('Lunch', 'Salads', 'Setup', 'Put out tortillas'),
    ('Lunch', 'Salads', 'Setup', 'Set up deli bar'),
    ('Lunch', 'Salads', 'Setup', 'Ensure plates are stocked'),
    ('Lunch', 'Salads', 'During Shift', 'Keep salad bar stocked'),
    ('Lunch', 'Salads', 'During Shift', 'Ensure plates remain stocked'),
    ('Lunch', 'Salads', 'Cleanup', 'Wipe all surfaces'),
    ('Lunch', 'Salads', 'Cleanup', 'Put away salad items'),
    ('Lunch', 'Salads', 'Cleanup', 'Sweep area'),
    ('Lunch', 'Salads', 'Cleanup', 'Mop if necessary')
  ) AS t(meal_type, job_name, phase, description)
),
generic_task_defs AS (
  SELECT * FROM (VALUES
    ('Sack Runner', 'Setup', 'Assist sack cashier with setup tasks'),
    ('Sack Runner', 'During Shift', 'Restock items from sack room as needed'),
    ('Sack Runner', 'During Shift', 'Coordinate with sack cashier'),
    ('Sack Runner', 'Cleanup', 'Assist sack cashier with cleanup tasks'),
    ('Paninis', 'Setup', 'Turn on panini machines'),
    ('Paninis', 'During Shift', 'Prepare paninis'),
    ('Paninis', 'During Shift', 'Press paninis in machines'),
    ('Paninis', 'During Shift', 'Cut paninis'),
    ('Paninis', 'During Shift', 'Put paninis out for service'),
    ('Paninis', 'Cleanup', 'Turn off machines'),
    ('Paninis', 'Cleanup', 'Clean machines and work surfaces'),
    ('Paninis', 'Cleanup', 'Put away tools and supplies'),
    ('Ice Cream', 'Setup', 'Get ice cream'),
    ('Ice Cream', 'Setup', 'Get scoops'),
    ('Ice Cream', 'Setup', 'Get bowls'),
    ('Ice Cream', 'Setup', 'Get water as needed'),
    ('Ice Cream', 'During Shift', 'Serve ice cream'),
    ('Ice Cream', 'Cleanup', 'Put away ice cream'),
    ('Ice Cream', 'Cleanup', 'Clean scoops and bowls'),
    ('Ice Cream', 'Cleanup', 'Clean serving area'),
    ('Condiments Prep', 'Setup', 'Ensure condiment cart is full'),
    ('Condiments Prep', 'Setup', 'Assist condiments host with setup'),
    ('Condiments Prep', 'During Shift', 'Keep condiments stocked'),
    ('Condiments Prep', 'During Shift', 'Prepare condiments for next meal'),
    ('Condiments Prep', 'During Shift', 'If dinner: prepare condiments for breakfast bar next day'),
    ('Condiments Prep', 'Cleanup', 'Assist condiments host with cleanup'),
    ('Condiments Prep', 'Cleanup', 'Clean prep area'),
    ('Condiments Prep', 'Cleanup', 'Put away condiment cart and supplies'),
    ('Condiments Host', 'Setup', 'Same tasks as breakfast condiments host setup'),
    ('Condiments Host', 'During Shift', 'Same tasks as breakfast condiments host during shift'),
    ('Condiments Host', 'Cleanup', 'Same tasks as breakfast condiments host cleanup'),
    ('Line Runner', 'Setup', 'Fill wells with water'),
    ('Line Runner', 'Setup', 'Turn on heat'),
    ('Line Runner', 'Setup', 'Turn on heating elements'),
    ('Line Runner', 'Setup', 'Put food out in correct order'),
    ('Line Runner', 'Setup', 'Get utensils'),
    ('Line Runner', 'Setup', 'Prepare plate stacks'),
    ('Line Runner', 'During Shift', 'Keep food stocked'),
    ('Line Runner', 'During Shift', 'Communicate with chefs as needed'),
    ('Line Runner', 'During Shift', 'Put plates out 10 at a time'),
    ('Line Runner', 'During Shift', 'Keep track of plate counts'),
    ('Line Runner', 'Cleanup', 'Turn off heat'),
    ('Line Runner', 'Cleanup', 'Remove water from wells'),
    ('Line Runner', 'Cleanup', 'Empty buckets'),
    ('Line Runner', 'Cleanup', 'Turn off heating elements'),
    ('Line Runner', 'Cleanup', 'Wipe down all surfaces'),
    ('Beverages', 'Setup', 'Ensure all beverages are stocked'),
    ('Beverages', 'Setup', 'Turn on beverage machines'),
    ('Beverages', 'During Shift', 'Restock cups'),
    ('Beverages', 'During Shift', 'Check bib room for soda stock'),
    ('Beverages', 'During Shift', 'Ensure sodas are stocked'),
    ('Beverages', 'During Shift', 'Ensure juices are stocked'),
    ('Beverages', 'During Shift', 'Ensure all beverage stations remain stocked'),
    ('Beverages', 'Cleanup', 'Wipe down surfaces'),
    ('Beverages', 'Cleanup', 'Rinse troughs'),
    ('Beverages', 'Cleanup', 'Turn off all machines'),
    ('Beverages', 'Cleanup', 'Wipe down machines'),
    ('Beverages', 'Cleanup', 'Refill ice'),
    ('Beverages', 'Cleanup', 'Put ice into machines for lines 1 and 2'),
    ('Senior Cash', 'Setup', 'Sign into register'),
    ('Senior Cash', 'Setup', 'Verify register is ready'),
    ('Senior Cash', 'During Shift', 'Ring up senior missionaries'),
    ('Senior Cash', 'Cleanup', 'Restock napkins at tables'),
    ('Senior Cash', 'Cleanup', 'Restock salt and pepper shakers'),
    ('Senior Cash', 'Cleanup', 'Write next meal on whiteboard on doors'),
    ('Junior Cash', 'Setup', 'Sign into register'),
    ('Junior Cash', 'During Shift', 'Ensure missionaries swipe cards'),
    ('Junior Cash', 'During Shift', 'Keep count of missionaries without cards'),
    ('Junior Cash', 'Cleanup', 'Same cleanup tasks as Senior Cash'),
    ('Desserts', 'Setup', 'Put out desserts'),
    ('Desserts', 'Setup', 'Breakfast: donuts'),
    ('Desserts', 'Setup', 'Lunch/Dinner: cookies or assigned desserts'),
    ('Desserts', 'Setup', 'Put out plates'),
    ('Desserts', 'Setup', 'Put out utensils'),
    ('Desserts', 'During Shift', 'Keep desserts stocked'),
    ('Desserts', 'During Shift', 'Keep utensils stocked'),
    ('Desserts', 'Cleanup', 'Put away desserts'),
    ('Desserts', 'Cleanup', 'Clean counters'),
    ('Desserts', 'Cleanup', 'Sweep area'),
    ('Desserts', 'Cleanup', 'Wipe down surfaces')
  ) AS t(job_name, phase, description)
)
INSERT INTO tasks (job_id, phase, description)
SELECT j.id, ms.phase, ms.description
FROM meal_specific_task_defs ms
JOIN shifts s ON s.meal_type = ms.meal_type
JOIN jobs j ON j.shift_id = s.id AND j.name = ms.job_name
WHERE NOT EXISTS (
  SELECT 1 FROM tasks t
  WHERE t.job_id = j.id AND t.phase = ms.phase AND t.description = ms.description
);

WITH meal_jobs AS (
  SELECT * FROM (VALUES
    ('Breakfast', 'Sack Cashier'),
    ('Breakfast', 'Sack Runner'),
    ('Breakfast', 'Salads'),
    ('Breakfast', 'Line Runner'),
    ('Breakfast', 'Beverages'),
    ('Breakfast', 'Senior Cash'),
    ('Breakfast', 'Junior Cash'),
    ('Breakfast', 'Desserts'),
    ('Breakfast', 'Condiments Prep'),
    ('Breakfast', 'Condiments Host'),
    ('Lunch', 'Sack Cashier'),
    ('Lunch', 'Sack Runner'),
    ('Lunch', 'Salads'),
    ('Lunch', 'Ice Cream'),
    ('Lunch', 'Paninis'),
    ('Lunch', 'Line Runner'),
    ('Lunch', 'Beverages'),
    ('Lunch', 'Senior Cash'),
    ('Lunch', 'Junior Cash'),
    ('Lunch', 'Desserts'),
    ('Lunch', 'Condiments Prep'),
    ('Lunch', 'Condiments Host'),
    ('Dinner', 'Ice Cream'),
    ('Dinner', 'Paninis'),
    ('Dinner', 'Line Runner'),
    ('Dinner', 'Beverages'),
    ('Dinner', 'Senior Cash'),
    ('Dinner', 'Junior Cash'),
    ('Dinner', 'Desserts'),
    ('Dinner', 'Condiments Prep'),
    ('Dinner', 'Condiments Host')
  ) AS t(meal_type, job_name)
)
INSERT INTO tasks (job_id, phase, description)
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
  ((SELECT id FROM users WHERE email = 'trainer@mtc.local'), (SELECT id FROM tasks ORDER BY id LIMIT 1), true, true)
ON CONFLICT (user_id, task_id) DO NOTHING;

INSERT INTO supervisor_job_checks (meal_type, job_id, checked)
VALUES
  ('Breakfast', (SELECT j.id FROM jobs j JOIN shifts s ON s.id = j.shift_id WHERE s.meal_type = 'Breakfast' AND j.name = 'Sack Cashier' LIMIT 1), true)
ON CONFLICT (meal_type, job_id) DO NOTHING;

INSERT INTO supervisor_task_checks (meal_type, job_id, task_id, checked)
VALUES (
  'Breakfast',
  (SELECT j.id FROM jobs j JOIN shifts s ON s.id = j.shift_id WHERE s.meal_type = 'Breakfast' AND j.name = 'Sack Cashier' LIMIT 1),
  (SELECT t.id FROM tasks t JOIN jobs j ON j.id = t.job_id JOIN shifts s ON s.id = j.shift_id WHERE s.meal_type = 'Breakfast' AND j.name = 'Sack Cashier' AND t.phase = 'Cleanup' ORDER BY t.id LIMIT 1),
  true
)
ON CONFLICT (meal_type, job_id, task_id) DO NOTHING;

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
  )
ON CONFLICT DO NOTHING;
