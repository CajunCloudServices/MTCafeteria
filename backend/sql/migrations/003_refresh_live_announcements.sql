-- Replace the old placeholder live announcements with the current real set.
-- Keep this targeted so we do not wipe legitimate manager-created rows.

DELETE FROM announcements
WHERE title IN (
  'Seasonal Shift Sign-Up',
  'Shift Readiness Reminder',
  'VIP Event Volunteer Sign-Up'
);

INSERT INTO announcements (type, title, content, start_date, end_date, created_by)
SELECT
  'Announcement',
  'Table Direction Changes',
  'Everyone: Management is working on changing table directions to improve customer seating. Please keep the table direction changes in place. - Dusty Lybbert',
  DATE '2026-04-09',
  CURRENT_DATE + INTERVAL '180 day',
  u.id
FROM users u
WHERE u.email = 'manager@mtc.local'
  AND NOT EXISTS (
    SELECT 1
    FROM announcements a
    WHERE a.title = 'Table Direction Changes'
      AND a.content = 'Everyone: Management is working on changing table directions to improve customer seating. Please keep the table direction changes in place. - Dusty Lybbert'
  );

INSERT INTO announcements (type, title, content, start_date, end_date, created_by)
SELECT
  'Reminder',
  'Sack Room Boiled Eggs',
  'Line: At breakfast in sack room, please put 18 boiled eggs in the warmer next to the oatmeal.',
  DATE '2026-04-04',
  CURRENT_DATE + INTERVAL '180 day',
  u.id
FROM users u
WHERE u.email = 'manager@mtc.local'
  AND NOT EXISTS (
    SELECT 1
    FROM announcements a
    WHERE a.title = 'Sack Room Boiled Eggs'
      AND a.content = 'Line: At breakfast in sack room, please put 18 boiled eggs in the warmer next to the oatmeal.'
  );

INSERT INTO announcements (type, title, content, start_date, end_date, created_by)
SELECT
  'Announcement',
  'Leave Silver Hangers on Stand',
  'Everyone: We are not recycling the silver metal hangers in the custodial closet. Please leave them on the hanger stand.',
  DATE '2026-04-04',
  CURRENT_DATE + INTERVAL '180 day',
  u.id
FROM users u
WHERE u.email = 'manager@mtc.local'
  AND NOT EXISTS (
    SELECT 1
    FROM announcements a
    WHERE a.title = 'Leave Silver Hangers on Stand'
      AND a.content = 'Everyone: We are not recycling the silver metal hangers in the custodial closet. Please leave them on the hanger stand.'
  );

INSERT INTO announcements (type, title, content, start_date, end_date, created_by)
SELECT
  'Reminder',
  'Keep Fork Containers Stocked',
  'Line: Even with the lack of metal forks, we need to make sure we are putting 2-3 containers of forks in each of the silverware stands, even if you have to put plastic in.',
  DATE '2026-04-04',
  CURRENT_DATE + INTERVAL '180 day',
  u.id
FROM users u
WHERE u.email = 'manager@mtc.local'
  AND NOT EXISTS (
    SELECT 1
    FROM announcements a
    WHERE a.title = 'Keep Fork Containers Stocked'
      AND a.content = 'Line: Even with the lack of metal forks, we need to make sure we are putting 2-3 containers of forks in each of the silverware stands, even if you have to put plastic in.'
  );
