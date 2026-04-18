-- Normalize the shared manager account to a predictable low point total
-- for kiosk/demo flows.
INSERT INTO points (user_id, points)
VALUES (
  (SELECT id FROM users WHERE email = 'manager@mtc.local'),
  5
)
ON CONFLICT (user_id) DO UPDATE
SET points = EXCLUDED.points;
